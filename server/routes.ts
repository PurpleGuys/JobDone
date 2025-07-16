import { Express } from "express";
import { createServer } from "http";
import { storage } from "./storage";
import { authenticateToken, requireAdmin } from "./auth";
import { payplugService } from "./payplugService";

export async function registerRoutes(app: Express) {
  const server = createServer(app);

  // Health check endpoint
  app.get("/api/health", (req, res) => {
    res.json({ 
      status: "healthy", 
      timestamp: new Date().toISOString(),
      version: "1.0.0",
      environment: process.env.NODE_ENV || 'development'
    });
  });

  // Services routes
  app.get("/api/services", async (req, res) => {
    try {
      const services = await storage.getServices();
      res.json(services);
    } catch (error) {
      res.status(500).json({ error: "Failed to fetch services" });
    }
  });

  // Waste types routes
  app.get("/api/waste-types", async (req, res) => {
    try {
      const wasteTypes = await storage.getWasteTypes();
      res.json(wasteTypes);
    } catch (error) {
      res.status(500).json({ error: "Failed to fetch waste types" });
    }
  });

  // Pricing routes
  app.get("/api/pricing", async (req, res) => {
    try {
      const pricing = await storage.getTreatmentPricing();
      res.json(pricing);
    } catch (error) {
      res.status(500).json({ error: "Failed to fetch pricing" });
    }
  });

  // Orders routes
  app.get("/api/orders", authenticateToken, async (req, res) => {
    try {
      const orders = await storage.getOrders();
      res.json(orders);
    } catch (error) {
      res.status(500).json({ error: "Failed to fetch orders" });
    }
  });

  app.post("/api/orders", authenticateToken, async (req, res) => {
    try {
      const order = await storage.createOrder(req.body);
      res.json(order);
    } catch (error) {
      res.status(500).json({ error: "Failed to create order" });
    }
  });

  // Admin routes
  app.get("/api/admin/services", authenticateToken, requireAdmin, async (req, res) => {
    try {
      const services = await storage.getServices();
      res.json(services);
    } catch (error) {
      res.status(500).json({ error: "Failed to fetch services" });
    }
  });

  // PayPlug payment routes
  app.post("/api/payments/create", authenticateToken, async (req, res) => {
    try {
      const payment = await payplugService.createPayment(req.body);
      res.json(payment);
    } catch (error) {
      res.status(500).json({ error: "Failed to create payment" });
    }
  });

  app.get("/api/payments/:id", authenticateToken, async (req, res) => {
    try {
      const payment = await payplugService.getPayment(req.params.id);
      res.json(payment);
    } catch (error) {
      res.status(500).json({ error: "Failed to retrieve payment" });
    }
  });

  app.post("/api/payments/:id/refund", authenticateToken, requireAdmin, async (req, res) => {
    try {
      const refund = await payplugService.createRefund(req.params.id, req.body.amount, req.body.metadata);
      res.json(refund);
    } catch (error) {
      res.status(500).json({ error: "Failed to create refund" });
    }
  });

  // PayPlug webhook endpoint
  app.post("/api/webhooks/payplug", async (req, res) => {
    await payplugService.handleWebhook(req, res);
  });

  return server;
}