//+------------------------------------------------------------------+
//| Forex Trading Bot: Buy Stop & Sell Stop at Pip Intervals (MQL4) |
//+------------------------------------------------------------------+
#property strict

extern double LotSize = 0.1;       // User-defined lot size
extern int OrderCount = 4;         // Number of Buy Stop/Sell Stop orders
extern int PipInterval = 1000;     // Interval in pips between orders
extern double BuyTriggerLevel = 3100; // Price level to trigger Buy Stop orders
extern double SellTriggerLevel = 3150; // Price level to trigger Sell Stop orders
extern int StopLossPips = 2000;      // Stop loss in pips

bool BuyTriggered = false;
bool SellTriggered = false;

double BuyStopTakeProfit;
double SellStopTakeProfit;

// Function to place Buy Stop orders
void SetBuyStops(double triggerPrice) {
   double price = triggerPrice + PipInterval * Point;
   double stopLoss = price - (StopLossPips * Point);
   double takeProfit = price + (20 * StopLossPips * Point);
   BuyStopTakeProfit = takeProfit;
   
   for (int i = 0; i < OrderCount; i++) {
      int ticket = OrderSend(Symbol(), OP_BUYSTOP, LotSize, price, 3, stopLoss, takeProfit, "Buy Stop Order", 0, 0, Blue);
      if (ticket > 0) {
         Print("✅ Buy Stop order placed at ", price);
      } else {
         Print("❌ Error placing Buy Stop order: ", GetLastError());
      }
      price += PipInterval * Point;
   }
}

// Function to place Sell Stop orders
void SetSellStops(double triggerPrice) {
   double price = triggerPrice - PipInterval * Point;
   double stopLoss = price + (StopLossPips * Point);
   double takeProfit = price - (20 * StopLossPips * Point);
   SellStopTakeProfit = takeProfit;
   
   for (int i = 0; i < OrderCount; i++) {
      int ticket = OrderSend(Symbol(), OP_SELLSTOP, LotSize, price, 3, stopLoss, takeProfit, "Sell Stop Order", 0, 0, Red);
      if (ticket > 0) {
         Print("✅ Sell Stop order placed at ", price);
      } else {
         Print("❌ Error placing Sell Stop order: ", GetLastError());
      }
      price -= PipInterval * Point;
   }
}

// Check if Buy Trigger Level is reached
void CheckBuyTrigger() {
   if (Bid >= BuyTriggerLevel && !BuyTriggered) {
      Print("🔥 Buy Trigger Activated at ", BuyTriggerLevel);
      SetBuyStops(BuyTriggerLevel);
      BuyTriggered = true;
   }
}

// Check if Sell Trigger Level is reached
void CheckSellTrigger() {
   if (Ask <= SellTriggerLevel && !SellTriggered) {
      Print("🔥 Sell Trigger Activated at ", SellTriggerLevel);
      SetSellStops(SellTriggerLevel);
      SellTriggered = true;
   }
}

//+------------------------------------------------------------------+
//| Expert initialization function                                  |
//+------------------------------------------------------------------+
int init() {
   Print("Bot Initialized: Monitoring price levels...");
   return 0;
}

//+------------------------------------------------------------------+
//| Expert tick function                                            |
//+------------------------------------------------------------------+
void start() {
   CheckBuyTrigger();
   CheckSellTrigger();
}
