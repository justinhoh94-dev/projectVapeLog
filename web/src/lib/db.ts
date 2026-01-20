import Dexie, { Table } from 'dexie';

// Data models matching iOS version
export interface Product {
  id?: number;
  name: string;
  brand?: string;
  type: string;
  route: string;

  // Cannabinoids
  thcPercent?: number;
  cbdPercent?: number;
  cbgPercent?: number;
  thcvPercent?: number;

  // Terpenes
  myrcene?: number;
  limonene?: number;
  pinene?: number;
  caryophyllene?: number;
  humulene?: number;
  linalool?: number;
  terpinolene?: number;
  ocimene?: number;
  otherTerpenes?: string;

  notes?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface Session {
  id?: number;
  productId: number;
  dateTime: Date;
  doseMg?: number;
  doseUnits?: string;

  // Context
  location?: string;
  withCompany: boolean;
  hadCaffeine: boolean;
  hadAlcohol: boolean;
  hadFood: boolean;
  sleepQuality?: number;

  // Pre-session state
  preMood?: number;
  preStress?: number;

  notes?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface CheckIn {
  id?: number;
  sessionId: number;
  minutesAfter: number;
  timestamp: Date;

  // Positive effects
  awake?: number;
  active?: number;
  cerebral?: number;
  social?: number;
  euphoric?: number;
  creative?: number;
  focused?: number;

  // Negative effects
  tired?: number;
  groggy?: number;
  anxious?: number;
  antisocial?: number;
  paranoia?: number;
  dryMouth?: number;
  dryEyes?: number;
  racingHeart?: number;

  notes?: string;
  createdAt: Date;
}

// IndexedDB Database
export class VapeLogDB extends Dexie {
  products!: Table<Product, number>;
  sessions!: Table<Session, number>;
  checkIns!: Table<CheckIn, number>;

  constructor() {
    super('VapeLogDB');

    this.version(1).stores({
      products: '++id, name, type, createdAt',
      sessions: '++id, productId, dateTime, createdAt',
      checkIns: '++id, sessionId, minutesAfter, timestamp'
    });
  }
}

// Singleton instance
export const db = new VapeLogDB();

// Helper functions
export async function addProduct(product: Omit<Product, 'id' | 'createdAt' | 'updatedAt'>): Promise<number> {
  const now = new Date();
  return await db.products.add({
    ...product,
    createdAt: now,
    updatedAt: now
  });
}

export async function addSession(session: Omit<Session, 'id' | 'createdAt' | 'updatedAt'>): Promise<number> {
  const now = new Date();
  return await db.sessions.add({
    ...session,
    createdAt: now,
    updatedAt: now
  });
}

export async function addCheckIn(checkIn: Omit<CheckIn, 'id' | 'createdAt'>): Promise<number> {
  return await db.checkIns.add({
    ...checkIn,
    createdAt: new Date()
  });
}

export async function getSessionCount(): Promise<number> {
  return await db.sessions.count();
}

export async function getAllProducts(): Promise<Product[]> {
  return await db.products.orderBy('createdAt').reverse().toArray();
}

export async function getAllSessions(): Promise<Session[]> {
  return await db.sessions.orderBy('dateTime').reverse().toArray();
}

export async function getSessionsWithProduct(): Promise<Array<Session & { product: Product }>> {
  const sessions = await getAllSessions();
  const products = await db.products.toArray();
  const productMap = new Map(products.map(p => [p.id!, p]));

  return sessions
    .map(session => ({
      ...session,
      product: productMap.get(session.productId)!
    }))
    .filter(s => s.product);
}

export async function getCheckIns(sessionId: number): Promise<CheckIn[]> {
  return await db.checkIns
    .where('sessionId')
    .equals(sessionId)
    .sortBy('minutesAfter');
}

export async function calculateAverageEffects(productId: number): Promise<{ positive: number; negative: number } | null> {
  const sessions = await db.sessions.where('productId').equals(productId).toArray();

  if (sessions.length === 0) return null;

  let positiveSum = 0;
  let negativeSum = 0;
  let count = 0;

  for (const session of sessions) {
    const checkIns = await getCheckIns(session.id!);

    for (const checkIn of checkIns) {
      const positive = [
        checkIn.awake ?? 0, checkIn.active ?? 0, checkIn.cerebral ?? 0, checkIn.social ?? 0,
        checkIn.euphoric ?? 0, checkIn.creative ?? 0, checkIn.focused ?? 0
      ].reduce((sum, val) => sum + val, 0) / 7;

      const negative = [
        checkIn.tired ?? 0, checkIn.groggy ?? 0, checkIn.anxious ?? 0, checkIn.antisocial ?? 0,
        checkIn.paranoia ?? 0, checkIn.dryMouth ?? 0, checkIn.dryEyes ?? 0, checkIn.racingHeart ?? 0
      ].reduce((sum, val) => sum + val, 0) / 8;

      positiveSum += positive;
      negativeSum += negative;
      count++;
    }
  }

  if (count === 0) return null;

  return {
    positive: positiveSum / count,
    negative: negativeSum / count
  };
}

// Export all data
export async function exportData(): Promise<string> {
  const products = await db.products.toArray();
  const sessions = await db.sessions.toArray();
  const checkIns = await db.checkIns.toArray();

  return JSON.stringify({
    products,
    sessions,
    checkIns,
    exportedAt: new Date().toISOString()
  }, null, 2);
}
