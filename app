import { useState, useEffect, useRef } from "react";

// ─── DESIGN TOKENS ────────────────────────────────────────────────────────────
const C = {
  bg: "#111111", surface: "#141414", surfaceAlt: "#161616",
  border: "#1E1E1E", borderHover: "#2A2A2A",
  orange: "#FF4D00", orangeDim: "rgba(255,77,0,0.1)", orangeGlow: "rgba(255,77,0,0.05)",
  text: "#F0EDE8", textMid: "#888", textDim: "#555", textFaint: "#333",
};

// ─── STYLE SHORTHANDS ────────────────────────────────────────────────────────
const S = {
  // Typography
  eyebrow: { fontSize:"11px", color:"#FF4D00", letterSpacing:"2.5px", textTransform:"uppercase", fontWeight:600 },
  label:   { fontSize:"13px", fontWeight:500, color:"#C0BAB2" },
  hint:    { fontSize:"12px", color:"#555" },
  body:    { fontSize:"14px", color:"#888", lineHeight:1.7 },
  small:   { fontSize:"12px", color:"#555", lineHeight:1.6 },
  tiny:    { fontSize:"11px", color:"#333" },
  serif:   { fontFamily:"'Playfair Display', serif" },
  // Layout
  flex:    { display:"flex" },
  flexCol: { display:"flex", flexDirection:"column" },
  center:  { display:"flex", alignItems:"center" },
  between: { display:"flex", justifyContent:"space-between", alignItems:"center" },
  // Surfaces
  card:    { background:"#141414", border:"1px solid #1E1E1E", borderRadius:"12px" },
  cardAlt: { background:"#161616", border:"1px solid #1E1E1E", borderRadius:"12px" },
  // Buttons
  btnPrimary: { background:"#FF4D00", border:"none", borderRadius:"8px", color:"#111", fontFamily:"'Inter',sans-serif", cursor:"pointer" },
  btnGhost:   { background:"transparent", border:"1px solid #2A2A2A", borderRadius:"8px", color:"#888", fontFamily:"'Inter',sans-serif", cursor:"pointer" },
  // Transitions
  t2: { transition:"all 0.2s" },
  t3: { transition:"all 0.3s" },
};

const GLOBAL_STYLES = `
  @import url('https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400;1,600&family=Inter:wght@300;400;500;600&display=swap');
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
  html { scroll-behavior: smooth; }
  body { background: #111111; }
  ::-webkit-scrollbar { width: 3px; }
  ::-webkit-scrollbar-thumb { background: #FF4D00; border-radius: 2px; }
  ::selection { background: rgba(255,77,0,0.25); color: #F0EDE8; }
  a { text-decoration: none; color: inherit; }
  textarea, input, select {
    width: 100%; background: #1E1E1E; border: 1px solid #2A2A2A;
    border-radius: 8px; color: #F0EDE8; font-family: 'Inter', sans-serif;
    font-size: 14px; padding: 14px 16px; outline: none;
    transition: border-color 0.2s; resize: vertical; appearance: none;
  }
  textarea:focus, input:focus, select:focus { border-color: #FF4D00; }
  textarea::placeholder, input::placeholder { color: #444; }
  select option { background: #1E1E1E; }
  button { cursor: pointer; font-family: 'Inter', sans-serif; }
  .output-text { white-space: pre-wrap; line-height: 1.85; font-size: 14px; color: #C8C3BB; }
  @keyframes spin { to { transform: rotate(360deg); } }
  @keyframes fadeUp { from { opacity: 0; transform: translateY(16px); } to { opacity: 1; transform: translateY(0); } }
  @keyframes pulse { 0%,100% { opacity:0.5; } 50% { opacity:1; } }
`;

// ─── DATA ─────────────────────────────────────────────────────────────────────
const CASE_SECTIONS = [
  { id:"context", label:"Project Context", subtitle:"Tell us what you were hired to do", fields:[
    { id:"projectType", label:"What type of project was this?", type:"select", options:["Brand Identity","UI/UX Design","Video Production","Photography","Motion Graphics","Illustration","Web Design","Social Media Design","Other"], placeholder:"Select a project type" },
    { id:"clientContext", label:"Who was the client?", hint:"Industry, size, or type — no need to name them", type:"text", placeholder:"e.g. A Lagos-based fashion startup with 3 founders" },
    { id:"coreProblem", label:"What core problem or goal did the client bring to you?", type:"textarea", placeholder:"e.g. They had no visual identity and were about to launch. They needed to look credible and premium before their first market activation." },
    { id:"constraints", label:"What were the constraints?", hint:"Budget, timeline, brief limitations", type:"textarea", placeholder:"e.g. 2-week turnaround, limited reference material, client had strong personal opinions about colour" },
  ]},
  { id:"process", label:"Your Creative Process", subtitle:"Walk us through how you thought and worked", fields:[
    { id:"approach", label:"What was your strategy or approach going in?", type:"textarea", placeholder:"e.g. I started by researching their competitors to identify gaps in the visual landscape, then built a mood board around tension — soft luxury meeting bold structure." },
    { id:"keyDecisions", label:"What key creative decisions did you make and why?", type:"textarea", placeholder:"e.g. I chose a monogram mark over a wordmark because it would scale better across packaging and social." },
    { id:"whatFailed", label:"What did you try that didn't work?", hint:"This shows maturity — don't skip it", type:"textarea", placeholder:"e.g. My first direction was too minimal — the client felt it lacked energy." },
    { id:"tools", label:"What tools or methods did you use?", type:"text", placeholder:"e.g. Figma, Adobe Illustrator, Notion" },
  ]},
  { id:"outcome", label:"The Outcome", subtitle:"What came out of the work — and what it meant", fields:[
    { id:"deliverables", label:"What was delivered?", type:"textarea", placeholder:"e.g. Full brand identity system — logo suite, colour palette, typography guide, brand guidelines document, and social media templates." },
    { id:"impact", label:"What was the result or impact?", hint:"Qualitative counts — client reaction, revisions, reception", type:"textarea", placeholder:"e.g. Client launched with zero revision requests. Got picked up by a local press feature." },
    { id:"learned", label:"What did you learn from this project?", type:"textarea", placeholder:"e.g. I learned how to manage a client with strong personal taste without compromising the creative direction." },
  ]},
];

const OUTPUT_FORMATS = [
  { id:"casestudy", label:"Full Case Study", icon:"📄" },
  { id:"linkedin", label:"LinkedIn Post", icon:"💼" },
  { id:"deckslide", label:"Pitch Deck Slide", icon:"🎯" },
  { id:"bioblurb", label:"Bio Blurb", icon:"✍️" },
];

const FEEDBACK_QUESTIONS = [
  { id:"impression", label:"What's your overall first impression?", placeholder:"How did you feel when you first saw the work?", type:"textarea" },
  { id:"working", label:"What's working well — what do you want to keep exactly as is?", placeholder:"Be as specific as you can. Even small details matter.", type:"textarea" },
  { id:"offOrUnclear", label:"What feels off or unclear?", placeholder:"Don't hold back — honest feedback helps us get to the best result faster.", type:"textarea" },
  { id:"oneChange", label:"If you could only change one thing, what would it be?", placeholder:"Your top priority for the next round.", type:"textarea" },
  { id:"references", label:"Any references, examples, or words that describe where you want to go?", placeholder:"Links, descriptions, feelings — anything that points in the right direction.", type:"textarea" },
  { id:"timeline", label:"What's your timeline for the next round?", placeholder:"e.g. End of this week, by Friday 5pm, no rush", type:"text" },
];

const TOOLS_DATA = [
  { id:"critique", name:"Draftora Critique", tag:"GET BETTER", description:"Upload your work. Get structured, honest feedback on what's working, what isn't, and exactly what to improve — from an eye that never flatters.", detail:"For designers, filmmakers, photographers, and illustrators who want to grow faster than their environment allows.", icon:"◈", status:"Coming Soon" },
  { id:"case", name:"Draftora Case", tag:"TELL THE STORY", description:"Answer a few questions about your project. Walk away with a full case study, a LinkedIn post, a pitch deck slide, and a bio blurb — all in minutes.", detail:"For creatives who build great things but struggle to put into words why they're great.", icon:"◉", status:"Live" },
  { id:"decode", name:"Draftora Decode", tag:"UNDERSTAND THE CLIENT", description:"Send your client a focused feedback form after every delivery. Get structured, clear responses — so revisions start with a real brief, not a guess.", detail:"For freelancers who've redone work three times because the brief was never clear.", icon:"◎", status:"Live" },
];

const MANIFESTO = ["Your work is good.","You know it.","But you can't always prove it —","not in a pitch,","not in a case study,","not in a client email at 11pm.","Draftora closes that gap."];

// ─── UTILITIES ────────────────────────────────────────────────────────────────
function generateId() { return Math.random().toString(36).slice(2,10) + Date.now().toString(36); }
function timeAgo(ts) {
  const diff = Date.now() - ts;
  const m = Math.floor(diff/60000), h = Math.floor(diff/3600000), d = Math.floor(diff/86400000);
  if (d > 0) return `${d}d ago`; if (h > 0) return `${h}h ago`; if (m > 0) return `${m}m ago`; return "Just now";
}
function fmtDate(ts) { return new Date(ts).toLocaleDateString("en-GB", { day:"numeric", month:"short", year:"numeric" }); }

async function callClaude(prompt) {
  const res = await fetch("https://api.anthropic.com/v1/messages", {
    method:"POST", headers:{"Content-Type":"application/json"},
    body: JSON.stringify({ model:"claude-sonnet-4-20250514", max_tokens:1000, messages:[{ role:"user", content:prompt }] }),
  });
  const data = await res.json();
  return data.content?.map((b) => b.text||"").join("") || "Something went wrong. Please try again.";
}

function buildCasePrompt(fd, format) {
  const inst = {
    casestudy:`Write a compelling, full-length portfolio case study with a clear narrative arc. Structure it with: an opening hook, a problem section, your process and key decisions, the solution, and the outcome. Write in first person, professional but human tone. Around 400-500 words.`,
    linkedin:`Write a LinkedIn post in first person. Start with a hook. Tell the story briefly, focus on one key decision or lesson. End with a takeaway or question. 150-200 words. No hashtags.`,
    deckslide:`Write content for a single pitch deck slide. Format:\nHEADLINE: (One punchy line)\nCHALLENGE: (One sentence)\nAPPROACH: (2-3 bullet points, each under 10 words)\nRESULT: (One powerful outcome line)`,
    bioblurb:`Write a single sentence bio blurb. Format: "I [verb] the [project type] for [client description], [solving/achieving] [core outcome] through [key approach]." Under 30 words.`,
  };
  return `You are a creative writing assistant helping a designer articulate their work.\n\nPROJECT TYPE: ${fd.projectType||"Not specified"}\nCLIENT: ${fd.clientContext||"Not specified"}\nCORE PROBLEM: ${fd.coreProblem||"Not specified"}\nCONSTRAINTS: ${fd.constraints||"Not specified"}\nAPPROACH: ${fd.approach||"Not specified"}\nKEY DECISIONS: ${fd.keyDecisions||"Not specified"}\nWHAT DIDN'T WORK: ${fd.whatFailed||"Not specified"}\nTOOLS: ${fd.tools||"Not specified"}\nDELIVERABLES: ${fd.deliverables||"Not specified"}\nIMPACT: ${fd.impact||"Not specified"}\nLESSONS: ${fd.learned||"Not specified"}\n\nTASK: ${inst[format]}\n\nWrite only the content. No preamble.`;
}

function buildDecodePrompt(fb, meta) {
  return `You are a creative director helping a freelance creative understand client feedback and plan their next steps.\n\nPROJECT: ${meta.projectName}\nTYPE: ${meta.projectType}\nCREATIVE: ${meta.creativeName}\n\nCLIENT FEEDBACK:\nFirst impression: ${fb.impression||"Not provided"}\nWhat's working: ${fb.working||"Not provided"}\nWhat feels off: ${fb.offOrUnclear||"Not provided"}\nTop priority change: ${fb.oneChange||"Not provided"}\nReferences/direction: ${fb.references||"Not provided"}\nTimeline: ${fb.timeline||"Not provided"}\n\nProvide a structured analysis with three sections:\n1. WHAT THEY LOVE (2-3 sentences — specific and direct)\n2. WHAT NEEDS TO CHANGE (clear, actionable revision priorities — ordered by importance)\n3. SUGGESTED NEXT STEPS (3-4 concrete actions for the next round)\n\nDirect professional tone. No fluff. For the creative's eyes only.`;
}

function calculateConfidence(fd) {
  const fields = ["projectType","clientContext","coreProblem","constraints","approach","keyDecisions","whatFailed","tools","deliverables","impact","learned"];
  const filled = fields.filter((f) => fd[f]?.trim().length > 20).length;
  const score = Math.round((filled/fields.length)*100);
  const feedback = [];
  if (!fd.coreProblem||fd.coreProblem.length<30) feedback.push("Add more detail to the core problem — this anchors your whole story.");
  if (!fd.keyDecisions||fd.keyDecisions.length<40) feedback.push("Expand on your key decisions — this separates your thinking from everyone else's.");
  if (!fd.impact||fd.impact.length<20) feedback.push("Even a qualitative result matters — add the client's reaction or your own assessment.");
  if (!fd.whatFailed||fd.whatFailed.length<20) feedback.push("Mentioning what didn't work shows creative maturity. Don't skip it.");
  return { score, feedback };
}

// ─── PLAN SYSTEM ─────────────────────────────────────────────────────────────
const PLANS = {
  free: {
    name: "Free",
    caseLimit: 3,       // generations per month
    decodeLimit: 2,     // active links at a time
    submissionLimit: 5, // client submissions per month
    history: false,
    watermark: true,
  },
  pro: {
    name: "Pro",
    caseLimit: Infinity,
    decodeLimit: Infinity,
    submissionLimit: Infinity,
    history: true,
    watermark: false,
    price: "$9/month",
  },
};

const CURRENT_MONTH = () => new Date().toISOString().slice(0, 7); // "2025-06"

async function loadPlan() {
  try {
    const r = await window.storage.get("plan:user");
    return r ? JSON.parse(r.value) : { type: "free", caseUsed: 0, decodeUsed: 0, submissionsUsed: 0, month: CURRENT_MONTH() };
  } catch { return { type: "free", caseUsed: 0, decodeUsed: 0, submissionsUsed: 0, month: CURRENT_MONTH() }; }
}

async function savePlan(plan) {
  try { await window.storage.set("plan:user", JSON.stringify(plan)); } catch {}
}

async function incrementUsage(field) {
  const plan = await loadPlan();
  // Reset counters if new month
  const current = { ...plan, month: CURRENT_MONTH() };
  if (plan.month !== CURRENT_MONTH()) { current.caseUsed = 0; current.decodeUsed = 0; current.submissionsUsed = 0; }
  current[field] = (current[field] || 0) + 1;
  await savePlan(current);
  return current;
}

async function checkLimit(field) {
  const plan = await loadPlan();
  if (plan.month !== CURRENT_MONTH()) return { allowed: true, used: 0, limit: PLANS[plan.type || "free"][field === "caseUsed" ? "caseLimit" : field === "decodeUsed" ? "decodeLimit" : "submissionLimit"] };
  const planConfig = PLANS[plan.type || "free"];
  const limitMap = { caseUsed: "caseLimit", decodeUsed: "decodeLimit", submissionsUsed: "submissionLimit" };
  const limit = planConfig[limitMap[field]];
  const used = plan[field] || 0;
  return { allowed: used < limit, used, limit, type: plan.type || "free" };
}

// ─── ONBOARDING STORAGE ───────────────────────────────────────────────────────
async function loadUserProfile() {
  try {
    const r = await window.storage.get("user:profile");
    return r ? JSON.parse(r.value) : null;
  } catch { return null; }
}

async function saveUserProfile(profile) {
  try { await window.storage.set("user:profile", JSON.stringify(profile)); } catch {}
}

// ─── STORAGE HELPERS ──────────────────────────────────────────────────────────
async function saveProject(project) {
  try { await window.storage.set(`case:${project.id}`, JSON.stringify(project)); } catch {}
}
async function loadProjects() {
  try {
    const keys = await window.storage.list("case:");
    if (!keys?.keys?.length) return [];
    const items = await Promise.all(keys.keys.map(async (k) => {
      try { const r = await window.storage.get(k); return r ? JSON.parse(r.value) : null; } catch { return null; }
    }));
    return items.filter(Boolean).sort((a,b) => b.createdAt - a.createdAt);
  } catch { return []; }
}
async function saveThread(thread) {
  try { await window.storage.set(`decode:${thread.id}`, JSON.stringify(thread), true); } catch {}
}
async function loadThreads() {
  try {
    const keys = await window.storage.list("decode:");
    if (!keys?.keys?.length) return [];
    const items = await Promise.all(keys.keys.map(async (k) => {
      try { const r = await window.storage.get(k, true); return r ? JSON.parse(r.value) : null; } catch { return null; }
    }));
    return items.filter(Boolean).sort((a,b) => b.createdAt - a.createdAt);
  } catch { return []; }
}

// ─── HOOKS ────────────────────────────────────────────────────────────────────
function useWordReveal(text, trigger, delay=120) {
  const [revealed, setRevealed] = useState(0);
  const words = text.split(" ");
  useEffect(() => {
    if (!trigger) return;
    setRevealed(0); let i=0;
    const t = setInterval(() => { i++; setRevealed(i); if (i>=words.length) clearInterval(t); }, delay);
    return () => clearInterval(t);
  }, [trigger]);
  return { words, revealed };
}
function useIntersect(threshold=0.2) {
  const ref = useRef(null);
  const [visible, setVisible] = useState(false);
  useEffect(() => {
    const obs = new IntersectionObserver(([e]) => { if(e.isIntersecting) setVisible(true); }, { threshold });
    if (ref.current) obs.observe(ref.current);
    return () => obs.disconnect();
  }, []);
  return [ref, visible];
}

// ─── SHARED COMPONENTS ────────────────────────────────────────────────────────
function Spinner({ size=16 }) {
  return <div style={{ width:size, height:size, borderRadius:"50%", border:`2px solid ${C.border}`, borderTopColor:C.orange, animation:"spin 0.8s linear infinite", flexShrink:0 }} />;
}

function Breadcrumb({ items }) {
  return (
    <div style={{ display:"flex", alignItems:"center", gap:"8px", marginBottom:"40px" }}>
      {items.map((item,i) => (
        <span key={i} style={{ display:"flex", alignItems:"center", gap:"8px" }}>
          {i>0 && <span style={{ color:C.textFaint, fontSize:"13px" }}>›</span>}
          <button onClick={() => item.onClick?.()} style={{ background:"none", border:"none", padding:0, fontSize:"13px", color: i===items.length-1 ? C.orange : C.textDim, fontWeight: i===items.length-1 ? 500 : 400, cursor: item.onClick ? "pointer" : "default" }}
            onMouseEnter={(e) => { if(item.onClick) e.currentTarget.style.color=C.text; }}
            onMouseLeave={(e) => { if(item.onClick) e.currentTarget.style.color = i===items.length-1 ? C.orange : C.textDim; }}
          >{item.label}</button>
        </span>
      ))}
    </div>
  );
}

function PageHeader({ eyebrow, title, subtitle }) {
  return (
    <div style={{ marginBottom:"40px" }}>
      {eyebrow && <p style={{ fontSize:"11px", color:C.orange, letterSpacing:"2.5px", textTransform:"uppercase", marginBottom:"10px", fontWeight:600 }}>{eyebrow}</p>}
      <h1 style={{ fontFamily:"'Playfair Display', serif", fontSize:"clamp(22px, 4vw, 34px)", fontWeight:600, lineHeight:1.2, color:C.text, letterSpacing:"-0.3px", marginBottom: subtitle ? "12px" : 0 }}>{title}</h1>
      {subtitle && <p style={{ fontSize:"14px", color:C.textDim, lineHeight:1.7 }}>{subtitle}</p>}
    </div>
  );
}

function EmptyState({ icon, title, body, cta, onCta }) {
  return (
    <div style={{ textAlign:"center", padding:"80px 24px", border:`1px dashed ${C.borderHover}`, borderRadius:"16px" }}>
      <p style={{ fontSize:"36px", marginBottom:"16px" }}>{icon}</p>
      <p style={{ fontFamily:"'Playfair Display', serif", fontSize:"20px", color:C.text, marginBottom:"8px" }}>{title}</p>
      <p style={{ fontSize:"13px", color:C.textDim, marginBottom:"28px", lineHeight:1.6 }}>{body}</p>
      {cta && <button onClick={onCta} style={{ padding:"12px 28px", background:C.orange, border:"none", borderRadius:"8px", color:"#111", fontSize:"13px", fontWeight:600 }}>{cta}</button>}
    </div>
  );
}

function StatusPill({ status }) {
  const cfg = {
    pending:   { label:"Pending",   bg:"rgba(255,180,0,0.1)",  color:"#FFAA00", border:"rgba(255,180,0,0.3)" },
    submitted: { label:"Responded", bg:"rgba(0,200,100,0.1)",  color:"#00C864", border:"rgba(0,200,100,0.3)" },
    live:      { label:"Live",      bg:"rgba(255,77,0,0.12)",  color:C.orange,  border:"rgba(255,77,0,0.3)"  },
  }[status] || { label:status, bg:C.surfaceAlt, color:C.textMid, border:C.border };
  return (
    <span style={{ fontSize:"10px", letterSpacing:"1.5px", fontWeight:600, padding:"4px 10px", borderRadius:"20px", background:cfg.bg, color:cfg.color, border:`1px solid ${cfg.border}`, textTransform:"uppercase" }}>
      {cfg.label}
    </span>
  );
}

// ─── UPGRADE MODAL ───────────────────────────────────────────────────────────
function UpgradeModal({ reason, onClose }) {
  const reasons = {
    case: { title: "You've used your 3 free case studies this month.", body: "Upgrade to Pro and build unlimited case studies — every project, every client, every time." },
    decode: { title: "You've reached your 2 active feedback links.", body: "Upgrade to Pro for unlimited feedback links and client submissions." },
    history: { title: "History is a Pro feature.", body: "Upgrade to save every case study and feedback thread — your full creative archive, always accessible." },
  };
  const content = reasons[reason] || { title: "You've hit your free tier limit.", body: "Upgrade to Pro for unlimited access to all Draftora tools." };

  return (
    <div style={{ position:"fixed", inset:0, zIndex:1000, background:"rgba(0,0,0,0.85)", backdropFilter:"blur(8px)", display:"flex", alignItems:"center", justifyContent:"center", padding:"24px" }}
      onClick={(e) => e.target === e.currentTarget && onClose()}>
      <div style={{ background:C.surface, border:`1px solid ${C.border}`, borderRadius:"20px", padding:"48px", maxWidth:"480px", width:"100%", position:"relative", animation:"fadeUp 0.3s ease" }}>
        {/* Close */}
        <button onClick={onClose} style={{ position:"absolute", top:"20px", right:"20px", background:"none", border:"none", color:C.textDim, fontSize:"18px", lineHeight:1 }}>×</button>

        {/* Glow */}
        <div style={{ width:"56px", height:"56px", borderRadius:"16px", background:"rgba(255,77,0,0.12)", border:`1px solid rgba(255,77,0,0.3)`, display:"flex", alignItems:"center", justifyContent:"center", marginBottom:"24px", fontSize:"22px" }}>⬡</div>

        <p style={{ fontSize:"11px", color:C.orange, letterSpacing:"2px", textTransform:"uppercase", fontWeight:600, marginBottom:"12px" }}>Upgrade to Pro</p>
        <h2 style={{ fontFamily:"'Playfair Display', serif", fontSize:"22px", fontWeight:600, color:C.text, lineHeight:1.3, marginBottom:"12px" }}>{content.title}</h2>
        <p style={{ fontSize:"14px", color:C.textDim, lineHeight:1.7, marginBottom:"32px" }}>{content.body}</p>

        {/* Pro features */}
        <div style={{ background:C.surfaceAlt, borderRadius:"12px", padding:"20px", marginBottom:"28px" }}>
          {[
            "Unlimited case studies every month",
            "Unlimited client feedback links",
            "Full project & thread history",
            "No watermark on outputs",
            "Early access to Draftora Critique",
          ].map((feat, i) => (
            <div key={i} style={{ display:"flex", alignItems:"center", gap:"10px", padding:"8px 0", borderBottom: i < 4 ? `1px solid ${C.border}` : "none" }}>
              <span style={{ color:C.orange, fontSize:"12px", flexShrink:0 }}>✓</span>
              <span style={{ fontSize:"13px", color:C.textMid }}>{feat}</span>
            </div>
          ))}
        </div>

        <div style={{ display:"flex", gap:"12px" }}>
          <button style={{ flex:1, padding:"14px", background:C.orange, border:"none", borderRadius:"10px", color:"#111", fontSize:"15px", fontWeight:700, letterSpacing:"0.2px" }}
            onMouseEnter={(e) => e.currentTarget.style.opacity="0.88"}
            onMouseLeave={(e) => e.currentTarget.style.opacity="1"}
          >Upgrade — $9/month</button>
          <button onClick={onClose} style={{ padding:"14px 20px", background:"transparent", border:`1px solid ${C.borderHover}`, borderRadius:"10px", color:C.textDim, fontSize:"14px" }}>Later</button>
        </div>

        <p style={{ fontSize:"11px", color:C.textFaint, textAlign:"center", marginTop:"16px" }}>Cancel anytime. No commitments.</p>
      </div>
    </div>
  );
}

// ─── ONBOARDING ───────────────────────────────────────────────────────────────
const CREATIVE_TYPES = [
  { id:"designer", label:"Designer", icon:"◈", desc:"Brand, UI/UX, graphic, or visual design" },
  { id:"filmmaker", label:"Filmmaker", icon:"◉", desc:"Video, film, documentary, or motion" },
  { id:"photographer", label:"Photographer", icon:"◎", desc:"Commercial, editorial, or creative photography" },
  { id:"illustrator", label:"Illustrator", icon:"⬡", desc:"Illustration, art direction, or concept art" },
  { id:"other", label:"Other Creative", icon:"◇", desc:"Something else — you're still welcome here" },
];

function Onboarding({ onComplete }) {
  const [step, setStep] = useState(1);
  const [creativeType, setCreativeType] = useState("");
  const [firstAction, setFirstAction] = useState("");
  const [name, setName] = useState("");
  const [saving, setSaving] = useState(false);

  const handleComplete = async () => {
    if (!name.trim()) return;
    setSaving(true);
    const profile = { name: name.trim(), creativeType, firstAction, completedAt: Date.now() };
    await saveUserProfile(profile);
    onComplete(profile, firstAction);
  };

  return (
    <div style={{ minHeight:"100vh", background:C.bg, display:"flex", flexDirection:"column", alignItems:"center", justifyContent:"center", padding:"24px", position:"relative", overflow:"hidden" }}>
      {/* Ambient glow */}
      <div style={{ position:"absolute", top:"20%", left:"50%", transform:"translateX(-50%)", width:"600px", height:"600px", borderRadius:"50%", background:`radial-gradient(circle, ${C.orangeGlow} 0%, transparent 70%)`, pointerEvents:"none" }} />

      <div style={{ width:"100%", maxWidth:"560px", position:"relative", zIndex:1 }}>
        {/* Logo */}
        <div style={{ textAlign:"center", marginBottom:"48px" }}>
          <span style={{ fontFamily:"'Playfair Display', serif", fontSize:"28px", fontWeight:700, color:C.text }}>
            Draft<span style={{ color:C.orange }}>ora</span>
          </span>
        </div>

        {/* Progress dots */}
        <div style={{ display:"flex", justifyContent:"center", gap:"8px", marginBottom:"48px" }}>
          {[1,2,3].map((s) => (
            <div key={s} style={{ width: s === step ? "24px" : "8px", height:"8px", borderRadius:"4px", background: s <= step ? C.orange : C.border, transition:"all 0.3s ease" }} />
          ))}
        </div>

        {/* Step 1 — Creative type */}
        {step === 1 && (
          <div style={{ animation:"fadeUp 0.4s ease" }}>
            <p style={{ fontSize:"11px", color:C.orange, letterSpacing:"2.5px", textTransform:"uppercase", fontWeight:600, marginBottom:"16px", textAlign:"center" }}>Step 1 of 3</p>
            <h1 style={{ fontFamily:"'Playfair Display', serif", fontSize:"clamp(24px, 4vw, 36px)", fontWeight:600, color:C.text, lineHeight:1.2, letterSpacing:"-0.5px", marginBottom:"12px", textAlign:"center" }}>
              What kind of creative are you?
            </h1>
            <p style={{ fontSize:"14px", color:C.textDim, textAlign:"center", marginBottom:"36px", lineHeight:1.6 }}>
              This helps Draftora speak your language.
            </p>
            <div style={{ display:"flex", flexDirection:"column", gap:"10px", marginBottom:"36px" }}>
              {CREATIVE_TYPES.map((type) => (
                <button key={type.id} onClick={() => setCreativeType(type.id)}
                  style={{ padding:"18px 20px", background: creativeType===type.id ? C.orangeDim : C.surface, border:`1px solid ${creativeType===type.id ? C.orange : C.border}`, borderRadius:"12px", textAlign:"left", transition:"all 0.2s", display:"flex", alignItems:"center", gap:"16px" }}
                  onMouseEnter={(e) => { if(creativeType!==type.id) e.currentTarget.style.borderColor=C.borderHover; }}
                  onMouseLeave={(e) => { if(creativeType!==type.id) e.currentTarget.style.borderColor=C.border; }}
                >
                  <span style={{ fontSize:"20px", color:C.orange, flexShrink:0 }}>{type.icon}</span>
                  <div>
                    <p style={{ fontSize:"14px", fontWeight:600, color:C.text, marginBottom:"2px" }}>{type.label}</p>
                    <p style={{ fontSize:"12px", color:C.textDim }}>{type.desc}</p>
                  </div>
                  {creativeType===type.id && <span style={{ marginLeft:"auto", color:C.orange, fontSize:"16px", flexShrink:0 }}>✓</span>}
                </button>
              ))}
            </div>
            <button onClick={() => setStep(2)} disabled={!creativeType}
              style={{ width:"100%", padding:"16px", background: creativeType ? C.orange : C.border, border:"none", borderRadius:"10px", color: creativeType ? "#111" : "#333", fontSize:"15px", fontWeight:700, transition:"all 0.2s" }}>
              Continue →
            </button>
          </div>
        )}

        {/* Step 2 — First action */}
        {step === 2 && (
          <div style={{ animation:"fadeUp 0.4s ease" }}>
            <p style={{ fontSize:"11px", color:C.orange, letterSpacing:"2.5px", textTransform:"uppercase", fontWeight:600, marginBottom:"16px", textAlign:"center" }}>Step 2 of 3</p>
            <h1 style={{ fontFamily:"'Playfair Display', serif", fontSize:"clamp(24px, 4vw, 36px)", fontWeight:600, color:C.text, lineHeight:1.2, letterSpacing:"-0.5px", marginBottom:"12px", textAlign:"center" }}>
              What do you want to do first?
            </h1>
            <p style={{ fontSize:"14px", color:C.textDim, textAlign:"center", marginBottom:"36px", lineHeight:1.6 }}>
              We'll take you straight there after setup.
            </p>
            <div style={{ display:"flex", flexDirection:"column", gap:"12px", marginBottom:"36px" }}>
              {[
                { id:"case", icon:"◉", title:"Build a case study", desc:"Turn a finished project into a compelling portfolio story." },
                { id:"decode", icon:"◎", title:"Send a feedback link", desc:"Get clear, structured feedback from a client after a delivery." },
              ].map((action) => (
                <button key={action.id} onClick={() => setFirstAction(action.id)}
                  style={{ padding:"24px", background: firstAction===action.id ? C.orangeDim : C.surface, border:`1px solid ${firstAction===action.id ? C.orange : C.border}`, borderRadius:"12px", textAlign:"left", transition:"all 0.2s", display:"flex", alignItems:"center", gap:"16px" }}
                  onMouseEnter={(e) => { if(firstAction!==action.id) e.currentTarget.style.borderColor=C.borderHover; }}
                  onMouseLeave={(e) => { if(firstAction!==action.id) e.currentTarget.style.borderColor=C.border; }}
                >
                  <span style={{ fontSize:"24px", color:C.orange, flexShrink:0 }}>{action.icon}</span>
                  <div>
                    <p style={{ fontSize:"15px", fontWeight:600, color:C.text, marginBottom:"4px" }}>{action.title}</p>
                    <p style={{ fontSize:"13px", color:C.textDim, lineHeight:1.5 }}>{action.desc}</p>
                  </div>
                  {firstAction===action.id && <span style={{ marginLeft:"auto", color:C.orange, fontSize:"16px", flexShrink:0 }}>✓</span>}
                </button>
              ))}
            </div>
            <div style={{ display:"flex", gap:"12px" }}>
              <button onClick={() => setStep(1)} style={{ padding:"16px 24px", background:"transparent", border:`1px solid ${C.borderHover}`, borderRadius:"10px", color:C.textDim, fontSize:"14px" }}>Back</button>
              <button onClick={() => setStep(3)} disabled={!firstAction}
                style={{ flex:1, padding:"16px", background: firstAction ? C.orange : C.border, border:"none", borderRadius:"10px", color: firstAction ? "#111" : "#333", fontSize:"15px", fontWeight:700, transition:"all 0.2s" }}>
                Continue →
              </button>
            </div>
          </div>
        )}

        {/* Step 3 — Name */}
        {step === 3 && (
          <div style={{ animation:"fadeUp 0.4s ease" }}>
            <p style={{ fontSize:"11px", color:C.orange, letterSpacing:"2.5px", textTransform:"uppercase", fontWeight:600, marginBottom:"16px", textAlign:"center" }}>Step 3 of 3</p>
            <h1 style={{ fontFamily:"'Playfair Display', serif", fontSize:"clamp(24px, 4vw, 36px)", fontWeight:600, color:C.text, lineHeight:1.2, letterSpacing:"-0.5px", marginBottom:"12px", textAlign:"center" }}>
              What should we call you?
            </h1>
            <p style={{ fontSize:"14px", color:C.textDim, textAlign:"center", marginBottom:"36px", lineHeight:1.6 }}>
              Just your first name is fine.
            </p>
            <input type="text" value={name} onChange={(e) => setName(e.target.value)}
              placeholder="e.g. Bobby"
              style={{ marginBottom:"12px", fontSize:"18px", padding:"18px 20px", textAlign:"center" }}
              onKeyDown={(e) => e.key==="Enter" && name.trim() && handleComplete()}
              autoFocus
            />
            <p style={{ fontSize:"12px", color:C.textFaint, textAlign:"center", marginBottom:"28px" }}>
              Your dashboard will greet you by name.
            </p>
            <div style={{ display:"flex", gap:"12px" }}>
              <button onClick={() => setStep(2)} style={{ padding:"16px 24px", background:"transparent", border:`1px solid ${C.borderHover}`, borderRadius:"10px", color:C.textDim, fontSize:"14px" }}>Back</button>
              <button onClick={handleComplete} disabled={!name.trim() || saving}
                style={{ flex:1, padding:"16px", background: name.trim() ? C.orange : C.border, border:"none", borderRadius:"10px", color: name.trim() ? "#111" : "#333", fontSize:"15px", fontWeight:700, opacity: saving ? 0.7 : 1, transition:"all 0.2s" }}>
                {saving ? "Setting up..." : "Let's go →"}
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

// ─── NAV ──────────────────────────────────────────────────────────────────────
function Nav({ view, setView, scrolled, onGetStarted }) {
  const isLanding = view === "landing";
  const navItems = [
    { label:"Dashboard", view:"dashboard", icon:"⬡" },
    { label:"My Projects", view:"projects", icon:"◉" },
    { label:"Feedback Threads", view:"threads", icon:"◎" },
  ];
  return (
    <nav style={{ position:"fixed", top:0, left:0, right:0, zIndex:200, padding:"16px 48px", background: !isLanding||scrolled ? "rgba(17,17,17,0.95)" : "transparent", backdropFilter: !isLanding||scrolled ? "blur(16px)" : "none", borderBottom: !isLanding||scrolled ? `1px solid ${C.border}` : "none", transition:"all 0.3s ease", display:"flex", alignItems:"center", justifyContent:"space-between" }}>
      <button onClick={() => setView("landing")} style={{ background:"none", border:"none", padding:0 }}>
        <span style={{ fontFamily:"'Playfair Display', serif", fontSize:"22px", fontWeight:700, letterSpacing:"-0.5px", color:C.text }}>Draft<span style={{ color:C.orange }}>ora</span></span>
      </button>
      <div style={{ display:"flex", gap:"8px", alignItems:"center" }}>
        {!isLanding && navItems.map((item) => (
          <button key={item.view} onClick={() => setView(item.view)}
            style={{ padding:"8px 14px", background: view===item.view ? C.orangeDim : "transparent", border:`1px solid ${view===item.view ? C.orange : "transparent"}`, borderRadius:"8px", color: view===item.view ? C.orange : C.textDim, fontSize:"12px", fontWeight:500, transition:"all 0.2s" }}
            onMouseEnter={(e) => { if(view!==item.view) { e.currentTarget.style.color=C.text; e.currentTarget.style.borderColor=C.borderHover; }}}
            onMouseLeave={(e) => { if(view!==item.view) { e.currentTarget.style.color=C.textDim; e.currentTarget.style.borderColor="transparent"; }}}
          >{item.label}</button>
        ))}
        {isLanding ? (
          <>
            {["Tools","How it works","For who"].map((item) => (
              <a key={item} href={`#${item.toLowerCase().replace(/ /g,"-")}`} style={{ fontSize:"13px", color:C.textDim, padding:"8px 4px", transition:"color 0.2s" }}
                onMouseEnter={(e) => e.target.style.color=C.text}
                onMouseLeave={(e) => e.target.style.color=C.textDim}
              >{item}</a>
            ))}
          </>
        ) : null}
        <button onClick={() => isLanding ? onGetStarted() : setView("case")}
          style={{ marginLeft:"8px", padding:"10px 20px", background:C.orange, border:"none", borderRadius:"8px", color:"#111", fontSize:"13px", fontWeight:600, transition:"opacity 0.2s" }}
          onMouseEnter={(e) => e.currentTarget.style.opacity="0.85"}
          onMouseLeave={(e) => e.currentTarget.style.opacity="1"}
        >{isLanding ? "Get Started" : "+ New Project"}</button>
      </div>
    </nav>
  );
}

// ─── DASHBOARD ────────────────────────────────────────────────────────────────
function Dashboard({ setView, setDetailProject, setDetailThread, userName }) {
  const [projects, setProjects] = useState([]);
  const [threads, setThreads] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    (async () => {
      const [p, t] = await Promise.all([loadProjects(), loadThreads()]);
      setProjects(p.slice(0,3));
      setThreads(t.slice(0,3));
      setLoading(false);
    })();
  }, []);

  const totalProjects = projects.length;
  const pendingThreads = threads.filter((t) => t.status==="pending").length;
  const respondedThreads = threads.filter((t) => t.status==="submitted").length;

  return (
    <div style={{ minHeight:"100vh", background:C.bg, paddingTop:"72px" }}>
      <div style={{ maxWidth:"1000px", margin:"0 auto", padding:"48px 24px 100px" }}>

        {/* Welcome */}
        <div style={{ marginBottom:"48px", paddingBottom:"40px", borderBottom:`1px solid ${C.border}` }}>
          <p style={{ fontSize:"11px", color:C.orange, letterSpacing:"2.5px", textTransform:"uppercase", marginBottom:"12px", fontWeight:600 }}>Dashboard</p>
          <h1 style={{ fontFamily:"'Playfair Display', serif", fontSize:"clamp(28px, 4vw, 42px)", fontWeight:600, color:C.text, letterSpacing:"-0.8px", lineHeight:1.2 }}>
            {userName ? `Welcome back, ${userName}.` : "Welcome back."}
          </h1>
          <p style={{ fontSize:"15px", color:C.textDim, marginTop:"10px", fontWeight:300 }}>What are you working on today?</p>
        </div>

        {/* Quick Actions */}
        <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr", gap:"16px", marginBottom:"56px" }}>
          {[
            { icon:"◉", label:"New Case Study", sub:"Document a project", view:"case", live:true },
            { icon:"◎", label:"New Feedback Request", sub:"Send a client feedback link", view:"decode", live:true },
            { icon:"◈", label:"Draftora Critique", sub:"Coming soon", view:null, live:false },
            { icon:"⬡", label:"View All History", sub:"Projects & feedback threads", view:"projects", live:true },
          ].map((action) => (
            <button key={action.label} onClick={() => action.live && setView(action.view)}
              style={{ padding:"24px", background: action.live ? C.surface : "#111", border:`1px solid ${C.border}`, borderRadius:"12px", textAlign:"left", transition:"all 0.25s", opacity: action.live ? 1 : 0.4, cursor: action.live ? "pointer" : "not-allowed", position:"relative", overflow:"hidden" }}
              onMouseEnter={(e) => { if(action.live) { e.currentTarget.style.borderColor=C.orange; e.currentTarget.style.background="rgba(255,77,0,0.03)"; }}}
              onMouseLeave={(e) => { if(action.live) { e.currentTarget.style.borderColor=C.border; e.currentTarget.style.background=C.surface; }}}
            >
              <span style={{ fontSize:"22px", display:"block", marginBottom:"12px", color:C.orange }}>{action.icon}</span>
              <p style={{ fontSize:"15px", fontWeight:600, color:C.text, marginBottom:"4px" }}>{action.label}</p>
              <p style={{ fontSize:"12px", color:C.textDim }}>{action.sub}</p>
              {action.live && <span style={{ position:"absolute", top:"16px", right:"16px", fontSize:"14px", color:C.textFaint }}>→</span>}
            </button>
          ))}
        </div>

        {/* Stats Row */}
        <div style={{ display:"grid", gridTemplateColumns:"repeat(3, 1fr)", gap:"16px", marginBottom:"56px" }}>
          {[
            { label:"Case Studies", value: loading ? "—" : projects.length, sub:"saved projects" },
            { label:"Feedback Pending", value: loading ? "—" : pendingThreads, sub:"awaiting client" },
            { label:"Responses In", value: loading ? "—" : respondedThreads, sub:"ready to review" },
          ].map((stat) => (
            <div key={stat.label} style={{ padding:"24px", background:C.surface, border:`1px solid ${C.border}`, borderRadius:"12px" }}>
              <p style={{ fontSize:"11px", color:C.textDim, letterSpacing:"1.5px", textTransform:"uppercase", marginBottom:"10px" }}>{stat.label}</p>
              <p style={{ fontFamily:"'Playfair Display', serif", fontSize:"36px", fontWeight:700, color:C.text, lineHeight:1, marginBottom:"4px" }}>{stat.value}</p>
              <p style={{ fontSize:"12px", color:C.textFaint }}>{stat.sub}</p>
            </div>
          ))}
        </div>

        {/* Recent Projects */}
        <div style={{ marginBottom:"48px" }}>
          <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center", marginBottom:"20px" }}>
            <p style={{ fontSize:"13px", fontWeight:600, color:C.text }}>Recent Case Studies</p>
            <button onClick={() => setView("projects")} style={{ background:"none", border:"none", fontSize:"12px", color:C.textDim, transition:"color 0.2s" }}
              onMouseEnter={(e) => e.currentTarget.style.color=C.orange}
              onMouseLeave={(e) => e.currentTarget.style.color=C.textDim}
            >View all →</button>
          </div>
          {loading ? (
            <div style={{ padding:"32px", textAlign:"center" }}><Spinner /></div>
          ) : projects.length === 0 ? (
            <EmptyState icon="◉" title="No case studies yet" body="Build your first one — it takes less than 10 minutes." cta="Start Draftora Case" onCta={() => setView("case")} />
          ) : (
            <div style={{ display:"flex", flexDirection:"column", gap:"12px" }}>
              {projects.map((p) => (
                <button key={p.id} onClick={() => { setDetailProject(p); setView("project-detail"); }}
                  style={{ padding:"20px 24px", background:C.surface, border:`1px solid ${C.border}`, borderRadius:"10px", textAlign:"left", transition:"all 0.2s", display:"flex", justifyContent:"space-between", alignItems:"center" }}
                  onMouseEnter={(e) => { e.currentTarget.style.borderColor=C.orange; }}
                  onMouseLeave={(e) => { e.currentTarget.style.borderColor=C.border; }}
                >
                  <div style={{ display:"flex", alignItems:"center", gap:"16px" }}>
                    <span style={{ fontSize:"18px", color:C.orange }}>◉</span>
                    <div>
                      <p style={{ fontSize:"14px", fontWeight:600, color:C.text, marginBottom:"2px" }}>{p.projectName || p.formData?.clientContext || "Untitled Project"}</p>
                      <p style={{ fontSize:"12px", color:C.textDim }}>{p.formData?.projectType || "Project"} · {fmtDate(p.createdAt)}</p>
                    </div>
                  </div>
                  <div style={{ display:"flex", gap:"6px", alignItems:"center" }}>
                    {p.outputs && Object.keys(p.outputs).map((fmt) => (
                      <span key={fmt} style={{ fontSize:"10px", padding:"3px 8px", background:C.surfaceAlt, borderRadius:"4px", color:C.textDim }}>{OUTPUT_FORMATS.find((f)=>f.id===fmt)?.icon}</span>
                    ))}
                    <span style={{ fontSize:"13px", color:C.textFaint, marginLeft:"8px" }}>→</span>
                  </div>
                </button>
              ))}
            </div>
          )}
        </div>

        {/* Recent Threads */}
        <div>
          <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center", marginBottom:"20px" }}>
            <p style={{ fontSize:"13px", fontWeight:600, color:C.text }}>Recent Feedback Threads</p>
            <button onClick={() => setView("threads")} style={{ background:"none", border:"none", fontSize:"12px", color:C.textDim, transition:"color 0.2s" }}
              onMouseEnter={(e) => e.currentTarget.style.color=C.orange}
              onMouseLeave={(e) => e.currentTarget.style.color=C.textDim}
            >View all →</button>
          </div>
          {loading ? (
            <div style={{ padding:"32px", textAlign:"center" }}><Spinner /></div>
          ) : threads.length === 0 ? (
            <EmptyState icon="◎" title="No feedback threads yet" body="Send your first client feedback link after your next delivery." cta="Start Draftora Decode" onCta={() => setView("decode")} />
          ) : (
            <div style={{ display:"flex", flexDirection:"column", gap:"12px" }}>
              {threads.map((t) => (
                <button key={t.id} onClick={() => { setDetailThread(t); setView("thread-detail"); }}
                  style={{ padding:"20px 24px", background:C.surface, border:`1px solid ${C.border}`, borderRadius:"10px", textAlign:"left", transition:"all 0.2s", display:"flex", justifyContent:"space-between", alignItems:"center" }}
                  onMouseEnter={(e) => { e.currentTarget.style.borderColor = t.status==="submitted" ? "#00C864" : C.orange; }}
                  onMouseLeave={(e) => { e.currentTarget.style.borderColor=C.border; }}
                >
                  <div style={{ display:"flex", alignItems:"center", gap:"16px" }}>
                    <span style={{ fontSize:"18px", color: t.status==="submitted" ? "#00C864" : C.orange }}>◎</span>
                    <div>
                      <p style={{ fontSize:"14px", fontWeight:600, color:C.text, marginBottom:"2px" }}>{t.meta?.projectName || "Untitled"}</p>
                      <p style={{ fontSize:"12px", color:C.textDim }}>{t.meta?.clientName || "Client"} · {timeAgo(t.createdAt)}</p>
                    </div>
                  </div>
                  <div style={{ display:"flex", alignItems:"center", gap:"12px" }}>
                    <StatusPill status={t.status} />
                    <span style={{ fontSize:"13px", color:C.textFaint }}>→</span>
                  </div>
                </button>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

// ─── MY PROJECTS PAGE ─────────────────────────────────────────────────────────
function MyProjectsPage({ setView, setDetailProject }) {
  const [projects, setProjects] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [filter, setFilter] = useState("all");

  useEffect(() => {
    loadProjects().then((p) => { setProjects(p); setLoading(false); });
  }, []);

  const types = ["all", ...new Set(projects.map((p) => p.formData?.projectType).filter(Boolean))];
  const filtered = projects.filter((p) => {
    const name = (p.projectName || p.formData?.clientContext || "").toLowerCase();
    const type = (p.formData?.projectType || "").toLowerCase();
    const matchSearch = !search || name.includes(search.toLowerCase()) || type.includes(search.toLowerCase());
    const matchFilter = filter === "all" || p.formData?.projectType === filter;
    return matchSearch && matchFilter;
  });

  return (
    <div style={{ minHeight:"100vh", background:C.bg, paddingTop:"72px" }}>
      <div style={{ maxWidth:"900px", margin:"0 auto", padding:"48px 24px 100px" }}>
        <Breadcrumb items={[{ label:"Dashboard", onClick:() => setView("dashboard") }, { label:"My Projects" }]} />
        <div style={{ display:"flex", justifyContent:"space-between", alignItems:"flex-end", marginBottom:"36px" }}>
          <PageHeader eyebrow="Draftora Case" title="My Projects" subtitle="Every case study you've built — all in one place." />
          <button onClick={() => setView("case")} style={{ padding:"12px 24px", background:C.orange, border:"none", borderRadius:"8px", color:"#111", fontSize:"13px", fontWeight:600, flexShrink:0, marginLeft:"24px", marginBottom:"40px" }}>
            + New Case Study
          </button>
        </div>

        {/* Search & Filter */}
        {projects.length > 0 && (
          <div style={{ display:"flex", gap:"12px", marginBottom:"28px", flexWrap:"wrap" }}>
            <input type="text" value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search projects..." style={{ flex:1, minWidth:"200px" }} />
            <div style={{ display:"flex", gap:"8px", flexWrap:"wrap" }}>
              {types.map((t) => (
                <button key={t} onClick={() => setFilter(t)}
                  style={{ padding:"10px 16px", borderRadius:"8px", fontSize:"12px", fontWeight:500, border:`1px solid ${filter===t ? C.orange : C.borderHover}`, background: filter===t ? C.orangeDim : "transparent", color: filter===t ? C.orange : C.textMid, transition:"all 0.2s", textTransform:"capitalize" }}>
                  {t}
                </button>
              ))}
            </div>
          </div>
        )}

        {loading ? (
          <div style={{ padding:"80px", textAlign:"center" }}><Spinner size={24} /></div>
        ) : projects.length === 0 ? (
          <EmptyState icon="◉" title="No case studies yet" body="Your first Draftora Case project will appear here once you build it. It takes less than 10 minutes." cta="Build Your First Case Study" onCta={() => setView("case")} />
        ) : filtered.length === 0 ? (
          <div style={{ padding:"48px", textAlign:"center" }}>
            <p style={{ color:C.textDim, fontSize:"14px" }}>No projects match your search.</p>
          </div>
        ) : (
          <div style={{ display:"grid", gridTemplateColumns:"repeat(auto-fill, minmax(380px, 1fr))", gap:"16px" }}>
            {filtered.map((p) => (
              <button key={p.id} onClick={() => { setDetailProject(p); setView("project-detail"); }}
                style={{ padding:"28px", background:C.surface, border:`1px solid ${C.border}`, borderRadius:"12px", textAlign:"left", transition:"all 0.25s", cursor:"pointer", position:"relative", overflow:"hidden" }}
                onMouseEnter={(e) => { e.currentTarget.style.borderColor=C.orange; e.currentTarget.style.background="rgba(255,77,0,0.02)"; }}
                onMouseLeave={(e) => { e.currentTarget.style.borderColor=C.border; e.currentTarget.style.background=C.surface; }}
              >
                <div style={{ display:"flex", justifyContent:"space-between", alignItems:"flex-start", marginBottom:"16px" }}>
                  <span style={{ fontSize:"11px", color:C.orange, letterSpacing:"1.5px", fontWeight:600, textTransform:"uppercase" }}>{p.formData?.projectType || "Project"}</span>
                  <span style={{ fontSize:"11px", color:C.textFaint }}>{fmtDate(p.createdAt)}</span>
                </div>
                <p style={{ fontFamily:"'Playfair Display', serif", fontSize:"18px", fontWeight:600, color:C.text, marginBottom:"8px", lineHeight:1.3 }}>
                  {p.projectName || p.formData?.clientContext || "Untitled Project"}
                </p>
                <p style={{ fontSize:"12px", color:C.textDim, lineHeight:1.6, marginBottom:"20px" }}>
                  {p.formData?.coreProblem ? p.formData.coreProblem.slice(0,100) + (p.formData.coreProblem.length > 100 ? "..." : "") : "No description"}
                </p>
                <div style={{ display:"flex", gap:"6px", paddingTop:"16px", borderTop:`1px solid ${C.border}` }}>
                  {p.outputs && Object.keys(p.outputs).map((fmt) => {
                    const f = OUTPUT_FORMATS.find((x) => x.id===fmt);
                    return f ? <span key={fmt} style={{ fontSize:"11px", padding:"4px 10px", background:C.surfaceAlt, border:`1px solid ${C.borderHover}`, borderRadius:"6px", color:C.textDim }}>{f.icon} {f.label}</span> : null;
                  })}
                  {(!p.outputs || Object.keys(p.outputs).length===0) && <span style={{ fontSize:"11px", color:C.textFaint }}>No outputs generated yet</span>}
                </div>
                <div style={{ position:"absolute", bottom:0, left:0, right:0, height:"2px", background:C.orange, transform:"scaleX(0)", transformOrigin:"left", transition:"transform 0.3s" }} className="hover-line" />
              </button>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

// ─── PROJECT DETAIL ───────────────────────────────────────────────────────────
function ProjectDetail({ project, setView }) {
  const [activeFormat, setActiveFormat] = useState("casestudy");
  const [outputs, setOutputs] = useState(project.outputs || {});
  const [loading, setLoading] = useState({});
  const [copied, setCopied] = useState(false);

  const generateOutput = async (format) => {
    setLoading((p) => ({ ...p, [format]:true }));
    try {
      const text = await callClaude(buildCasePrompt(project.formData, format));
      const updated = { ...outputs, [format]:text };
      setOutputs(updated);
      await saveProject({ ...project, outputs:updated });
    } catch { setOutputs((p) => ({ ...p, [format]:"Generation failed. Please try again." })); }
    setLoading((p) => ({ ...p, [format]:false }));
  };

  const handleCopy = () => {
    navigator.clipboard.writeText(outputs[activeFormat] || "");
    setCopied(true); setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div style={{ minHeight:"100vh", background:C.bg, paddingTop:"72px" }}>
      <div style={{ maxWidth:"720px", margin:"0 auto", padding:"48px 24px 100px" }}>
        <Breadcrumb items={[{ label:"Dashboard", onClick:() => setView("dashboard") }, { label:"My Projects", onClick:() => setView("projects") }, { label: project.projectName || "Project" }]} />

        {/* Project Meta */}
        <div style={{ marginBottom:"40px" }}>
          <span style={{ fontSize:"11px", color:C.orange, letterSpacing:"2px", textTransform:"uppercase", fontWeight:600 }}>{project.formData?.projectType}</span>
          <h1 style={{ fontFamily:"'Playfair Display', serif", fontSize:"clamp(24px, 4vw, 36px)", fontWeight:600, color:C.text, marginTop:"8px", marginBottom:"8px", letterSpacing:"-0.5px" }}>
            {project.projectName || project.formData?.clientContext || "Untitled Project"}
          </h1>
          <p style={{ fontSize:"13px", color:C.textDim }}>Created {fmtDate(project.createdAt)}</p>
        </div>

        {/* Project Summary */}
        <div style={{ background:C.surface, border:`1px solid ${C.border}`, borderRadius:"12px", padding:"24px", marginBottom:"36px" }}>
          <p style={{ fontSize:"11px", color:C.textDim, letterSpacing:"1.5px", textTransform:"uppercase", marginBottom:"16px", fontWeight:600 }}>Project Overview</p>
          <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr", gap:"16px" }}>
            {[
              { label:"Client", value:project.formData?.clientContext },
              { label:"Deliverables", value:project.formData?.deliverables },
              { label:"Tools Used", value:project.formData?.tools },
              { label:"Impact", value:project.formData?.impact },
            ].filter((item) => item.value).map((item) => (
              <div key={item.label}>
                <p style={{ fontSize:"11px", color:C.textFaint, marginBottom:"4px", textTransform:"uppercase", letterSpacing:"1px" }}>{item.label}</p>
                <p style={{ fontSize:"13px", color:C.textMid, lineHeight:1.5 }}>{item.value.slice(0,120)}{item.value.length>120 ? "..." : ""}</p>
              </div>
            ))}
          </div>
        </div>

        {/* Output Tabs */}
        <div style={{ marginBottom:"20px" }}>
          <p style={{ fontSize:"11px", color:C.orange, letterSpacing:"2px", textTransform:"uppercase", marginBottom:"16px", fontWeight:600 }}>Your Outputs</p>
          <div style={{ display:"flex", gap:"8px", flexWrap:"wrap" }}>
            {OUTPUT_FORMATS.map((fmt) => (
              <button key={fmt.id} onClick={() => { setActiveFormat(fmt.id); if(!outputs[fmt.id]) generateOutput(fmt.id); }}
                style={{ padding:"10px 16px", borderRadius:"8px", fontSize:"13px", fontWeight:500, border:`1px solid ${activeFormat===fmt.id ? C.orange : C.borderHover}`, background: activeFormat===fmt.id ? C.orangeDim : "transparent", color: activeFormat===fmt.id ? C.orange : C.textMid, transition:"all 0.2s" }}>
                {fmt.icon} {fmt.label}
              </button>
            ))}
          </div>
        </div>

        <div style={{ background:C.surfaceAlt, borderRadius:"12px", border:`1px solid ${C.border}`, overflow:"hidden" }}>
          <div style={{ padding:"14px 20px", borderBottom:`1px solid ${C.border}`, display:"flex", justifyContent:"space-between", alignItems:"center" }}>
            <span style={{ fontSize:"11px", color:C.textDim, letterSpacing:"1.5px", textTransform:"uppercase" }}>{OUTPUT_FORMATS.find((f) => f.id===activeFormat)?.label}</span>
            <div style={{ display:"flex", gap:"8px" }}>
              {outputs[activeFormat] && (
                <>
                  <button onClick={handleCopy} style={{ padding:"6px 14px", background:"transparent", border:`1px solid ${C.borderHover}`, borderRadius:"6px", color: copied ? C.orange : C.textMid, fontSize:"12px", transition:"color 0.2s" }}>
                    {copied ? "Copied!" : "Copy"}
                  </button>
                  <button onClick={() => generateOutput(activeFormat)} style={{ padding:"6px 14px", background:"transparent", border:`1px solid ${C.borderHover}`, borderRadius:"6px", color:C.textMid, fontSize:"12px" }}>
                    ↺ Regenerate
                  </button>
                </>
              )}
            </div>
          </div>
          <div style={{ padding:"24px" }}>
            {loading[activeFormat] ? (
              <div style={{ display:"flex", alignItems:"center", gap:"12px", color:C.textDim }}><Spinner /><span style={{ fontSize:"14px" }}>Writing your {OUTPUT_FORMATS.find((f)=>f.id===activeFormat)?.label.toLowerCase()}...</span></div>
            ) : outputs[activeFormat] ? (
              <p className="output-text">{outputs[activeFormat]}</p>
            ) : (
              <div style={{ textAlign:"center", padding:"32px" }}>
                <p style={{ fontSize:"13px", color:C.textDim, marginBottom:"16px" }}>This output hasn't been generated yet.</p>
                <button onClick={() => generateOutput(activeFormat)} style={{ padding:"10px 24px", background:C.orange, border:"none", borderRadius:"8px", color:"#111", fontSize:"13px", fontWeight:600 }}>Generate Now</button>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

// ─── FEEDBACK THREADS PAGE ────────────────────────────────────────────────────
function FeedbackThreadsPage({ setView, setDetailThread }) {
  const [threads, setThreads] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState("all");

  useEffect(() => {
    loadThreads().then((t) => { setThreads(t); setLoading(false); });
  }, []);

  const filtered = filter === "all" ? threads : threads.filter((t) => t.status === filter);

  return (
    <div style={{ minHeight:"100vh", background:C.bg, paddingTop:"72px" }}>
      <div style={{ maxWidth:"900px", margin:"0 auto", padding:"48px 24px 100px" }}>
        <Breadcrumb items={[{ label:"Dashboard", onClick:() => setView("dashboard") }, { label:"Feedback Threads" }]} />
        <div style={{ display:"flex", justifyContent:"space-between", alignItems:"flex-end", marginBottom:"36px" }}>
          <PageHeader eyebrow="Draftora Decode" title="Feedback Threads" subtitle="Every client feedback request — and their responses." />
          <button onClick={() => setView("decode")} style={{ padding:"12px 24px", background:C.orange, border:"none", borderRadius:"8px", color:"#111", fontSize:"13px", fontWeight:600, flexShrink:0, marginLeft:"24px", marginBottom:"40px" }}>
            + New Request
          </button>
        </div>

        {/* Filter Tabs */}
        {threads.length > 0 && (
          <div style={{ display:"flex", gap:"8px", marginBottom:"28px" }}>
            {["all","pending","submitted"].map((f) => (
              <button key={f} onClick={() => setFilter(f)}
                style={{ padding:"10px 18px", borderRadius:"8px", fontSize:"12px", fontWeight:500, border:`1px solid ${filter===f ? C.orange : C.borderHover}`, background: filter===f ? C.orangeDim : "transparent", color: filter===f ? C.orange : C.textMid, transition:"all 0.2s", textTransform:"capitalize" }}>
                {f === "all" ? `All (${threads.length})` : f === "pending" ? `Pending (${threads.filter((t)=>t.status==="pending").length})` : `Responded (${threads.filter((t)=>t.status==="submitted").length})`}
              </button>
            ))}
          </div>
        )}

        {loading ? (
          <div style={{ padding:"80px", textAlign:"center" }}><Spinner size={24} /></div>
        ) : threads.length === 0 ? (
          <EmptyState icon="◎" title="No feedback threads yet" body="After you deliver work to a client, use Draftora Decode to send a structured feedback link. Their responses appear here." cta="Send First Feedback Request" onCta={() => setView("decode")} />
        ) : filtered.length === 0 ? (
          <div style={{ padding:"48px", textAlign:"center" }}><p style={{ color:C.textDim, fontSize:"14px" }}>No threads match this filter.</p></div>
        ) : (
          <div style={{ display:"flex", flexDirection:"column", gap:"12px" }}>
            {filtered.map((t) => (
              <button key={t.id} onClick={() => { setDetailThread(t); setView("thread-detail"); }}
                style={{ padding:"24px 28px", background:C.surface, border:`1px solid ${C.border}`, borderRadius:"12px", textAlign:"left", transition:"all 0.25s", display:"flex", justifyContent:"space-between", alignItems:"center" }}
                onMouseEnter={(e) => { e.currentTarget.style.borderColor = t.status==="submitted" ? "#00C864" : C.orange; e.currentTarget.style.background="rgba(255,77,0,0.02)"; }}
                onMouseLeave={(e) => { e.currentTarget.style.borderColor=C.border; e.currentTarget.style.background=C.surface; }}
              >
                <div style={{ display:"flex", alignItems:"center", gap:"20px" }}>
                  <span style={{ fontSize:"24px", color: t.status==="submitted" ? "#00C864" : C.orange }}>◎</span>
                  <div>
                    <p style={{ fontSize:"15px", fontWeight:600, color:C.text, marginBottom:"4px" }}>{t.meta?.projectName || "Untitled"}</p>
                    <p style={{ fontSize:"12px", color:C.textDim }}>
                      {t.meta?.clientName ? `${t.meta.clientName} · ` : ""}{t.meta?.projectType || "Project"} · {timeAgo(t.createdAt)}
                    </p>
                    {t.status === "submitted" && t.feedback?.impression && (
                      <p style={{ fontSize:"12px", color:C.textDim, marginTop:"6px", fontStyle:"italic" }}>
                        "{t.feedback.impression.slice(0,80)}{t.feedback.impression.length > 80 ? "..." : ""}"
                      </p>
                    )}
                    {t.status === "pending" && (
                      <p style={{ fontSize:"12px", color:"#FFAA00", marginTop:"6px" }}>
                        ⏳ Waiting for client response
                      </p>
                    )}
                  </div>
                </div>
                <div style={{ display:"flex", alignItems:"center", gap:"14px", flexShrink:0 }}>
                  <StatusPill status={t.status} />
                  <span style={{ fontSize:"13px", color:C.textFaint }}>→</span>
                </div>
              </button>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

// ─── THREAD DETAIL ────────────────────────────────────────────────────────────
function ThreadDetail({ thread, setView }) {
  const [analysis, setAnalysis] = useState(thread.analysis || "");
  const [analyzing, setAnalyzing] = useState(false);
  const [copied, setCopied] = useState(false);
  const [shareUrl] = useState(`${window.location.href.split("?")[0]}?feedback=${thread.id}`);
  const [linkCopied, setLinkCopied] = useState(false);

  useEffect(() => {
    if (thread.status === "submitted" && !analysis) {
      runAnalysis();
    }
  }, []);

  const runAnalysis = async () => {
    setAnalyzing(true);
    try {
      const text = await callClaude(buildDecodePrompt(thread.feedback, thread.meta));
      setAnalysis(text);
      await saveThread({ ...thread, analysis:text });
    } catch { setAnalysis("Analysis failed. Please try again."); }
    setAnalyzing(false);
  };

  const handleCopyAnalysis = () => {
    navigator.clipboard.writeText(analysis);
    setCopied(true); setTimeout(() => setCopied(false), 2000);
  };

  const handleCopyLink = () => {
    navigator.clipboard.writeText(shareUrl);
    setLinkCopied(true); setTimeout(() => setLinkCopied(false), 2000);
  };

  return (
    <div style={{ minHeight:"100vh", background:C.bg, paddingTop:"72px" }}>
      <div style={{ maxWidth:"720px", margin:"0 auto", padding:"48px 24px 100px" }}>
        <Breadcrumb items={[{ label:"Dashboard", onClick:() => setView("dashboard") }, { label:"Feedback Threads", onClick:() => setView("threads") }, { label: thread.meta?.projectName || "Thread" }]} />

        {/* Header */}
        <div style={{ display:"flex", justifyContent:"space-between", alignItems:"flex-start", marginBottom:"36px" }}>
          <div>
            <span style={{ fontSize:"11px", color:C.orange, letterSpacing:"2px", textTransform:"uppercase", fontWeight:600 }}>{thread.meta?.projectType}</span>
            <h1 style={{ fontFamily:"'Playfair Display', serif", fontSize:"clamp(22px, 4vw, 32px)", fontWeight:600, color:C.text, marginTop:"8px", marginBottom:"6px", letterSpacing:"-0.4px" }}>
              {thread.meta?.projectName}
            </h1>
            <p style={{ fontSize:"13px", color:C.textDim }}>From {thread.meta?.creativeName} · {timeAgo(thread.createdAt)}</p>
          </div>
          <StatusPill status={thread.status} />
        </div>

        {/* Pending State */}
        {thread.status === "pending" && (
          <div style={{ background:C.surface, border:`1px solid #FFAA00`, borderRadius:"12px", padding:"28px", marginBottom:"32px", animation:"fadeUp 0.4s ease" }}>
            <p style={{ fontSize:"14px", fontWeight:600, color:"#FFAA00", marginBottom:"10px" }}>⏳ Awaiting client response</p>
            <p style={{ fontSize:"13px", color:C.textDim, lineHeight:1.6, marginBottom:"20px" }}>
              Your feedback link is active. Share it with your client if you haven't yet, or wait for them to respond.
            </p>
            <div style={{ display:"flex", gap:"10px", alignItems:"center" }}>
              <input type="text" readOnly value={shareUrl} style={{ flex:1, fontSize:"12px", color:C.textDim, cursor:"text" }} />
              <button onClick={handleCopyLink} style={{ padding:"12px 20px", background: linkCopied ? C.orangeDim : C.orange, border: linkCopied ? `1px solid ${C.orange}` : "none", borderRadius:"8px", color: linkCopied ? C.orange : "#111", fontSize:"13px", fontWeight:600, flexShrink:0, transition:"all 0.2s" }}>
                {linkCopied ? "Copied!" : "Copy Link"}
              </button>
            </div>
          </div>
        )}

        {/* Submitted — Client Responses */}
        {thread.status === "submitted" && thread.feedback && (
          <>
            <div style={{ marginBottom:"40px" }}>
              <p style={{ fontSize:"11px", color:C.textDim, letterSpacing:"2px", textTransform:"uppercase", marginBottom:"20px", fontWeight:600 }}>Client's Responses</p>
              <div style={{ display:"flex", flexDirection:"column", gap:"14px" }}>
                {FEEDBACK_QUESTIONS.map((q) => thread.feedback[q.id] && (
                  <div key={q.id} style={{ background:C.surface, border:`1px solid ${C.border}`, borderRadius:"10px", padding:"20px", animation:"fadeUp 0.4s ease" }}>
                    <p style={{ fontSize:"11px", color:C.textDim, marginBottom:"8px", fontWeight:500, letterSpacing:"0.5px" }}>{q.label}</p>
                    <p style={{ fontSize:"14px", color:C.text, lineHeight:1.75 }}>{thread.feedback[q.id]}</p>
                  </div>
                ))}
              </div>
            </div>

            {/* AI Analysis */}
            <div style={{ background:C.surface, border:`1px solid ${C.border}`, borderRadius:"12px", overflow:"hidden" }}>
              <div style={{ padding:"16px 20px", borderBottom:`1px solid ${C.border}`, display:"flex", justifyContent:"space-between", alignItems:"center" }}>
                <div style={{ display:"flex", alignItems:"center", gap:"8px" }}>
                  <span style={{ fontSize:"14px", color:C.orange }}>◎</span>
                  <span style={{ fontSize:"11px", color:C.orange, letterSpacing:"1.5px", textTransform:"uppercase", fontWeight:600 }}>Draftora Analysis</span>
                </div>
                {analysis && (
                  <div style={{ display:"flex", gap:"8px" }}>
                    <button onClick={handleCopyAnalysis} style={{ padding:"6px 14px", background:"transparent", border:`1px solid ${C.borderHover}`, borderRadius:"6px", color: copied ? C.orange : C.textMid, fontSize:"12px", transition:"color 0.2s" }}>
                      {copied ? "Copied!" : "Copy Brief"}
                    </button>
                    <button onClick={runAnalysis} style={{ padding:"6px 14px", background:"transparent", border:`1px solid ${C.borderHover}`, borderRadius:"6px", color:C.textMid, fontSize:"12px" }}>
                      ↺ Rerun
                    </button>
                  </div>
                )}
              </div>
              <div style={{ padding:"24px" }}>
                {analyzing ? (
                  <div style={{ display:"flex", alignItems:"center", gap:"12px", color:C.textDim }}>
                    <Spinner /><span style={{ fontSize:"14px" }}>Reading your client's feedback...</span>
                  </div>
                ) : analysis ? (
                  <p className="output-text">{analysis}</p>
                ) : (
                  <div style={{ textAlign:"center", padding:"24px" }}>
                    <button onClick={runAnalysis} style={{ padding:"12px 28px", background:C.orange, border:"none", borderRadius:"8px", color:"#111", fontSize:"14px", fontWeight:600 }}>
                      Run Analysis
                    </button>
                  </div>
                )}
              </div>
            </div>
          </>
        )}

        {/* Start new */}
        <div style={{ marginTop:"40px", textAlign:"center" }}>
          <button onClick={() => setView("decode")} style={{ padding:"12px 28px", background:"transparent", border:`1px solid ${C.borderHover}`, borderRadius:"8px", color:C.textDim, fontSize:"13px", transition:"all 0.2s" }}
            onMouseEnter={(e) => { e.currentTarget.style.borderColor=C.orange; e.currentTarget.style.color=C.orange; }}
            onMouseLeave={(e) => { e.currentTarget.style.borderColor=C.borderHover; e.currentTarget.style.color=C.textDim; }}
          >
            + New Feedback Request
          </button>
        </div>
      </div>
    </div>
  );
}

// ─── FORMA CASE TOOL ──────────────────────────────────────────────────────────
function DraftoraCaseTool({ onBack }) {
  const [currentSection, setCurrentSection] = useState(0);
  const [formData, setFormData] = useState({});
  const [activeFormat, setActiveFormat] = useState("casestudy");
  const [outputs, setOutputs] = useState({});
  const [loading, setLoading] = useState({});
  const [showOutput, setShowOutput] = useState(false);
  const [generatingAll, setGeneratingAll] = useState(false);
  const [savedId] = useState(() => generateId());
  const [showUpgrade, setShowUpgrade] = useState(false);
  const [planStatus, setPlanStatus] = useState(null);
  const outputRef = useRef(null);
  const topRef = useRef(null);

  useEffect(() => { checkLimit("caseUsed").then(setPlanStatus); }, []);

  const handleChange = (id, val) => setFormData((p) => ({ ...p, [id]:val }));
  const isValid = () => CASE_SECTIONS[currentSection].fields.filter((f) => !f.hint).every((f) => formData[f.id]?.trim().length > 0);

  const generateOutput = async (format) => {
    setLoading((p) => ({ ...p, [format]:true }));
    try {
      let text = await callClaude(buildCasePrompt(formData, format));
      // Append watermark for free users
      const plan = await loadPlan();
      if ((plan.type || "free") === "free") text += "\n\n—\nMade with Draftora · draftoraapp.com";
      setOutputs((p) => {
        const updated = { ...p, [format]:text };
        saveProject({ id:savedId, formData, outputs:updated, projectName: formData.clientContext, createdAt: Date.now() });
        return updated;
      });
    } catch { setOutputs((p) => ({ ...p, [format]:"Generation failed. Please try again." })); }
    setLoading((p) => ({ ...p, [format]:false }));
  };

  const handleGenerateAll = async () => {
    // Check limit before generating
    const status = await checkLimit("caseUsed");
    if (!status.allowed) { setShowUpgrade(true); return; }
    await incrementUsage("caseUsed");
    setPlanStatus({ ...status, used: status.used + 1 });
    setGeneratingAll(true); setShowOutput(true);
    for (const fmt of OUTPUT_FORMATS) await generateOutput(fmt.id);
    setGeneratingAll(false);
    setTimeout(() => outputRef.current?.scrollIntoView({ behavior:"smooth" }), 100);
  };

  const handleSectionChange = (next) => { setCurrentSection(next); setTimeout(() => topRef.current?.scrollIntoView({ behavior:"smooth", block:"start" }), 50); };
  const confidence = calculateConfidence(formData);

  return (
    <div style={{ minHeight:"100vh", background:C.bg, paddingTop:"72px" }}>
      {showUpgrade && <UpgradeModal reason="case" onClose={() => setShowUpgrade(false)} />}
      <div style={{ maxWidth:"680px", margin:"0 auto", padding:"48px 24px 100px" }} ref={topRef}>
        <Breadcrumb items={[{ label:"Dashboard", onClick:onBack }, { label:"Draftora Case" }]} />

        {/* Free tier usage indicator */}
        {planStatus && planStatus.type === "free" && (
          <div style={{ marginBottom:"28px", padding:"14px 18px", background:C.surface, border:`1px solid ${C.border}`, borderRadius:"10px", display:"flex", justifyContent:"space-between", alignItems:"center" }}>
            <div style={{ display:"flex", alignItems:"center", gap:"10px" }}>
              <div style={{ width:"80px", height:"4px", background:C.borderHover, borderRadius:"2px", overflow:"hidden" }}>
                <div style={{ height:"100%", width:`${Math.min((planStatus.used/planStatus.limit)*100, 100)}%`, background: planStatus.used >= planStatus.limit ? "#FF4444" : C.orange, transition:"width 0.4s" }} />
              </div>
              <span style={{ fontSize:"12px", color: planStatus.used >= planStatus.limit ? "#FF4444" : C.textDim }}>
                {planStatus.used} of {planStatus.limit} free case studies used this month
              </span>
            </div>
            <button onClick={() => setShowUpgrade(true)} style={{ padding:"6px 14px", background:C.orangeDim, border:`1px solid rgba(255,77,0,0.3)`, borderRadius:"6px", color:C.orange, fontSize:"12px", fontWeight:600 }}>
              Upgrade
            </button>
          </div>
        )}
        <div style={{ display:"flex", gap:"6px", marginBottom:"40px" }}>
          {CASE_SECTIONS.map((s,i) => <div key={s.id} style={{ flex:1, height:"3px", borderRadius:"2px", background: i<=currentSection ? C.orange : C.border, transition:"background 0.4s" }} />)}
        </div>
        <div style={{ marginBottom:"40px" }}>
          <p style={{ fontSize:"11px", color:C.orange, letterSpacing:"2.5px", textTransform:"uppercase", marginBottom:"10px", fontWeight:600 }}>{currentSection+1} of {CASE_SECTIONS.length} — {CASE_SECTIONS[currentSection].label}</p>
          <h1 style={{ fontFamily:"'Playfair Display', serif", fontSize:"clamp(22px, 4vw, 34px)", fontWeight:600, lineHeight:1.2, color:C.text, letterSpacing:"-0.3px" }}>{CASE_SECTIONS[currentSection].subtitle}</h1>
        </div>
        <div style={{ display:"flex", flexDirection:"column", gap:"30px", marginBottom:"44px" }}>
          {CASE_SECTIONS[currentSection].fields.map((field) => (
            <div key={field.id}>
              <label style={{ display:"block", fontSize:"13px", fontWeight:500, color:"#C0BAB2", marginBottom: field.hint ? "4px" : "8px" }}>{field.label}</label>
              {field.hint && <p style={{ fontSize:"12px", color:C.textDim, marginBottom:"10px" }}>{field.hint}</p>}
              {field.type==="textarea" ? <textarea rows={4} value={formData[field.id]||""} onChange={(e) => handleChange(field.id, e.target.value)} placeholder={field.placeholder} />
              : field.type==="select" ? (
                <select value={formData[field.id]||""} onChange={(e) => handleChange(field.id, e.target.value)}>
                  <option value="" disabled>{field.placeholder}</option>
                  {field.options.map((opt) => <option key={opt} value={opt}>{opt}</option>)}
                </select>
              ) : <input type="text" value={formData[field.id]||""} onChange={(e) => handleChange(field.id, e.target.value)} placeholder={field.placeholder} />}
            </div>
          ))}
        </div>
        <div style={{ display:"flex", gap:"12px" }}>
          {currentSection>0 && <button onClick={() => handleSectionChange(currentSection-1)} style={{ padding:"14px 24px", background:"transparent", border:`1px solid ${C.borderHover}`, borderRadius:"8px", color:C.textMid, fontSize:"14px" }}>Back</button>}
          {currentSection < CASE_SECTIONS.length-1
            ? <button onClick={() => handleSectionChange(currentSection+1)} disabled={!isValid()} style={{ flex:1, padding:"14px 24px", background: isValid() ? C.orange : C.border, border:"none", borderRadius:"8px", color: isValid() ? "#111" : "#333", fontSize:"14px", fontWeight:600, transition:"all 0.2s" }}>Continue →</button>
            : <button onClick={handleGenerateAll} disabled={generatingAll} style={{ flex:1, padding:"16px 24px", background:C.orange, border:"none", borderRadius:"8px", color:"#111", fontSize:"15px", fontWeight:700, opacity: generatingAll ? 0.7 : 1 }}>{generatingAll ? "Building your case study..." : "Build My Case Study →"}</button>}
        </div>
        {currentSection>=1 && (
          <div style={{ marginTop:"36px", padding:"20px", background:C.surfaceAlt, borderRadius:"12px", border:`1px solid ${C.border}` }}>
            <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center", marginBottom:"10px" }}>
              <span style={{ fontSize:"11px", color:C.textMid, letterSpacing:"1.5px", textTransform:"uppercase" }}>Case Study Strength</span>
              <span style={{ fontSize:"20px", fontWeight:700, color: confidence.score>=70 ? C.orange : confidence.score>=40 ? "#C8803A" : "#444" }}>{confidence.score}%</span>
            </div>
            <div style={{ height:"3px", background:C.borderHover, borderRadius:"2px", marginBottom:"16px" }}>
              <div style={{ height:"100%", width:`${confidence.score}%`, background:C.orange, borderRadius:"2px", transition:"width 0.4s" }} />
            </div>
            {confidence.feedback.length>0 && <div style={{ display:"flex", flexDirection:"column", gap:"8px" }}>{confidence.feedback.map((tip,i) => <p key={i} style={{ fontSize:"12px", color:C.textDim, paddingLeft:"12px", borderLeft:`2px solid ${C.borderHover}` }}>{tip}</p>)}</div>}
          </div>
        )}
        {showOutput && (
          <div ref={outputRef} style={{ marginTop:"64px" }}>
            <div style={{ marginBottom:"28px" }}>
              <p style={{ fontSize:"11px", color:C.orange, letterSpacing:"2px", textTransform:"uppercase", marginBottom:"10px", fontWeight:600 }}>Your Outputs</p>
              <h2 style={{ fontFamily:"'Playfair Display', serif", fontSize:"clamp(20px, 3vw, 28px)", fontWeight:600, color:C.text }}>Your story, four ways.</h2>
            </div>
            <div style={{ display:"flex", gap:"8px", marginBottom:"20px", flexWrap:"wrap" }}>
              {OUTPUT_FORMATS.map((fmt) => (
                <button key={fmt.id} onClick={() => { setActiveFormat(fmt.id); if(!outputs[fmt.id]) generateOutput(fmt.id); }}
                  style={{ padding:"10px 16px", borderRadius:"8px", fontSize:"13px", fontWeight:500, border:`1px solid ${activeFormat===fmt.id ? C.orange : C.borderHover}`, background: activeFormat===fmt.id ? C.orangeDim : "transparent", color: activeFormat===fmt.id ? C.orange : C.textMid, transition:"all 0.2s" }}>
                  {fmt.icon} {fmt.label}
                </button>
              ))}
            </div>
            <div style={{ background:C.surfaceAlt, borderRadius:"12px", border:`1px solid ${C.border}`, overflow:"hidden" }}>
              <div style={{ padding:"14px 20px", borderBottom:`1px solid ${C.border}`, display:"flex", justifyContent:"space-between", alignItems:"center" }}>
                <span style={{ fontSize:"11px", color:C.textDim, letterSpacing:"1.5px", textTransform:"uppercase" }}>{OUTPUT_FORMATS.find((f) => f.id===activeFormat)?.label}</span>
                {outputs[activeFormat] && <button onClick={() => navigator.clipboard.writeText(outputs[activeFormat])} style={{ padding:"6px 14px", background:"transparent", border:`1px solid ${C.borderHover}`, borderRadius:"6px", color:C.textMid, fontSize:"12px" }}>Copy</button>}
              </div>
              <div style={{ padding:"24px" }}>
                {loading[activeFormat] ? <div style={{ display:"flex", alignItems:"center", gap:"12px", color:C.textDim }}><Spinner /><span style={{ fontSize:"14px" }}>Writing your {OUTPUT_FORMATS.find((f)=>f.id===activeFormat)?.label.toLowerCase()}...</span></div>
                : outputs[activeFormat] ? <p className="output-text">{outputs[activeFormat]}</p>
                : <p style={{ color:"#333", fontSize:"14px" }}>Click a format tab to generate this output.</p>}
              </div>
            </div>
            {outputs[activeFormat] && !loading[activeFormat] && <button onClick={() => generateOutput(activeFormat)} style={{ marginTop:"12px", padding:"10px 20px", background:"transparent", border:`1px solid ${C.borderHover}`, borderRadius:"8px", color:C.textDim, fontSize:"13px" }}>↺ Regenerate</button>}
            <div style={{ marginTop:"40px", padding:"24px", background:C.surface, borderRadius:"12px", border:`1px solid ${C.border}`, display:"flex", justifyContent:"space-between", alignItems:"center" }}>
              <div>
                <p style={{ fontSize:"13px", fontWeight:600, color:C.text, marginBottom:"4px" }}>Saved to My Projects</p>
                <p style={{ fontSize:"12px", color:C.textDim }}>View it anytime in your project history.</p>
              </div>
              <div style={{ display:"flex", gap:"10px" }}>
                <button onClick={() => onBack()} style={{ padding:"10px 20px", background:"transparent", border:`1px solid ${C.borderHover}`, borderRadius:"8px", color:C.textDim, fontSize:"13px" }}>Dashboard</button>
                <button onClick={() => { setFormData({}); setOutputs({}); setCurrentSection(0); setShowOutput(false); topRef.current?.scrollIntoView({ behavior:"smooth" }); }} style={{ padding:"10px 20px", background:C.orange, border:"none", borderRadius:"8px", color:"#111", fontSize:"13px", fontWeight:600 }}>New Project</button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

// ─── DRAFTORA DECODE TOOL ─────────────────────────────────────────────────────
function DraftoraDecode({ onBack }) {
  const [step, setStep] = useState("setup");
  const [meta, setMeta] = useState({ creativeName:"", projectName:"", projectType:"", note:"" });
  const [linkId, setLinkId] = useState(null);
  const [copied, setCopied] = useState(false);
  const [feedback, setFeedback] = useState(null);
  const [analysis, setAnalysis] = useState("");
  const [analyzing, setAnalyzing] = useState(false);
  const [showUpgrade, setShowUpgrade] = useState(false);
  const [polling, setPolling] = useState(false);
  const topRef = useRef(null);
  const isSetupValid = meta.creativeName.trim() && meta.projectName.trim() && meta.projectType.trim();

  const handleCreateLink = async () => {
    // Check active decode link limit
    const status = await checkLimit("decodeUsed");
    if (!status.allowed) { setShowUpgrade(true); return; }
    await incrementUsage("decodeUsed");
    const id = generateId();
    const thread = { id, meta, status:"pending", createdAt:Date.now() };
    try { await saveThread(thread); setLinkId(id); setStep("waiting"); topRef.current?.scrollIntoView({ behavior:"smooth" }); }
    catch { alert("Storage error — please try again."); }
  };

  const checkForResponse = async () => {
    if (!linkId) return;
    setPolling(true);
    try {
      const result = await window.storage.get(`decode:${linkId}`, true);
      if (result) {
        const record = JSON.parse(result.value);
        if (record.status==="submitted" && record.feedback) { setFeedback(record.feedback); setStep("results"); runAnalysis(record.feedback, record.meta||meta); }
      }
    } catch {}
    setPolling(false);
  };

  const runAnalysis = async (fb, m) => {
    setAnalyzing(true);
    try { setAnalysis(await callClaude(buildDecodePrompt(fb, m))); }
    catch { setAnalysis("Analysis failed. Please try again."); }
    setAnalyzing(false);
  };

  const shareUrl = linkId ? `${window.location.href.split("?")[0]}?feedback=${linkId}` : "";
  const handleCopy = () => { navigator.clipboard.writeText(shareUrl); setCopied(true); setTimeout(() => setCopied(false), 2000); };

  return (
    <div style={{ minHeight:"100vh", background:C.bg, paddingTop:"72px" }}>
      {showUpgrade && <UpgradeModal reason="decode" onClose={() => setShowUpgrade(false)} />}
      <div style={{ maxWidth:"680px", margin:"0 auto", padding:"48px 24px 100px" }} ref={topRef}>
        <Breadcrumb items={[{ label:"Dashboard", onClick:onBack }, { label:"Draftora Decode" }]} />

        {step==="setup" && (
          <div style={{ animation:"fadeUp 0.4s ease" }}>
            <PageHeader eyebrow="Draftora Decode" title={"Get clear feedback.\nBefore revisions begin."} subtitle="Fill in your project details. We'll generate a focused feedback link to send your client — they answer six structured questions, you get a clear brief for the next round." />
            <div style={{ display:"flex", flexDirection:"column", gap:"28px", marginBottom:"40px" }}>
              {[
                { id:"creativeName", label:"Your name or studio name", placeholder:"e.g. Shotblac Studio or Bobby Dimas", hint:"This is how you'll appear to your client" },
                { id:"projectName", label:"Project name", placeholder:"e.g. Vestra Brand Identity, Campaign Visuals" },
                { id:"projectType", label:"Project type", placeholder:"e.g. Brand Identity, UI Design, Video Production" },
                { id:"note", label:"Personal note to your client", placeholder:"e.g. Hey — would love your honest thoughts on the direction. No filter needed.", hint:"Optional — shown at the top of their form" },
              ].map((field) => (
                <div key={field.id}>
                  <label style={{ display:"block", fontSize:"13px", fontWeight:500, color:"#C0BAB2", marginBottom: field.hint ? "4px" : "8px" }}>{field.label}</label>
                  {field.hint && <p style={{ fontSize:"12px", color:C.textDim, marginBottom:"10px" }}>{field.hint}</p>}
                  <input type="text" value={meta[field.id]||""} onChange={(e) => setMeta((p) => ({ ...p, [field.id]:e.target.value }))} placeholder={field.placeholder} />
                </div>
              ))}
            </div>
            <button onClick={handleCreateLink} disabled={!isSetupValid} style={{ width:"100%", padding:"16px", background: isSetupValid ? C.orange : C.border, border:"none", borderRadius:"8px", color: isSetupValid ? "#111" : "#333", fontSize:"15px", fontWeight:700, transition:"all 0.2s" }}>
              Generate Feedback Link →
            </button>
          </div>
        )}

        {step==="waiting" && (
          <div style={{ animation:"fadeUp 0.4s ease" }}>
            <PageHeader eyebrow="Link Ready" title="Send this to your client." subtitle="They'll see a clean, focused form — six structured questions. Once they submit, come back here and check for their response." />
            <div style={{ background:C.surface, border:`1px solid ${C.border}`, borderRadius:"12px", padding:"24px", marginBottom:"28px" }}>
              <p style={{ fontSize:"11px", color:C.textDim, letterSpacing:"1.5px", textTransform:"uppercase", marginBottom:"12px" }}>Shareable Link</p>
              <div style={{ display:"flex", gap:"10px", alignItems:"center" }}>
                <input type="text" readOnly value={shareUrl} style={{ flex:1, fontSize:"12px", color:C.textDim, cursor:"text" }} />
                <button onClick={handleCopy} style={{ padding:"14px 20px", background: copied ? C.orangeDim : C.orange, border: copied ? `1px solid ${C.orange}` : "none", borderRadius:"8px", color: copied ? C.orange : "#111", fontSize:"13px", fontWeight:600, flexShrink:0, transition:"all 0.2s" }}>
                  {copied ? "Copied!" : "Copy Link"}
                </button>
              </div>
            </div>
            <div style={{ background:C.surfaceAlt, border:`1px solid ${C.border}`, borderRadius:"10px", padding:"16px 20px", marginBottom:"28px" }}>
              <p style={{ fontSize:"13px", fontWeight:600, color:C.text, marginBottom:"4px" }}>{meta.projectName}</p>
              <p style={{ fontSize:"12px", color:C.textDim }}>{meta.projectType} · From {meta.creativeName}</p>
            </div>
            <button onClick={checkForResponse} disabled={polling} style={{ width:"100%", padding:"14px", background:C.orange, border:"none", borderRadius:"8px", color:"#111", fontSize:"14px", fontWeight:600, display:"flex", alignItems:"center", justifyContent:"center", gap:"10px", opacity: polling ? 0.7 : 1 }}>
              {polling ? <><Spinner /> Checking...</> : "Check for Client Response"}
            </button>
            <p style={{ fontSize:"12px", color:C.textDim, textAlign:"center", marginTop:"12px" }}>Come back and click this once your client has filled in the form.</p>
            <button onClick={() => { setStep("setup"); setLinkId(null); }} style={{ width:"100%", marginTop:"12px", padding:"12px", background:"transparent", border:`1px solid ${C.borderHover}`, borderRadius:"8px", color:C.textDim, fontSize:"13px" }}>← Start over</button>
          </div>
        )}

        {step==="results" && feedback && (
          <div style={{ animation:"fadeUp 0.4s ease" }}>
            <PageHeader eyebrow="Feedback Received" title="Your client responded." subtitle="Here's what they said — and what it means for your next round." />
            <div style={{ marginBottom:"36px" }}>
              <p style={{ fontSize:"11px", color:C.textDim, letterSpacing:"2px", textTransform:"uppercase", marginBottom:"16px", fontWeight:600 }}>Client's Responses</p>
              <div style={{ display:"flex", flexDirection:"column", gap:"12px" }}>
                {FEEDBACK_QUESTIONS.map((q) => feedback[q.id] && (
                  <div key={q.id} style={{ background:C.surfaceAlt, border:`1px solid ${C.border}`, borderRadius:"10px", padding:"20px" }}>
                    <p style={{ fontSize:"11px", color:C.textDim, marginBottom:"8px", fontWeight:500 }}>{q.label}</p>
                    <p style={{ fontSize:"14px", color:C.text, lineHeight:1.75 }}>{feedback[q.id]}</p>
                  </div>
                ))}
              </div>
            </div>
            <div style={{ background:C.surface, border:`1px solid ${C.border}`, borderRadius:"12px", overflow:"hidden", marginBottom:"24px" }}>
              <div style={{ padding:"16px 20px", borderBottom:`1px solid ${C.border}`, display:"flex", justifyContent:"space-between", alignItems:"center" }}>
                <span style={{ fontSize:"11px", color:C.orange, letterSpacing:"1.5px", textTransform:"uppercase", fontWeight:600 }}>◎ Draftora Analysis</span>
                {analysis && <button onClick={() => navigator.clipboard.writeText(analysis)} style={{ padding:"6px 14px", background:"transparent", border:`1px solid ${C.borderHover}`, borderRadius:"6px", color:C.textMid, fontSize:"12px" }}>Copy Brief</button>}
              </div>
              <div style={{ padding:"24px" }}>
                {analyzing ? <div style={{ display:"flex", alignItems:"center", gap:"12px", color:C.textDim }}><Spinner /><span style={{ fontSize:"14px" }}>Reading your client's feedback...</span></div>
                : analysis ? <p className="output-text">{analysis}</p>
                : null}
              </div>
            </div>
            <button onClick={() => { setStep("setup"); setMeta({ creativeName:"", projectName:"", projectType:"", note:"" }); setLinkId(null); setFeedback(null); setAnalysis(""); }} style={{ width:"100%", padding:"14px", background:C.orange, border:"none", borderRadius:"8px", color:"#111", fontSize:"14px", fontWeight:600 }}>
              Start a New Feedback Request
            </button>
          </div>
        )}
      </div>
    </div>
  );
}

// ─── CLIENT FEEDBACK FORM ─────────────────────────────────────────────────────
function ClientFeedbackForm({ feedbackId }) {
  const [record, setRecord] = useState(null);
  const [loading, setLoading] = useState(true);
  const [answers, setAnswers] = useState({});
  const [submitted, setSubmitted] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState(null);
  const [currentQ, setCurrentQ] = useState(0);

  useEffect(() => {
    (async () => {
      try {
        const result = await window.storage.get(`decode:${feedbackId}`, true);
        if (result) { const rec = JSON.parse(result.value); if (rec.status==="submitted") setSubmitted(true); else setRecord(rec); }
        else setError("This feedback link is no longer active.");
      } catch { setError("Unable to load this feedback form."); }
      setLoading(false);
    })();
  }, [feedbackId]);

  const handleSubmit = async () => {
    setSubmitting(true);
    try { await window.storage.set(`decode:${feedbackId}`, JSON.stringify({ ...record, status:"submitted", feedback:answers, submittedAt:Date.now() }), true); setSubmitted(true); }
    catch { setError("Submission failed. Please try again."); }
    setSubmitting(false);
  };

  const isLastQ = currentQ === FEEDBACK_QUESTIONS.length-1;
  const currentAnswer = answers[FEEDBACK_QUESTIONS[currentQ]?.id] || "";

  if (loading) return <div style={{ minHeight:"100vh", background:C.bg, display:"flex", alignItems:"center", justifyContent:"center" }}><Spinner size={24} /></div>;
  if (error) return <div style={{ minHeight:"100vh", background:C.bg, display:"flex", alignItems:"center", justifyContent:"center", padding:"24px" }}><div style={{ textAlign:"center", maxWidth:"400px" }}><p style={{ fontSize:"32px", marginBottom:"16px" }}>◎</p><p style={{ fontFamily:"'Playfair Display', serif", fontSize:"22px", color:C.text, marginBottom:"12px" }}>Link unavailable</p><p style={{ fontSize:"14px", color:C.textDim }}>{error}</p></div></div>;
  if (submitted) return (
    <div style={{ minHeight:"100vh", background:C.bg, display:"flex", alignItems:"center", justifyContent:"center", padding:"24px" }}>
      <div style={{ textAlign:"center", maxWidth:"440px", animation:"fadeUp 0.5s ease" }}>
        <div style={{ width:"56px", height:"56px", borderRadius:"50%", background:C.orangeDim, border:`1px solid ${C.orange}`, display:"flex", alignItems:"center", justifyContent:"center", margin:"0 auto 24px", fontSize:"22px" }}>✓</div>
        <h1 style={{ fontFamily:"'Playfair Display', serif", fontSize:"clamp(24px, 4vw, 34px)", fontWeight:600, color:C.text, marginBottom:"16px", letterSpacing:"-0.5px" }}>Thank you.</h1>
        <p style={{ fontSize:"15px", color:C.textDim, lineHeight:1.7 }}>Your feedback has been sent. {record?.meta?.creativeName||"The creative"} will review it and be in touch.</p>
      </div>
    </div>
  );

  return (
    <div style={{ minHeight:"100vh", background:C.bg, color:C.text, fontFamily:"'Inter', sans-serif" }}>
      <style>{GLOBAL_STYLES}</style>
      <div style={{ maxWidth:"600px", margin:"0 auto", padding:"60px 24px 100px" }}>
        <div style={{ marginBottom:"56px" }}>
          {record?.meta?.note && <div style={{ background:C.surfaceAlt, border:`1px solid ${C.border}`, borderRadius:"10px", padding:"16px 20px", marginBottom:"28px" }}><p style={{ fontSize:"13px", color:C.textMid, lineHeight:1.7, fontStyle:"italic" }}>"{record.meta.note}"</p><p style={{ fontSize:"12px", color:C.textDim, marginTop:"8px" }}>— {record?.meta?.creativeName}</p></div>}
          <p style={{ fontSize:"11px", color:C.orange, letterSpacing:"2.5px", textTransform:"uppercase", fontWeight:600, marginBottom:"12px" }}>Feedback Request</p>
          <h1 style={{ fontFamily:"'Playfair Display', serif", fontSize:"clamp(24px, 4vw, 38px)", fontWeight:600, color:C.text, lineHeight:1.2, letterSpacing:"-0.5px", marginBottom:"10px" }}>{record?.meta?.projectName}</h1>
          <p style={{ fontSize:"14px", color:C.textDim }}>From {record?.meta?.creativeName} · {record?.meta?.projectType}</p>
        </div>
        <div style={{ display:"flex", gap:"4px", marginBottom:"40px" }}>
          {FEEDBACK_QUESTIONS.map((_,i) => <div key={i} style={{ flex:1, height:"3px", borderRadius:"2px", background: i<=currentQ ? C.orange : C.border, transition:"background 0.3s" }} />)}
        </div>
        <div key={currentQ} style={{ animation:"fadeUp 0.35s ease" }}>
          <p style={{ fontSize:"11px", color:C.textDim, letterSpacing:"2px", textTransform:"uppercase", marginBottom:"14px" }}>Question {currentQ+1} of {FEEDBACK_QUESTIONS.length}</p>
          <label style={{ display:"block", fontFamily:"'Playfair Display', serif", fontSize:"clamp(18px, 3vw, 24px)", fontWeight:600, color:C.text, lineHeight:1.3, marginBottom:"24px", letterSpacing:"-0.2px" }}>{FEEDBACK_QUESTIONS[currentQ].label}</label>
          {FEEDBACK_QUESTIONS[currentQ].type==="textarea"
            ? <textarea rows={5} value={currentAnswer} onChange={(e) => setAnswers((p) => ({ ...p, [FEEDBACK_QUESTIONS[currentQ].id]:e.target.value }))} placeholder={FEEDBACK_QUESTIONS[currentQ].placeholder} style={{ fontSize:"15px" }} autoFocus />
            : <input type="text" value={currentAnswer} onChange={(e) => setAnswers((p) => ({ ...p, [FEEDBACK_QUESTIONS[currentQ].id]:e.target.value }))} placeholder={FEEDBACK_QUESTIONS[currentQ].placeholder} style={{ fontSize:"15px" }} autoFocus />}
        </div>
        <div style={{ display:"flex", gap:"12px", marginTop:"28px" }}>
          {currentQ>0 && <button onClick={() => setCurrentQ((p) => p-1)} style={{ padding:"14px 24px", background:"transparent", border:`1px solid ${C.borderHover}`, borderRadius:"8px", color:C.textMid, fontSize:"14px" }}>Back</button>}
          {!isLastQ
            ? <button onClick={() => setCurrentQ((p) => p+1)} style={{ flex:1, padding:"14px 24px", background: currentAnswer.trim() ? C.orange : C.border, border:"none", borderRadius:"8px", color: currentAnswer.trim() ? "#111" : "#333", fontSize:"14px", fontWeight:600, transition:"all 0.2s" }}>Next →</button>
            : <button onClick={handleSubmit} disabled={submitting} style={{ flex:1, padding:"14px 24px", background:C.orange, border:"none", borderRadius:"8px", color:"#111", fontSize:"14px", fontWeight:700, opacity: submitting ? 0.7 : 1, display:"flex", alignItems:"center", justifyContent:"center", gap:"10px" }}>
                {submitting ? <><Spinner />Submitting...</> : "Submit Feedback →"}
              </button>}
        </div>
        {isLastQ && !currentAnswer.trim() && <p style={{ fontSize:"12px", color:C.textDim, textAlign:"center", marginTop:"12px" }}>This question is optional — you can skip and submit.</p>}
      </div>
    </div>
  );
}

// ─── LANDING PAGE ─────────────────────────────────────────────────────────────
function LandingPage({ onLaunchTool }) {
  const [heroStarted, setHeroStarted] = useState(false);
  const [subVisible, setSubVisible] = useState(false);
  const [ctaVisible, setCtaVisible] = useState(false);
  const { words:heroWords, revealed } = useWordReveal("Structure your creative.", heroStarted, 120);
  const [howRef, howVisible] = useIntersect(0.15);
  const [statsRef, statsVisible] = useIntersect(0.15);

  useEffect(() => {
    const t1 = setTimeout(() => setHeroStarted(true), 300);
    const t2 = setTimeout(() => setSubVisible(true), 1700);
    const t3 = setTimeout(() => setCtaVisible(true), 2200);
    return () => { clearTimeout(t1); clearTimeout(t2); clearTimeout(t3); };
  }, []);

  return (
    <div>
      <section style={{ minHeight:"100vh", display:"flex", flexDirection:"column", justifyContent:"center", padding:"120px 48px 80px", maxWidth:"1100px", margin:"0 auto", position:"relative" }}>
        <div style={{ position:"absolute", top:"25%", left:"-8%", width:"500px", height:"500px", borderRadius:"50%", background:`radial-gradient(circle, ${C.orangeGlow} 0%, transparent 70%)`, pointerEvents:"none" }} />
        <p style={{ fontSize:"11px", color:C.orange, letterSpacing:"3px", fontWeight:600, marginBottom:"28px", textTransform:"uppercase" }}>Tools for creative professionals</p>
        <h1 style={{ fontFamily:"'Playfair Display', serif", fontSize:"clamp(48px, 8vw, 96px)", fontWeight:700, lineHeight:1.05, letterSpacing:"-2px", marginBottom:"32px", maxWidth:"820px" }}>
          {heroWords.map((word,i) => (
            <span key={i} style={{ display:"inline-block", marginRight:"0.25em", color: word==="creative." ? C.orange : C.text, opacity: i<revealed ? 1 : 0, transform: i<revealed ? "translateY(0)" : "translateY(20px)", transition:"opacity 0.4s ease, transform 0.4s ease" }}>{word}</span>
          ))}
        </h1>
        <p style={{ fontSize:"clamp(15px, 1.8vw, 19px)", color:C.textDim, lineHeight:1.75, maxWidth:"500px", marginBottom:"48px", fontWeight:300, opacity: subVisible ? 1 : 0, transform: subVisible ? "translateY(0)" : "translateY(16px)", transition:"all 0.6s ease" }}>
          Draftora is a suite of AI tools built for creatives — to sharpen the work, articulate it clearly, and grow from every project.
        </p>
        <div style={{ display:"flex", gap:"16px", alignItems:"center", flexWrap:"wrap", opacity: ctaVisible ? 1 : 0, transform: ctaVisible ? "translateY(0)" : "translateY(16px)", transition:"all 0.6s ease" }}>
          <button onClick={() => onLaunchTool("case")} style={{ padding:"16px 32px", background:C.orange, border:"none", borderRadius:"10px", color:"#111", fontSize:"15px", fontWeight:700 }}
            onMouseEnter={(e) => e.currentTarget.style.opacity="0.88"}
            onMouseLeave={(e) => e.currentTarget.style.opacity="1"}>Try Draftora Case — It's Free</button>
          <a href="#tools" style={{ padding:"16px 24px", background:"transparent", border:`1px solid ${C.borderHover}`, borderRadius:"10px", color:C.textMid, fontSize:"14px", display:"inline-block", transition:"all 0.2s" }}
            onMouseEnter={(e) => { e.currentTarget.style.borderColor=C.orange; e.currentTarget.style.color=C.orange; }}
            onMouseLeave={(e) => { e.currentTarget.style.borderColor=C.borderHover; e.currentTarget.style.color=C.textMid; }}>See all tools ↓</a>
        </div>
        <div style={{ position:"absolute", bottom:"48px", left:"48px", display:"flex", alignItems:"center", gap:"10px", opacity: ctaVisible ? 0.35 : 0, transition:"opacity 0.6s ease 0.4s" }}>
          <div style={{ width:"1px", height:"40px", background:C.textFaint }} />
          <span style={{ fontSize:"10px", color:C.textDim, letterSpacing:"2.5px", textTransform:"uppercase" }}>Scroll</span>
        </div>
      </section>

      <section style={{ padding:"80px 48px 100px", maxWidth:"860px", margin:"0 auto" }}>
        {MANIFESTO.map((line,i) => {
          const [ref, visible] = [useRef(null), useState(false)];
          useEffect(() => {
            const obs = new IntersectionObserver(([e]) => { if(e.isIntersecting) visible[1](true); }, { threshold:0.3 });
            if(ref.current) obs.observe(ref.current); return () => obs.disconnect();
          }, []);
          const isAccent = i===0||i===1;
          return (
            <p key={i} ref={ref} style={{ fontFamily: isAccent ? "'Playfair Display', serif" : "'Inter', sans-serif", fontSize: isAccent ? "clamp(26px, 4vw, 42px)" : "clamp(15px, 2.2vw, 21px)", fontWeight: isAccent ? 600 : 300, color: isAccent ? C.text : C.textDim, lineHeight:1.3, marginBottom: isAccent ? "8px" : "4px", transform: visible[0] ? "translateX(0)" : "translateX(-24px)", opacity: visible[0] ? 1 : 0, transition:`all 0.5s ease ${i*80}ms` }}>{line}</p>
          );
        })}
        <div style={{ marginTop:"32px", display:"flex", alignItems:"center", gap:"12px" }}>
          <div style={{ width:"32px", height:"2px", background:C.orange }} />
          <span style={{ fontSize:"11px", color:C.orange, letterSpacing:"2px", textTransform:"uppercase", fontWeight:600 }}>That's what Draftora is for</span>
        </div>
      </section>

      <section id="tools" style={{ padding:"80px 48px 100px", maxWidth:"1100px", margin:"0 auto" }}>
        <div style={{ marginBottom:"56px" }}>
          <p style={{ fontSize:"11px", color:C.orange, letterSpacing:"3px", fontWeight:600, marginBottom:"14px", textTransform:"uppercase" }}>The Suite</p>
          <h2 style={{ fontFamily:"'Playfair Display', serif", fontSize:"clamp(28px, 4vw, 48px)", fontWeight:600, letterSpacing:"-1px", color:C.text, maxWidth:"480px", lineHeight:1.15 }}>Three tools.<br />One creative language.</h2>
        </div>
        <div style={{ display:"grid", gridTemplateColumns:"repeat(auto-fit, minmax(300px, 1fr))", gap:"20px" }}>
          {TOOLS_DATA.map((tool,i) => {
            const [hovered, setHovered] = useState(false);
            const isLive = tool.status==="Live";
            return (
              <div key={tool.id} onMouseEnter={() => setHovered(true)} onMouseLeave={() => setHovered(false)}
                onClick={() => isLive && onLaunchTool(tool.id)}
                style={{ padding:"40px", border:`1px solid ${hovered&&isLive ? C.orange : C.border}`, borderRadius:"16px", background: hovered&&isLive ? "rgba(255,77,0,0.03)" : C.surface, transition:"all 0.35s ease", cursor: isLive ? "pointer" : "default", position:"relative", overflow:"hidden" }}>
                <div style={{ display:"flex", justifyContent:"space-between", alignItems:"flex-start", marginBottom:"28px" }}>
                  <div style={{ display:"flex", alignItems:"center", gap:"12px" }}>
                    <span style={{ fontSize:"20px", color:C.orange }}>{tool.icon}</span>
                    <span style={{ fontSize:"11px", color:C.orange, letterSpacing:"2px", fontWeight:600 }}>{tool.tag}</span>
                  </div>
                  <StatusPill status={isLive ? "live" : "coming-soon"} />
                </div>
                <h3 style={{ fontFamily:"'Playfair Display', serif", fontSize:"clamp(19px, 2.5vw, 25px)", fontWeight:600, color:C.text, marginBottom:"14px", letterSpacing:"-0.3px" }}>{tool.name}</h3>
                <p style={{ fontSize:"14px", color:C.textMid, lineHeight:1.75, marginBottom:"20px" }}>{tool.description}</p>
                <div style={{ paddingTop:"20px", borderTop:`1px solid ${C.border}`, display:"flex", justifyContent:"space-between", alignItems:"center" }}>
                  <p style={{ fontSize:"12px", color:C.textFaint, fontStyle:"italic", flex:1, lineHeight:1.6 }}>{tool.detail}</p>
                  {isLive && <span style={{ fontSize:"12px", color:C.orange, marginLeft:"16px", opacity: hovered ? 1 : 0, transition:"opacity 0.2s" }}>Open →</span>}
                </div>
                <div style={{ position:"absolute", bottom:0, left:0, height:"2px", width: hovered&&isLive ? "100%" : "0%", background:C.orange, transition:"width 0.4s ease" }} />
              </div>
            );
          })}
        </div>
      </section>

      <section id="how-it-works" style={{ padding:"80px 48px 100px", borderTop:`1px solid ${C.border}` }}>
        <div style={{ maxWidth:"1100px", margin:"0 auto" }}>
          <div style={{ marginBottom:"60px" }}>
            <p style={{ fontSize:"11px", color:C.orange, letterSpacing:"3px", fontWeight:600, marginBottom:"14px", textTransform:"uppercase" }}>How it works</p>
            <h2 style={{ fontFamily:"'Playfair Display', serif", fontSize:"clamp(28px, 4vw, 48px)", fontWeight:600, letterSpacing:"-1px", color:C.text, lineHeight:1.15 }}>Simple enough to use<br />after every project.</h2>
          </div>
          <div ref={howRef} style={{ display:"grid", gridTemplateColumns:"repeat(auto-fit, minmax(220px, 1fr))" }}>
            {[{ step:"01", title:"Pick your tool", body:"Choose what you need — critique, case study, or feedback decoding." },{ step:"02", title:"Give it context", body:"Answer structured questions about your project, process, and outcome." },{ step:"03", title:"Get your output", body:"Draftora generates what you need — ready to use, send, or publish." },{ step:"04", title:"Keep building", body:"Every tool is designed to be used again. After every project. After every client." }].map((item,i) => (
              <div key={i} style={{ padding:"40px 32px", borderLeft: i===0 ? `1px solid ${C.border}` : "none", borderRight:`1px solid ${C.border}`, borderTop:`1px solid ${C.border}`, borderBottom:`1px solid ${C.border}`, transform: howVisible ? "translateY(0)" : "translateY(24px)", opacity: howVisible ? 1 : 0, transition:`all 0.5s ease ${i*100}ms` }}>
                <span style={{ fontFamily:"'Playfair Display', serif", fontSize:"48px", fontWeight:700, color:"#1E1E1E", display:"block", marginBottom:"20px", lineHeight:1 }}>{item.step}</span>
                <h4 style={{ fontSize:"15px", fontWeight:600, color:C.text, marginBottom:"10px" }}>{item.title}</h4>
                <p style={{ fontSize:"13px", color:C.textDim, lineHeight:1.7 }}>{item.body}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section id="for-who" style={{ padding:"80px 48px 100px", maxWidth:"1100px", margin:"0 auto" }}>
        <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr", gap:"80px", alignItems:"center" }}>
          <div>
            <p style={{ fontSize:"11px", color:C.orange, letterSpacing:"3px", fontWeight:600, marginBottom:"14px", textTransform:"uppercase" }}>For who</p>
            <h2 style={{ fontFamily:"'Playfair Display', serif", fontSize:"clamp(26px, 3.5vw, 40px)", fontWeight:600, color:C.text, lineHeight:1.2, letterSpacing:"-0.8px" }}>Built for the creative who takes their work seriously.</h2>
          </div>
          <div ref={statsRef} style={{ display:"flex", flexDirection:"column" }}>
            {[{ who:"Freelance Creatives", desc:"Win better clients. Communicate your value. Protect your process." },{ who:"Design Students", desc:"Build confidence before you have a body of work that speaks for itself." },{ who:"Startup Creatives", desc:"Move fast without losing the quality of your thinking or your story." },{ who:"Brand Designers", desc:"Document client work with the depth it deserves — for pitches and portfolios alike." }].map((item,i) => (
              <div key={i} style={{ padding:"22px 0", borderBottom:`1px solid ${C.border}`, transform: statsVisible ? "translateX(0)" : "translateX(20px)", opacity: statsVisible ? 1 : 0, transition:`all 0.5s ease ${i*100}ms` }}>
                <div style={{ display:"flex", alignItems:"flex-start", gap:"14px" }}>
                  <div style={{ width:"5px", height:"5px", borderRadius:"50%", background:C.orange, marginTop:"8px", flexShrink:0 }} />
                  <div>
                    <p style={{ fontSize:"14px", fontWeight:600, color:C.text, marginBottom:"4px" }}>{item.who}</p>
                    <p style={{ fontSize:"13px", color:C.textDim, lineHeight:1.6 }}>{item.desc}</p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section style={{ padding:"100px 48px", borderTop:`1px solid ${C.border}`, textAlign:"center", position:"relative", overflow:"hidden" }}>
        <div style={{ position:"absolute", top:"50%", left:"50%", transform:"translate(-50%,-50%)", width:"700px", height:"700px", borderRadius:"50%", background:`radial-gradient(circle, ${C.orangeGlow} 0%, transparent 70%)`, pointerEvents:"none" }} />
        <p style={{ fontSize:"11px", color:C.orange, letterSpacing:"3px", fontWeight:600, marginBottom:"24px", textTransform:"uppercase" }}>Start now</p>
        <h2 style={{ fontFamily:"'Playfair Display', serif", fontSize:"clamp(36px, 6vw, 72px)", fontWeight:700, color:C.text, lineHeight:1.1, letterSpacing:"-2px", marginBottom:"24px" }}>Your work deserves<br /><span style={{ color:C.orange, fontStyle:"italic" }}>better words.</span></h2>
        <p style={{ fontSize:"16px", color:C.textDim, marginBottom:"48px", fontWeight:300 }}>Start with Draftora Case. Free. No account needed.</p>
        <button onClick={() => onLaunchTool("case")} style={{ padding:"18px 48px", background:C.orange, border:"none", borderRadius:"12px", color:"#111", fontSize:"16px", fontWeight:700 }}
          onMouseEnter={(e) => e.currentTarget.style.opacity="0.88"}
          onMouseLeave={(e) => e.currentTarget.style.opacity="1"}>Build Your First Case Study →</button>
      </section>

      <footer style={{ padding:"32px 48px", borderTop:`1px solid ${C.border}`, display:"flex", justifyContent:"space-between", alignItems:"center" }}>
        <span style={{ fontFamily:"'Playfair Display', serif", fontSize:"18px", fontWeight:700, color:C.text }}>Draft<span style={{ color:C.orange }}>ora</span></span>
        <p style={{ fontSize:"12px", color:C.textFaint }}>Structure your creative.</p>
        <p style={{ fontSize:"12px", color:"#222" }}>© 2025 Draftora</p>
      </footer>
    </div>
  );
}

// ─── ROOT APP ─────────────────────────────────────────────────────────────────
export default function DraftoraApp() {
  const [view, setView] = useState("landing");
  const [scrolled, setScrolled] = useState(false);
  const [feedbackId, setFeedbackId] = useState(null);
  const [detailProject, setDetailProject] = useState(null);
  const [detailThread, setDetailThread] = useState(null);
  const [userProfile, setUserProfile] = useState(null);
  const [showOnboarding, setShowOnboarding] = useState(false);
  const [profileLoaded, setProfileLoaded] = useState(false);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const id = params.get("feedback");
    if (id) { setFeedbackId(id); setView("client-feedback"); setProfileLoaded(true); return; }
    // Load profile to decide if onboarding needed
    loadUserProfile().then((profile) => {
      setUserProfile(profile);
      setProfileLoaded(true);
    });
  }, []);

  useEffect(() => {
    const handleScroll = () => setScrolled(window.scrollY > 60);
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  useEffect(() => {
    if (view !== "client-feedback") window.scrollTo({ top:0, behavior:"smooth" });
  }, [view]);

  const handleSetView = (v) => { setView(v); };

  const handleGetStarted = () => {
    if (!userProfile) { setShowOnboarding(true); }
    else { setView("dashboard"); }
  };

  const handleOnboardingComplete = (profile, firstAction) => {
    setUserProfile(profile);
    setShowOnboarding(false);
    setView(firstAction || "dashboard");
  };

  if (!profileLoaded) return (
    <div style={{ minHeight:"100vh", background:C.bg, display:"flex", alignItems:"center", justifyContent:"center" }}>
      <style>{GLOBAL_STYLES}</style>
      <Spinner size={24} />
    </div>
  );

  if (view === "client-feedback" && feedbackId) return <><style>{GLOBAL_STYLES}</style><ClientFeedbackForm feedbackId={feedbackId} /></>;

  if (showOnboarding) return <><style>{GLOBAL_STYLES}</style><Onboarding onComplete={handleOnboardingComplete} /></>;

  return (
    <div style={{ minHeight:"100vh", background:C.bg, color:C.text, fontFamily:"'Inter', sans-serif", overflowX:"hidden" }}>
      <style>{GLOBAL_STYLES}</style>
      <Nav view={view} setView={handleSetView} scrolled={scrolled} onGetStarted={handleGetStarted} />
      {view === "landing"         && <LandingPage onLaunchTool={(v) => { if(v==="dashboard") handleGetStarted(); else { handleGetStarted(); setTimeout(()=>handleSetView(v),50); } }} onGetStarted={handleGetStarted} />}
      {view === "dashboard"       && <Dashboard setView={handleSetView} setDetailProject={setDetailProject} setDetailThread={setDetailThread} userName={userProfile?.name} />}
      {view === "case"            && <DraftoraCaseTool onBack={() => handleSetView("dashboard")} />}
      {view === "decode"          && <DraftoraDecode onBack={() => handleSetView("dashboard")} />}
      {view === "projects"        && <MyProjectsPage setView={handleSetView} setDetailProject={setDetailProject} />}
      {view === "project-detail"  && detailProject && <ProjectDetail project={detailProject} setView={handleSetView} />}
      {view === "threads"         && <FeedbackThreadsPage setView={handleSetView} setDetailThread={setDetailThread} />}
      {view === "thread-detail"   && detailThread && <ThreadDetail thread={detailThread} setView={handleSetView} />}
    </div>
  );
}
