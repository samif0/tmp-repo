import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: 'standalone',

  eslint: {
    dirs: ['src'],
  }
};

export default nextConfig;
