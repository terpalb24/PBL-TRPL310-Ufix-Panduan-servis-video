"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Cookies from "js-cookie";

export default function LoginAdminPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState("");

  const API_URL = "http://localhost:3001/api/auth/login"; 
  //UBAH KE PORT BACKEND KAMU

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    setErrorMsg("");

    try {
      const res = await fetch(API_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email: email.trim(),
          password,
        }),
      });

      const data = await res.json();

      // Jika gagal login
      if (!data.success) {
        setErrorMsg(data.message || "Login gagal.");
        setLoading(false);
        return;
      }

      const user = data.user;

      // Cek role admin
      if (!user || user.role !== "admin") {
        setErrorMsg("Akses ditolak. Anda bukan admin.");
        setLoading(false);
        return;
      }

      // Simpan cookie
      Cookies.set("token", data.token, { expires: 1 });
      Cookies.set("role", user.role, { expires: 1 });
      Cookies.set("adminName", user.displayName || "", { expires: 1 });

      // Redirect ke dashboard admin
      router.push("/admin/dashboard");
    } catch (error) {
      console.error("Login error:", error);
      setErrorMsg("Terjadi kesalahan server.");
    }

    setLoading(false);
  };

  return (
    <div
      style={{
        width: "100%",
        height: "100vh",
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        backgroundColor: "#F3F6FA",
      }}
    >
      <form
        onSubmit={handleLogin}
        style={{
          width: "360px",
          padding: "28px",
          borderRadius: "12px",
          backgroundColor: "#fff",
          boxShadow: "0 4px 24px rgba(0,0,0,0.1)",
        }}
      >
        <h2
          style={{
            textAlign: "center",
            marginBottom: "22px",
            fontSize: "24px",
            fontWeight: "600",
            color: "#333",
          }}
        >
          Admin Login
        </h2>

        {errorMsg && (
          <p
            style={{
              color: "red",
              marginBottom: "14px",
              textAlign: "center",
              fontSize: "14px",
            }}
          >
            {errorMsg}
          </p>
        )}

        <label style={{ fontSize: "14px" }}>Email</label>
        <input
          type="email"
          placeholder="admin@example.com"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          required
          style={{
            width: "100%",
            padding: "10px",
            marginBottom: "16px",
            borderRadius: "8px",
            border: "1px solid #ccc",
          }}
        />

        <label style={{ fontSize: "14px" }}>Password</label>
        <input
          type="password"
          placeholder="••••••••••"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
          style={{
            width: "100%",
            padding: "10px",
            marginBottom: "20px",
            borderRadius: "8px",
            border: "1px solid #ccc",
          }}
        />

        <button
          type="submit"
          disabled={loading}
          style={{
            width: "100%",
            padding: "12px",
            backgroundColor: "#4B92DB",
            color: "#fff",
            border: "none",
            borderRadius: "8px",
            fontSize: "16px",
            cursor: "pointer",
          }}
        >
          {loading ? "Memproses..." : "Masuk"}
        </button>
      </form>
    </div>
  );
}
