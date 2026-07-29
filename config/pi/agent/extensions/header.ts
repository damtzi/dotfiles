import * as fs from "node:fs";
import os from "node:os";
import path from "node:path";
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@mariozechner/pi-coding-agent";

const RESET = "\x1b[0m";
const BOLD = "\x1b[1m";

const TEXT: Rgb = [202, 211, 245];
const MUTED: Rgb = [147, 154, 183];
const PINK: Rgb = [245, 189, 230];
const BLUE: Rgb = [138, 173, 244];
const BORDER = BLUE;
const GREEN: Rgb = [166, 218, 149];
const TEAL: Rgb = [139, 213, 202];

const DEEP_BLUE: Rgb = [22, 83, 189];
const ROYAL_BLUE: Rgb = [48, 129, 247];
const SKY: Rgb = [93, 171, 255];
const ICE: Rgb = [151, 205, 255];
const LOGO_PALETTE: Rgb[] = [DEEP_BLUE, ROYAL_BLUE, SKY, ICE, SKY, ROYAL_BLUE];

const MIN_WIDTH = 76;
const LEFT_WIDTH = 24;

const LOGO_LINES = [
  "██████   ",
  "██  ██   ",
  "████  ██ ",
  "██    ██ ",
];

type Rgb = [number, number, number];
type StartupInfo = {
  contextFiles: number;
  extensions: number;
  skills: number;
  recentSessions: string[];
};

const ANSI_PATTERN =
  /[\u001B\u009B][[\]()#;?]*(?:(?:(?:[a-zA-Z\d]*(?:;[a-zA-Z\d]*)*)?\u0007)|(?:(?:\d{1,4}(?:;\d{0,4})*)?[\dA-PR-TZcf-nq-uy=><~]))/g;

function mix(a: number, b: number, t: number) {
  return Math.round(a + (b - a) * t);
}

function sampleGradient(position: number) {
  const wrapped = ((position % 1) + 1) % 1;
  const scaled = wrapped * LOGO_PALETTE.length;
  const index = Math.floor(scaled);
  const nextIndex = (index + 1) % LOGO_PALETTE.length;
  const t = scaled - index;
  const a = LOGO_PALETTE[index]!;
  const b = LOGO_PALETTE[nextIndex]!;
  return [mix(a[0], b[0], t), mix(a[1], b[1], t), mix(a[2], b[2], t)] as Rgb;
}

function fg([r, g, b]: Rgb, text: string) {
  return `\x1b[38;2;${r};${g};${b}m${text}${RESET}`;
}

function visibleLength(text: string) {
  return [...text.replace(ANSI_PATTERN, "")].length;
}

function padRight(text: string, width: number) {
  const length = visibleLength(text);
  if (length >= width) return text;
  return `${text}${" ".repeat(width - length)}`;
}

function center(text: string, width: number) {
  const length = visibleLength(text);
  if (length >= width) return text;
  const left = Math.floor((width - length) / 2);
  return `${" ".repeat(left)}${text}${" ".repeat(width - length - left)}`;
}

function gradientLogoLine(line: string | undefined, row: number) {
  if (!line) return "";
  const chars = [...line];
  const span = Math.max(chars.length - 1, 1);
  return chars
    .map((char, index) => {
      if (char === " ") return char;
      return fg(sampleGradient(index / span + row * 0.045), char);
    })
    .join("");
}

function rule(width: number) {
  return fg(BORDER, "─".repeat(width));
}

function plural(count: number, singular: string, pluralName = `${singular}s`) {
  return `${count} ${count === 1 ? singular : pluralName}`;
}

function safeReaddir(dir: string) {
  try {
    return fs.readdirSync(dir, { withFileTypes: true });
  } catch {
    return [];
  }
}

function countFiles(dir: string, predicate: (name: string) => boolean) {
  return safeReaddir(dir).filter((entry) => entry.isFile() && predicate(entry.name)).length;
}

function countSkillFiles(dir: string): number {
  return safeReaddir(dir).reduce((count, entry) => {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) return count + countSkillFiles(fullPath);
    return count + (entry.isFile() && entry.name === "SKILL.md" ? 1 : 0);
  }, 0);
}

function countContextFiles() {
  const names = new Set(["AGENTS.md", "CLAUDE.md", "PI.md", "README.md"]);
  let count = 0;
  let dir = process.cwd();
  while (true) {
    count += countFiles(dir, (name) => names.has(name));
    const parent = path.dirname(dir);
    if (parent === dir || dir === os.homedir()) break;
    dir = parent;
  }
  return count;
}

function decodeSessionDir(name: string) {
  return name.replace(/^-+|-+$/g, "").split("-").filter(Boolean).at(-1) ?? name;
}

function formatAge(timeMs: number) {
  const seconds = Math.max(0, Math.floor((Date.now() - timeMs) / 1000));
  if (seconds < 60) return "now";
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  return `${Math.floor(hours / 24)}d ago`;
}

function recentSessions() {
  const sessionsDir = path.join(os.homedir(), ".pi", "agent", "sessions");
  return safeReaddir(sessionsDir)
    .filter((entry) => entry.isDirectory())
    .map((entry) => {
      const dir = path.join(sessionsDir, entry.name);
      const newest = safeReaddir(dir)
        .filter((file) => file.isFile() && file.name.endsWith(".jsonl"))
        .map((file) => fs.statSync(path.join(dir, file.name)).mtimeMs)
        .sort((a, b) => b - a)[0] ?? 0;
      return { name: decodeSessionDir(entry.name), newest };
    })
    .filter((session) => session.newest > 0)
    .sort((a, b) => b.newest - a.newest)
    .slice(0, 3)
    .map((session) => `${fg(TEAL, session.name)} ${fg(MUTED, `(${formatAge(session.newest)})`)}`);
}

function getStartupInfo(): StartupInfo {
  const agentDir = path.join(os.homedir(), ".pi", "agent");
  const extensionsDir = path.join(agentDir, "extensions");
  const skillsDir = path.join(agentDir, "skills");
  return {
    contextFiles: countContextFiles(),
    extensions: countFiles(extensionsDir, (name) => name.endsWith(".ts") || name.endsWith(".js")),
    skills: countSkillFiles(skillsDir),
    recentSessions: recentSessions(),
  };
}

function leftContent(row: number, width: number, modelId: string) {
  switch (row) {
    case 1:
      return center(`${BOLD}${fg(TEXT, "Welcome back!")}${RESET}`, width);
    case 3:
    case 4:
    case 5:
    case 6:
      return center(gradientLogoLine(LOGO_LINES[row - 3], row), width);
    case 8:
      return center(fg(PINK, modelId), width);
    case 9:
      return center(fg(MUTED, "openai-codex"), width);
    default:
      return " ".repeat(width);
  }
}

function rightContent(row: number, width: number, info: StartupInfo) {
  const recentLine = (index: number) => {
    const session = info.recentSessions[index];
    return session ? `${fg(MUTED, "•")} ${session}` : "";
  };
  const lines: Record<number, string> = {
    0: `${BOLD}${fg(BLUE, "Tips")}${RESET}`,
    1: `${fg(MUTED, "/")} for commands`,
    2: `${fg(MUTED, "!")} to run bash`,
    3: `${fg(MUTED, "Shift+Tab")} cycle thinking`,
    4: rule(width),
    5: `${BOLD}${fg(BLUE, "Loaded")}${RESET}`,
    6: fg(GREEN, `✓ ${plural(info.contextFiles, "context file")}`),
    7: fg(GREEN, `✓ ${plural(info.extensions, "extension")}`),
    8: fg(GREEN, `✓ ${plural(info.skills, "skill")}`),
    9: rule(width),
    10: `${BOLD}${fg(BLUE, "Recent sessions")}${RESET}`,
    11: recentLine(0),
    12: recentLine(1),
    13: recentLine(2),
  };
  return padRight(lines[row] ?? "", width);
}

function renderHeader(width: number, modelId: string, info: StartupInfo) {
  if (width < MIN_WIDTH) return [];

  const boxWidth = width;
  const leftWidth = LEFT_WIDTH;
  const rightWidth = boxWidth - leftWidth - 3;
  const title = ` ${fg(PINK, "π")} `;
  const titlePad = Math.max(0, boxWidth - visibleLength(title) - 2);
  const lines = [
    `${fg(BORDER, "╭")}${title}${fg(BORDER, "─".repeat(titlePad) + "╮")}`,
  ];

  for (let row = 0; row < 14; row++) {
    lines.push(
      `${fg(BORDER, "│")}${leftContent(row, leftWidth, modelId)}${fg(BORDER, "│")} ${rightContent(row, rightWidth - 1, info)}${fg(BORDER, "│")}`,
    );
  }

  const prompt = " Press ctrl+o to show help ";
  const bottomLeft = Math.max(0, Math.floor((boxWidth - visibleLength(prompt) - 2) / 2));
  const bottomRight = Math.max(0, boxWidth - visibleLength(prompt) - 2 - bottomLeft);
  lines.push(
    `${fg(BORDER, "╰" + "─".repeat(bottomLeft))}${fg(MUTED, prompt)}${fg(BORDER, "─".repeat(bottomRight) + "╯")}`,
    "",
  );

  return lines;
}

export default function (pi: ExtensionAPI) {
  let requestRender: (() => void) | undefined;
  let currentModelId = "no model selected";
  let startupInfo = getStartupInfo();

  function installHeader(ctx: ExtensionContext) {
    ctx.ui.setHeader((tui) => {
      requestRender = () => tui.requestRender();
      return {
        render(width: number) {
          return renderHeader(width, currentModelId, startupInfo);
        },
        invalidate() {
          tui.requestRender();
        },
      };
    });
  }

  pi.on("session_start", (_event, ctx) => {
    currentModelId = ctx.model?.id ?? "no model selected";
    startupInfo = getStartupInfo();
    if (!ctx.hasUI) return;
    installHeader(ctx);
  });

  pi.on("model_select", (event) => {
    currentModelId = event.model.id;
    requestRender?.();
  });

  pi.on("session_shutdown", (_event, ctx) => {
    if (ctx.hasUI) ctx.ui.setHeader(undefined);
  });

  pi.registerCommand("header", {
    description: "Enable the startup intro-style session header",
    handler: async (_args, ctx) => {
      startupInfo = getStartupInfo();
      installHeader(ctx);
      ctx.ui.notify("Custom header enabled", "info");
    },
  });

  pi.registerCommand("header-builtin", {
    description: "Restore pi's built-in header for this session",
    handler: async (_args, ctx) => {
      ctx.ui.setHeader(undefined);
      ctx.ui.notify("Built-in header restored", "info");
    },
  });
}
