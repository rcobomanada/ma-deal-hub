mkdir -p ma-deal-hub/src/lib ma-deal-hub/src/types ma-deal-hub/src/data ma-deal-hub/src/components ma-deal-hub/src/app/deals/'[id]' ma-deal-hub/src/app/analytics ma-deal-hub/src/app/about && cd ma-deal-hub && cat << 'EOF' > package.json
{
  "name": "ma-deal-hub",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "clsx": "^2.1.1",
    "lucide-react": "^0.475.0",
    "next": "15.1.7",
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "tailwind-merge": "^3.0.1"
  },
  "devDependencies": {
    "@types/node": "^20",
    "@types/react": "^19",
    "@types/react-dom": "^19",
    "postcss": "^8",
    "tailwindcss": "^3.4.1",
    "typescript": "^5"
  }
}
EOF
cat << 'EOF' > tsconfig.json
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": { "@/*": ["./src/*"] }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF
cat << 'EOF' > tailwind.config.ts
import type { Config } from "tailwindcss";
export default {
  content: ["./src/**/*.{js,ts,jsx,tsx,mdx}"],
  theme: { extend: {} },
  plugins: [],
} satisfies Config;
EOF
cat << 'EOF' > postcss.config.mjs
export default {
  plugins: {
    tailwindcss: {},
  },
};
EOF
cat << 'EOF' > src/app/globals.css
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF
cat << 'EOF' > src/types/deal.ts
export type DealStatus = "Completed" | "Pending" | "Terminated";
export interface Deal {
  id: string;
  slug: string;
  acquirer: string;
  target: string;
  acquirerCountry: string;
  targetCountry: string;
  sector: string;
  dealValue: number | null;
  currency: string;
  status: DealStatus;
  announcedDate: string;
  completedDate: string | null;
  dealType: string;
  description: string;
  rationale?: string;
  sourceUrl?: string;
  isExample: boolean;
}
EOF
cat << 'EOF' > src/lib/utils.ts
import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";
export function cn(...inputs: ClassValue[]) { return twMerge(clsx(inputs)); }
export function formatCurrency(value: number | null | undefined, currency = "USD"): string {
  if (value === null || value === undefined) return "Undisclosed";
  return new Intl.NumberFormat("en-US", { style: "currency", currency, notation: "compact", maximumFractionDigits: 1 }).format(value);
}
export function formatDate(dateString: string | null | undefined): string {
  if (!dateString) return "N/A";
  return new Date(dateString).toLocaleDateString("en-US", { year: "numeric", month: "short", day: "numeric" });
}
EOF
cat << 'EOF' > src/data/seedDeals.ts
import { Deal } from "@/types/deal";
export const SEED_DEALS: Deal[] = [
  {
    id: "msft-atvi-2022",
    slug: "microsoft-activision-blizzard",
    acquirer: "Microsoft Corporation",
    target: "Activision Blizzard, Inc.",
    acquirerCountry: "United States",
    targetCountry: "United States",
    sector: "Technology & Gaming",
    dealValue: 68700000000,
    currency: "USD",
    status: "Completed",
    announcedDate: "2022-01-18",
    completedDate: "2023-10-13",
    dealType: "Acquisition (All-cash)",
    description: "Microsoft acquired Activision Blizzard to accelerate growth in its gaming business across mobile, PC, and cloud.",
    rationale: "Strategic expansion into cloud gaming infrastructure and acquiring major IP.",
    sourceUrl: "https://news.microsoft.com",
    isExample: true,
  },
  {
    id: "xom-pxd-2023",
    slug: "exxonmobil-pioneer-natural-resources",
    acquirer: "ExxonMobil Corporation",
    target: "Pioneer Natural Resources",
    acquirerCountry: "United States",
    targetCountry: "United States",
    sector: "Energy",
    dealValue: 59500000000,
    currency: "USD",
    status: "Completed",
    announcedDate: "2023-10-11",
    completedDate: "2024-05-03",
    dealType: "Merger (All-stock)",
    description: "ExxonMobil merged with Pioneer to expand its position in the Permian Basin.",
    rationale: "Unlocking significant scale efficiencies in unconventional US oil production.",
    sourceUrl: "https://corporate.exxonmobil.com",
    isExample: true,
  },
  {
    id: "adbe-fig-2022",
    slug: "adobe-figma",
    acquirer: "Adobe Inc.",
    target: "Figma, Inc.",
    acquirerCountry: "United States",
    targetCountry: "United States",
    sector: "Technology & Design Software",
    dealValue: 20000000000,
    currency: "USD",
    status: "Terminated",
    announcedDate: "2022-09-15",
    completedDate: null,
    dealType: "Acquisition",
    description: "Proposed acquisition terminated following regulatory scrutiny in the UK and EU.",
    rationale: "Intended to merge web-native collaborative capabilities with Adobe Creative Suite.",
    sourceUrl: "https://news.adobe.com",
    isExample: true,
  }
];
EOF
cat << 'EOF' > src/lib/dataProvider.ts
import { SEED_DEALS } from "@/data/seedDeals";
import { Deal } from "@/types/deal";
export async function getDeals(params?: { query?: string; status?: string }): Promise<Deal[]> {
  let results = [...SEED_DEALS];
  if (params?.query) {
    const q = params.query.toLowerCase();
    results = results.filter(d => d.acquirer.toLowerCase().includes(q) || d.target.toLowerCase().includes(q));
  }
  if (params?.status && params.status !== "All") {
    results = results.filter(d => d.status === params.status);
  }
  return results;
}
export async function getDealById(id: string): Promise<Deal | undefined> {
  return SEED_DEALS.find(d => d.id === id || d.slug === id);
}
EOF
cat << 'EOF' > src/components/Navbar.tsx
import Link from "next/link";
import { Building2, BarChart3, Database, Info } from "lucide-react";
export function Navbar() {
  return (
    <nav className="bg-[#0f172a] text-white border-b border-slate-800 sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 flex items-center justify-between h-16">
        <Link href="/" className="flex items-center space-x-2 font-semibold text-lg">
          <Building2 className="h-6 w-6 text-emerald-400" />
          <span>M&A Deal Hub</span>
        </Link>
        <div className="flex space-x-6 text-sm font-medium">
          <Link href="/deals" className="hover:text-emerald-400 flex items-center gap-1.5"><Database className="h-4 w-4" /> Deals</Link>
          <Link href="/analytics" className="hover:text-emerald-400 flex items-center gap-1.5"><BarChart3 className="h-4 w-4" /> Analytics</Link>
          <Link href="/about" className="hover:text-emerald-400 flex items-center gap-1.5"><Info className="h-4 w-4" /> About</Link>
        </div>
      </div>
    </nav>
  );
}
EOF
cat << 'EOF' > src/app/layout.tsx
import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { Navbar } from "@/components/Navbar";
const inter = Inter({ subsets: ["latin"] });
export const metadata: Metadata = {
  title: "M&A Deal Hub",
  description: "Global mergers and acquisitions database",
};
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className={`${inter.className} min-h-screen bg-slate-50 text-slate-900 flex flex-col`}>
        <Navbar />
        <main className="flex-1 max-w-7xl w-full mx-auto px-4 py-8">{children}</main>
      </body>
    </html>
  );
}
EOF
cat << 'EOF' > src/app/not-found.tsx
import Link from "next/link";
export default function NotFound() {
  return (
    <div className="text-center py-20">
      <h1 className="text-3xl font-bold mb-2">Record Not Found</h1>
      <p className="text-slate-600 mb-6 text-sm">The requested transaction could not be located.</p>
      <Link href="/deals" className="bg-slate-900 text-white px-4 py-2 rounded-md text-sm">Back to Deals</Link>
    </div>
  );
}
EOF
cat << 'EOF' > src/app/page.tsx
import Link from "next/link";
import { getDeals } from "@/lib/dataProvider";
import { formatCurrency, formatDate } from "@/lib/utils";
import { Search } from "lucide-react";
export default async function HomePage() {
  const deals = await getDeals();
  return (
    <div className="space-y-10">
      <div className="text-center space-y-4 max-w-2xl mx-auto pt-4">
        <h1 className="text-4xl font-extrabold text-slate-900">Discover the deals shaping global business.</h1>
        <p className="text-slate-600 text-sm">Institutional-grade intelligence for M&A transactions.</p>
        <form action="/deals" method="GET" className="relative max-w-lg mx-auto flex items-center">
          <Search className="absolute left-3 h-4 w-4 text-slate-400" />
          <input name="query" placeholder="Search company (e.g. Microsoft)..." className="w-full pl-10 pr-24 py-2.5 bg-white border border-slate-300 rounded-lg text-sm" />
          <button type="submit" className="absolute right-1.5 px-3 py-1.5 bg-slate-900 text-white rounded-md text-xs font-semibold">Search</button>
        </form>
      </div>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {deals.map(d => (
          <Link key={d.id} href={`/deals/${d.id}`} className="p-4 bg-white border border-slate-200 rounded-lg hover:shadow-sm">
            <span className="text-[11px] font-bold text-slate-500 uppercase">{d.sector}</span>
            <h3 className="font-bold text-slate-900 mt-1">{d.acquirer}</h3>
            <p className="text-xs text-slate-500 mb-3">target: {d.target}</p>
            <div className="text-sm font-bold">{formatCurrency(d.dealValue)}</div>
          </Link>
        ))}
      </div>
    </div>
  );
}
EOF
cat << 'EOF' > src/app/deals/page.tsx
import Link from "next/link";
import { getDeals } from "@/lib/dataProvider";
import { formatCurrency, formatDate } from "@/lib/utils";
export default async function DealsPage({ searchParams }: { searchParams: Promise<{ query?: string; status?: string }> }) {
  const params = await searchParams;
  const deals = await getDeals(params);
  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Transaction Database</h1>
      <form method="GET" className="bg-white p-4 rounded-lg border border-slate-200 flex gap-4">
        <input name="query" defaultValue={params.query || ""} placeholder="Search acquirer or target..." className="w-full px-3 py-2 border rounded-md text-sm" />
        <button type="submit" className="bg-slate-900 text-white px-4 py-2 rounded-md text-sm font-semibold">Filter</button>
      </form>
      <div className="bg-white border rounded-lg overflow-hidden">
        <table className="w-full text-left text-sm">
          <thead className="bg-slate-50 border-b text-xs uppercase text-slate-500">
            <tr>
              <th className="p-3">Acquirer</th>
              <th className="p-3">Target</th>
              <th className="p-3">Value</th>
              <th className="p-3">Status</th>
              <th className="p-3"></th>
            </tr>
          </thead>
          <tbody className="divide-y">
            {deals.map(d => (
              <tr key={d.id}>
                <td className="p-3 font-semibold">{d.acquirer}</td>
                <td className="p-3">{d.target}</td>
                <td className="p-3">{formatCurrency(d.dealValue)}</td>
                <td className="p-3 text-xs">{d.status}</td>
                <td className="p-3 text-right"><Link href={`/deals/${d.id}`} className="text-emerald-700 underline text-xs">View</Link></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
EOF
cat << 'EOF' > src/app/deals/'[id]'/page.tsx
import { notFound } from "next/navigation";
import Link from "next/link";
import { getDealById } from "@/lib/dataProvider";
import { formatCurrency, formatDate } from "@/lib/utils";
export default async function DealDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const deal = await getDealById(id);
  if (!deal) notFound();
  return (
    <div className="bg-white p-6 border rounded-lg max-w-3xl mx-auto space-y-4">
      <Link href="/deals" className="text-xs text-slate-500 hover:underline">&larr; Back to Deals</Link>
      <h1 className="text-2xl font-bold">{deal.acquirer} & {deal.target}</h1>
      <div className="text-xl font-bold font-mono text-emerald-700">{formatCurrency(deal.dealValue)}</div>
      <p className="text-sm text-slate-700">{deal.description}</p>
      {deal.rationale && <p className="text-xs text-slate-500 bg-slate-50 p-3 rounded border">{deal.rationale}</p>}
    </div>
  );
}
EOF
cat << 'EOF' > src/app/analytics/page.tsx
import { getDeals } from "@/lib/dataProvider";
import { formatCurrency } from "@/lib/utils";
export default async function AnalyticsPage() {
  const deals = await getDeals();
  const total = deals.reduce((acc, d) => acc + (d.dealValue || 0), 0);
  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Analytics Overview</h1>
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div className="bg-white p-4 border rounded-lg">
          <div className="text-xs text-slate-500 font-mono">Total Disclosed Volume</div>
          <div className="text-2xl font-bold">{formatCurrency(total)}</div>
        </div>
        <div className="bg-white p-4 border rounded-lg">
          <div className="text-xs text-slate-500 font-mono">Total Deals Tracked</div>
          <div className="text-2xl font-bold">{deals.length}</div>
        </div>
      </div>
    </div>
  );
}
EOF
cat << 'EOF' > src/app/about/page.tsx
export default function AboutPage() {
  return (
    <div className="max-w-2xl mx-auto space-y-4 bg-white p-6 border rounded-lg">
      <h1 className="text-2xl font-bold">About M&A Deal Hub</h1>
      <p className="text-sm text-slate-700">This platform provides structured intelligence for corporate transactions. Designed for informational and educational analysis.</p>
    </div>
  );
}
EOF
cat << 'EOF' > README.md
# M&A Deal Hub
Platform for tracking and analyzing global M&A transactions.
## How to run
1. npm install
2. npm run build
3. npm run dev
EOF
git init && git add . && git commit -m "feat: complete ma-deal-hub project"
echo "--- PROYECTO LISTO Y COMPLETO EN LA CARPETA ma-deal-hub ---"