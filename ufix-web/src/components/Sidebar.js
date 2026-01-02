"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

export default function Sidebar() {
  const pathname = usePathname();

  const menu = [
    { label: "Dashboard", href: "/admin/dashboard" },
    { label: "Manage Users", href: "/admin/users" },
  ];

  return (
    <aside className="w-64 min-h-screen bg-white border-r">
      {/* LOGO */}
      <div className="p-6 border-b">
        <h1 className="text-xl font-bold text-blue-600">
          UFIX Admin
        </h1>
      </div>

      {/* MENU */}
      <nav className="p-4 space-y-2">
        {menu.map((item) => (
          <Link
            key={item.href}
            href={item.href}
            className={`block px-4 py-2 rounded-lg text-sm font-medium
              ${
                pathname === item.href
                  ? "bg-blue-100 text-blue-600"
                  : "text-gray-600 hover:bg-gray-100"
              }`}
          >
            {item.label}
          </Link>
        ))}
      </nav>
    </aside>
  );
}
