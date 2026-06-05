"use client";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { clearToken } from "@/lib/api";
const nav = [["/dashboard", "Overview"], ["/dashboard/clusters", "Clusters"], ["/dashboard/install-agent", "Install Agent"], ["/dashboard/settings/agent-keys", "Agent Keys"], ["/dashboard/settings", "Settings"]];
export function DashboardShell({ children }: { children: React.ReactNode }) { const pathname = usePathname(); const router = useRouter(); return <div className="min-h-screen lg:flex"><aside className="border-r bg-white p-5 lg:w-72"><Link href="/dashboard" className="text-xl font-black text-blue-700">ClusterWatch</Link><nav className="mt-8 space-y-1">{nav.map(([href,label]) => <Link key={href} href={href} className={`block rounded-lg px-3 py-2 text-sm font-medium ${pathname === href ? "bg-blue-50 text-blue-700" : "text-slate-700 hover:bg-slate-50"}`}>{label}</Link>)}</nav><button className="btn-secondary mt-8 w-full" onClick={() => { clearToken(); router.push("/login"); }}>Logout</button></aside><main className="flex-1 p-6 lg:p-10">{children}</main></div>; }
