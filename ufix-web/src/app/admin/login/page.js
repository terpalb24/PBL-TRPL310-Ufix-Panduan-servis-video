"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Cookies from "js-cookie";
import Image from "next/image";

export default function LoginAdminPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState("");

  const API_URL = "http://localhost:3001/api/auth/login-web";

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    setErrorMsg("");

    try {
      const res = await fetch(API_URL, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          email: email.trim(),
          password,
        }),
      });

      const data = await res.json();

      if (!data.success) {
        setErrorMsg(data.message || "Login gagal.");
        setLoading(false);
        return;
      }

      if (data.user.role !== "admin") {
        setErrorMsg("Akses ditolak. Bukan admin.");
        setLoading(false);
        return;
      }

      Cookies.set("token", data.token, { expires: 1 });
      Cookies.set("role", data.user.role, { expires: 1 });
      Cookies.set("adminName", data.user.displayName || "", { expires: 1 });


      router.push("/admin/dashboard");
    } catch (err) {
      setErrorMsg("Terjadi kesalahan server.");
    }

    setLoading(false);
  };

  return (
    <div
      style={{
        minHeight: "100vh",
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        backgroundColor: "#F7F7FA",
      }}
    >
      <form
        onSubmit={handleLogin}
        style={{
          width: "360px",
          padding: "32px",
          borderRadius: "16px",
          backgroundColor: "#fff",
          boxShadow: "0 6px 30px rgba(0,0,0,0.1)",
          textAlign: "center",
        }}
      >
        {/* LOGO */}
        <Image
          src="/logo.png"
          alt="Ufix Logo"
          width={180}
          height={180}
          style={{ marginBottom: "20px" }}
        />

        <h2 style={{ marginBottom: "20px", color: "#333" }}>
          Admin Login
        </h2>

        {errorMsg && (
          <p style={{ color: "red", marginBottom: "12px" }}>
            {errorMsg}
          </p>
        )}

        <input
          type="email"
          placeholder="Email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          style={inputStyle}
          required
        />

        <input
          type="password"
          placeholder="Password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          style={inputStyle}
          required
        />

        <button
          type="submit"
          disabled={loading}
          style={{
            width: "100%",
            padding: "12px",
            borderRadius: "20px",
            backgroundColor: "#4B92DB",
            color: "#fff",
            border: "none",
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

const inputStyle = {
  width: "100%",
  padding: "12px",
  marginBottom: "16px",
  borderRadius: "14px",
  border: "1px solid #ccc",
  backgroundColor: "#F0F7FC",
};
