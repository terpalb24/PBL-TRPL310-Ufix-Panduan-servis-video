"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

export default function Sidebar() {
  const pathname = usePathname();

  const menu = [
    { name: "Dashboard", href: "/admin/dashboard" },
    { name: "Manage Users", href: "/admin/users" },
    { name: "Videos", href: "/admin/videos" },
  ];

  return (
    <aside className="w-64 min-h-screen bg-gray-900 text-white flex flex-col">
      {/* LOGO */}
      <div className="p-6 text-2xl font-bold border-b border-gray-700">
        UFix Admin
      </div>

      {/* MENU */}
      <nav className="flex-1 p-4 space-y-2">
        {menu.map((item) => (
          <Link
            key={item.name}
            href={item.href}
            className={`block px-4 py-2 rounded-lg transition
              ${
                pathname === item.href
                  ? "bg-blue-600"
                  : "hover:bg-gray-800"
              }`}
          >
            {item.name}
          </Link>
        ))}
      </nav>

      {/* FOOTER */}
      <div className="p-4 border-t border-gray-700 text-sm text-gray-400">
        © UFix 2025
      </div>
    </aside>
  );
}
