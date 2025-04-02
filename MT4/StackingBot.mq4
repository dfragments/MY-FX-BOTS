//+------------------------------------------------------------------+
//| Forex Trading Bot: Buy Stop & Sell Stop at Pip Intervals (MQL4) |
//+------------------------------------------------------------------+
#property strict

extern double LotSize = 0.1;       // User-defined lot size
extern int OrderCount = 3;         // Number of Buy Stop/Sell Stop orders
extern int PipInterval = 1000;     // Interval in pips between orders
extern double BuyTriggerLevel = 3100; // Price level to trigger Buy Stop orders
extern double SellTriggerLevel = 3150; // Price level to trigger Sell Stop orders
extern int StopLossPips = 2000;      // Stop loss in pips
extern int WaitPips = 30;           // Wait 30 pips before placing orders

bool BuyTriggered = false;
bool SellTriggered = false;

double BuyStopTakeProfit;
double SellStopTakeProfit;

// Function to update chart comment
void UpdateChartMessage(string message) {
   Comment(message);
}

// Function to place Buy Stop orders
void SetBuyStops(double triggerPrice) {
   double price = triggerPrice + PipInterval * Point; // Start at the next Pip Interval
   double stopLoss = price - (StopLossPips * Point);
   double takeProfit = price + (30 * StopLossPips * Point);
   BuyStopTakeProfit = takeProfit;
   
   for (int i = 0; i < OrderCount; i++) {
      for (int j = 0; j < 3; j++) { // Open LotSize 3 times
         int ticket = OrderSend(Symbol(), OP_BUYSTOP, LotSize, price, 3, stopLoss, takeProfit, "Buy Stop Order", 0, 0, Blue);
         string msg;
         if (ticket > 0) {
            msg = "✅ Buy Stop order placed at " + DoubleToString(price, _Digits);
            Print("Buy Stop order placed at ", price);
            UpdateChartMessage(msg);
         } else {
            msg = "❌ Error placing Buy Stop order: " + IntegerToString(GetLastError());
            Print("Error placing Buy Stop order: ", GetLastError());
            UpdateChartMessage(msg);
         }
      }
      price += PipInterval * Point;
   }
}

// Function to place Sell Stop orders
void SetSellStops(double triggerPrice) {
   double price = triggerPrice - PipInterval * Point; // Start at the next Pip Interval
   double stopLoss = price + (StopLossPips * Point);
   double takeProfit = price - (30 * StopLossPips * Point);
   SellStopTakeProfit = takeProfit;
   
   for (int i = 0; i < OrderCount; i++) {
      for (int j = 0; j < 3; j++) { // Open LotSize 3 times
         int ticket = OrderSend(Symbol(), OP_SELLSTOP, LotSize, price, 3, stopLoss, takeProfit, "Sell Stop Order", 0, 0, Red);
         string msg;
         if (ticket > 0) {
            msg = "✅ Sell Stop order placed at " + DoubleToString(price, _Digits);
            Print("Sell Stop order placed at ", price);
            UpdateChartMessage(msg);
         } else {
            msg = "❌ Error placing Sell Stop order: " + IntegerToString(GetLastError());
            Print("Error placing Sell Stop order: ", GetLastError());
            UpdateChartMessage(msg);
         }
      }
      price -= PipInterval * Point;
   }
}

// Check if Buy Trigger Level is reached
void CheckBuyTrigger() {
   if (Bid >= BuyTriggerLevel - (WaitPips * Point) && Bid <= BuyTriggerLevel + (WaitPips * Point) && !BuyTriggered) {
      string msg = "🔥 Buy Trigger Activated at " + DoubleToString(BuyTriggerLevel, _Digits);
      Print("🔥 Buy Trigger Activated at ", BuyTriggerLevel);
      UpdateChartMessage(msg);
      SetBuyStops(BuyTriggerLevel);
      BuyTriggered = true;
   }
}

// Check if Sell Trigger Level is reached
void CheckSellTrigger() {
   if (Ask >= SellTriggerLevel - (WaitPips * Point) && Ask <= SellTriggerLevel + (WaitPips * Point) && !SellTriggered) {
      string msg = "🔥 Sell Trigger Activated at " + DoubleToString(SellTriggerLevel, _Digits);
      Print("🔥 Sell Trigger Activated at ", SellTriggerLevel);
      UpdateChartMessage(msg);
      SetSellStops(SellTriggerLevel);
      SellTriggered = true;
   }
}

//+------------------------------------------------------------------+
//| Expert initialization function                                  |
//+------------------------------------------------------------------+
int init() {
   string msg = "Bot Initialized: Monitoring price levels...";
   Print(msg);
   UpdateChartMessage(msg);
   return 0;
}

//+------------------------------------------------------------------+
//| Expert tick function                                            |
//+------------------------------------------------------------------+
void start() {
   CheckBuyTrigger();
   CheckSellTrigger();
}
