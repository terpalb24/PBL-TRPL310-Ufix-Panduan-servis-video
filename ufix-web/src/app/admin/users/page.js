"use client";

import Cookies from "js-cookie";
import { useRouter } from "next/navigation";
import { useEffect } from "react";

export default function ManageUsers() {
  const router = useRouter();

  useEffect(() => {
    const token = Cookies.get("token");
    const role = Cookies.get("role");

    if (!token || !["admin", "superadmin"].includes(role)) {
      router.push("/admin");
    }
  }, []);

  return (
    <div>
      {/* PAGE TITLE */}
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-gray-800">
          User Management
        </h1>
        <p className="text-gray-500">
          Manage admin, technician, and app users
        </p>
      </div>

      {/* CARD */}
      <div className="bg-white rounded-xl shadow p-6">

        {/* ACTION BAR */}
        <div className="flex justify-between items-center mb-4">
          <input
            type="text"
            placeholder="Search user..."
            className="border rounded-lg px-4 py-2 text-sm w-64"
          />

          <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
            + Add User
          </button>
        </div>

        {/* TABLE */}
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-gray-100 text-gray-600">
              <tr>
                <th className="p-4 text-left">No</th>
                <th className="p-4 text-left">Name</th>
                <th className="p-4 text-left">Email</th>
                <th className="p-4 text-left">Role</th>
                <th className="p-4 text-center">Action</th>
              </tr>
            </thead>

            <tbody>
              {[1, 2, 3].map((i) => (
                <tr key={i} className="border-t hover:bg-gray-50">
                  <td className="p-4">{i}</td>
                  <td className="p-4 font-medium">User {i}</td>
                  <td className="p-4 text-gray-600">
                    user{i}@mail.com
                  </td>
                  <td className="p-4">
                    <span className="px-3 py-1 rounded-full text-xs bg-green-100 text-green-700">
                      Admin
                    </span>
                  </td>
                  <td className="p-4 text-center space-x-2">
                    <button className="px-3 py-1 border rounded hover:bg-gray-100">
                      Edit
                    </button>
                    <button className="px-3 py-1 border rounded text-red-600 hover:bg-red-50">
                      Delete
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

      </div>
    </div>
  );
}
