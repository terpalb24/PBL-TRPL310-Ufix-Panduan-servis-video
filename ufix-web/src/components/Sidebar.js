'use client';

import { useState } from 'react';
import Link from 'next/link';
import {
  ChevronLeftIcon,
  ChevronRightIcon,
  HomeIcon,
  UsersIcon,
  VideoCameraIcon,
  ChatBubbleLeftIcon,
  BookmarkIcon,
  TvIcon,
  TagIcon,
  BookOpenIcon,
} from '@heroicons/react/24/outline';

export default function Sidebar() {
  const [collapsed, setCollapsed] = useState(false);

  const menuItems = [
    { name: 'Dashboard', icon: <HomeIcon className="w-3 h-3" />, path: '/' },
    { name: 'Pengguna', icon: <UsersIcon className="w-3 h-3" />, path: '/users' },
    { name: 'Video', icon: <VideoCameraIcon className="w-3 h-3" />, path: '/video' },
    { name: 'Komentar', icon: <ChatBubbleLeftIcon className="w-3 h-3" />, path: '/komentar' },
    { name: 'Bookmark', icon: <BookmarkIcon className="w-3 h-3" />, path: '/bookmark' },
    { name: 'Tontonan Pengguna', icon: <TvIcon className="w-3 h-3" />, path: '/menonton' },
    { name: 'Tag', icon: <TagIcon className="w-3 h-3" />, path: '/tag' },
  ];

  return (
    <div className={`min-h-screen transition-all duration-300 ${collapsed ? 'w-20' : 'w-64'} bg-base-200`}>
      {/* Sidebar Header */}
      <div className="p-4 flex items-center justify-between border-b border-base-300">
        {!collapsed && <h1 className="text-xl font-bold">My App</h1>}
        <button
          onClick={() => setCollapsed(!collapsed)}
          className="btn btn-ghost btn-circle"
        >
          {collapsed ? (
            <ChevronRightIcon className="w-5 h-5" />
          ) : (
            <ChevronLeftIcon className="w-5 h-5" />
          )}
        </button>
      </div>

      {/* Navigation Items */}
      <ul className="menu p-4 space-y-2">
        {menuItems.map((item) => (
          <li key={item.name}>
            <Link
              href={item.path}
              className="flex items-center gap-3 hover:bg-base-300 rounded-lg p-3"
              title={collapsed ? item.name : ''}
            >
              {item.icon}
              {!collapsed && <span>{item.name}</span>}
            </Link>
          </li>
        ))}
      </ul>
    </div>
  );
}
