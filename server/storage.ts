import { db } from "./db";
import { users, services, wasteTypes, orders, treatmentPricing } from "../shared/schema";
import { eq } from "drizzle-orm";

export class Storage {
  async getServices() {
    try {
      return await db.select().from(services);
    } catch (error) {
      console.error("Error fetching services:", error);
      return [];
    }
  }

  async getWasteTypes() {
    try {
      return await db.select().from(wasteTypes);
    } catch (error) {
      console.error("Error fetching waste types:", error);
      return [];
    }
  }

  async getTreatmentPricing() {
    try {
      return await db.select().from(treatmentPricing);
    } catch (error) {
      console.error("Error fetching treatment pricing:", error);
      return [];
    }
  }

  async getOrders() {
    try {
      return await db.select().from(orders);
    } catch (error) {
      console.error("Error fetching orders:", error);
      return [];
    }
  }

  async createOrder(orderData: any) {
    try {
      const [order] = await db.insert(orders).values(orderData).returning();
      return order;
    } catch (error) {
      console.error("Error creating order:", error);
      throw error;
    }
  }

  async getUsers() {
    try {
      return await db.select().from(users);
    } catch (error) {
      console.error("Error fetching users:", error);
      return [];
    }
  }

  async createUser(userData: any) {
    try {
      const [user] = await db.insert(users).values(userData).returning();
      return user;
    } catch (error) {
      console.error("Error creating user:", error);
      throw error;
    }
  }

  async getUserById(id: number) {
    try {
      const [user] = await db.select().from(users).where(eq(users.id, id));
      return user;
    } catch (error) {
      console.error("Error fetching user by ID:", error);
      return null;
    }
  }

  async getUserByEmail(email: string) {
    try {
      const [user] = await db.select().from(users).where(eq(users.email, email));
      return user;
    } catch (error) {
      console.error("Error fetching user by email:", error);
      return null;
    }
  }

  async updateUser(id: number, userData: any) {
    try {
      const [user] = await db.update(users).set(userData).where(eq(users.id, id)).returning();
      return user;
    } catch (error) {
      console.error("Error updating user:", error);
      throw error;
    }
  }

  async deleteUser(id: number) {
    try {
      await db.delete(users).where(eq(users.id, id));
      return true;
    } catch (error) {
      console.error("Error deleting user:", error);
      throw error;
    }
  }
}

export const storage = new Storage();