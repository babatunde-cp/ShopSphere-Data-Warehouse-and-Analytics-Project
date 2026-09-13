# ShopSphere — Analytical Insights & Recommendations

## Executive Summary

Between January 2023 and December 2024, ShopSphere generated **$9.48M in total revenue** across **60,331 orders** (75,675 order lines) spanning two channels — website and mobile app — and four markets: the United States, United Kingdom, Germany, and France.

This analysis covers four strategic areas: customer segmentation, product association, promotional effectiveness, and advertising allocation.

---

## 1. Revenue & Channel Performance

The website is the dominant channel, driving **$6.4M (67.6%)** of revenue against the app's **$3.07M (32.4%)**. Website AOV also leads at **$131.59** versus the app's **$113.86** — a gap that holds in every month of the dataset.

Both years show two clear seasonal peaks — **November and December** — with November 2023 ($545K) and December 2024 ($614K) as the highest-revenue months. This Q4 concentration holds across every channel and market.

**Recommendation:** Start Q4 campaign planning no later than September. Reallocating budget toward Q4 activations — especially in high-AOV categories — should deliver the strongest return, given how concentrated demand already is in that window.

---

## 2. Geographic Performance

The US leads with **$6.39M (67.4%)** of revenue, followed by the UK at **$1.91M (20.2%)**, Germany at **$764K (8.1%)**, and France at **$414K (4.4%)**.

The standout figure is UK website AOV — **$170.61**, the highest of any country-channel combination in the dataset, well above the US website AOV of $127.26. UK customers are either buying higher-value products or larger baskets per order.

**Recommendation:** The UK is underinvested relative to its value signal. A UK conversion is worth more than a conversion anywhere else in the dataset — targeted acquisition spend here, particularly on the website channel, should outperform.

---

## 3. Customer Segmentation — RFM Analysis

**22,155 registered customers** were segmented into nine RFM tiers.

### Revenue concentration
**Champions** (2,261 customers) and **Loyals** (3,744 customers) together drive **$4.2M — 44.6% of total revenue from just 27% of customers**. Champions average 5.3 orders and $922 per customer; Loyals average 3.9 orders and $565 per customer.

### At-risk revenue
**At Risk** customers (3,694) haven't ordered in an average of 328 days but have historically spent $376 each — **$1.39M** in relationships at risk of lapsing. **Lost** customers (2,443) average 564 days since last order at only $89 average spend — recovery here is unlikely to be worth the cost.

### Growth opportunity
**Potential Loyalists** (2,577 customers, $1.6M revenue) and **New Customers** (2,857 customers, $657K revenue) are the clearest conversion opportunity. New Customers average only 1.5 orders — the acquisition pipeline is working, but repeat-purchase behavior hasn't taken hold yet.

### Cross-channel insight
Customers active on **both** channels skew heavily toward Champion and Loyal status — 1,847 Champions and 2,619 Loyals shop cross-channel. Single-channel customers dominate the Lost, At Risk, and New Customer segments.

**Recommendations:**
- Protect Champions and Loyals with exclusive access, early launches, and loyalty rewards — not discounts. Their spend is already high, and promos here just erode margin.
- Re-engage At Risk customers before they lapse into Lost. At 328 days average recency, many are still recoverable with a single well-timed, personalized touchpoint.
- Prioritize converting New Customers to repeat buyers within their first 60 days — a structured post-purchase sequence (email, push, personalized offer) targeting all 2,857 of them.
- Treat cross-channel acquisition as the highest-leverage growth lever available: cross-channel customers generate **$607.69 revenue per customer**, versus **$339.43** website-only and **$177.75** app-only — a 2–3x uplift for moving someone from one channel to both.

---

## 4. Market Basket Analysis

Website orders average **1.46 items per basket** at **$192.16** average basket value — with 80 products across 6 categories, most customers are shopping across categories rather than stacking within one.

### Strongest product associations (by lift)

| Product A | Product B | Lift |
|---|---|---|
| Soccer Ball Professional | Bike Lock Heavy Duty | 1.69 |
| Women's Yoga Pants | Python Programming for Beginners | 1.54 |
| Storage Bins Set | Basketball Official Size | 1.48 |
| Air Fryer 5-Quart | Table Lamp Modern | 1.47 |
| Jump Rope Speed | Bike Lock Heavy Duty | 1.47 |

Lift above 1.5 is meaningful at this dataset size — Soccer Ball + Bike Lock at 1.69 is the strongest pairing in the catalogue.

### Strongest category associations (by support)

| Category A | Category B | Support |
|---|---|---|
| Electronics | Fashion | 4.21% |
| Fashion | Sports | 4.02% |
| Fashion | Home & Kitchen | 3.64% |
| Electronics | Sports | 3.63% |
| Home & Kitchen | Sports | 3.37% |

Electronics + Fashion is the most common cross-category pairing, appearing in 4.21% of all website orders.

**Recommendations:**
- Surface the top lift pairs in on-site product recommendations at cart and checkout. Soccer Ball + Bike Lock (1.69) and Yoga Pants + Programming Book (1.54) are non-obvious, cross-category signals a human merchandiser likely wouldn't spot on their own.
- Build bundle promotions around the Electronics + Fashion and Fashion + Sports pairings — the highest-support category combinations, with a clear data-backed audience for a "Tech + Lifestyle" or "Sport + Style" campaign.
- Lifting average basket size from 1.46 to 1.6 items through recommendation-driven cross-sells would add roughly $28/order — across 33,331 website orders, that's an estimated **~$930K in incremental annual revenue** with no new customer acquisition required.

---

## 5. Promotional Effectiveness

Promo codes applied to **19.05%** of mobile app orders, generating **$592,890** in revenue. The key finding: promos aren't producing meaningful AOV uplift.

| | Orders | AOV | Revenue |
|---|---|---|---|
| No Promo | 21,856 (80.95%) | $113.53 | $2,481,394 |
| Promo Applied | 5,144 (19.05%) | $115.26 | $592,890 |

The AOV gap between promo and non-promo orders is **$1.73** — functionally insignificant. Customers are largely applying codes to purchases they were already going to make.

### By promo type

| Promo Type | Redemptions | AOV | Estimated Discount Given |
|---|---|---|---|
| Other | 2,088 | $117.05 | $15,699 |
| Seasonal | 765 | $118.28 | $5,726 |
| Welcome | 729 | $120.20 | $5,337 |
| VIP | 815 | $104.91 | $6,255 |
| Flash | 747 | $113.62 | $5,710 |

VIP30 has the most redemptions (815) but the **lowest AOV** ($104.91) — a 30% discount is pulling in the most price-sensitive customers while delivering the least value per order. Welcome15 has both the highest AOV ($120.20) and the lowest discount cost ($5,337) — the most efficient code in the portfolio.

### By customer tier

High-value customers (top 20%) show **$170.34 AOV with a promo** versus **$164.23 without** — a marginal lift. This segment spends at a high level regardless of the promo.

**Recommendations:**
- **Restructure VIP30.** It's the weakest performer by value efficiency — 815 redemptions at only $104.91 AOV. Replace the blanket 30% discount with a tiered reward (bonus product, free shipping, early access) that drives engagement without eating margin.
- **Scale Welcome15.** At $120.20 AOV and only $5,337 in total discount cost, it's the most efficient acquisition code — expand its reach in onboarding.
- **Stop discounting Champions and Loyals.** High-value customers spend nearly the same with or without a promo, so every discount to this segment is pure margin loss. Reserve promos for At Risk re-engagement and New Customer conversion, where the incentive is more likely to actually change behavior.
- **Test removing promos on high-AOV categories.** Home & Kitchen promo orders already average $149–167 AOV — these customers likely convert without a discount. An A/B test removing the promo and tracking conversion impact would confirm this before assuming it's needed.

---

## 6. $500K Ad Spend Recommendation

All allocations below are revenue-proportional, derived directly from two years of transaction data.

### By channel

| Channel | Revenue Share | Recommended Budget |
|---|---|---|
| Website | 67.57% | **$337,842** |
| Mobile App | 32.43% | **$162,158** |

The website earns the majority of budget on 2x the revenue and a 16% AOV advantage. But the app's 32% share is more than proportional value — cross-channel customers, who skew heavily app-active, generate 3.4x the revenue of app-only customers. App spend is partly a website revenue investment in disguise.

### By geography

| Market | Revenue Share | Recommended Budget |
|---|---|---|
| United States | 67.39% | **$336,943** |
| United Kingdom | 20.17% | **$100,864** |
| Germany | 8.07% | **$40,331** |
| France | 4.37% | **$21,863** |

The US takes the largest share by volume. The UK's $100,864 should skew toward website acquisition, given its $170.61 website AOV — the highest in the dataset.

### By device (mobile app budget)

| Device | Revenue Share | Recommended Budget |
|---|---|---|
| iOS | 57.55% | **$287,728** |
| Android | 42.45% | **$212,272** |

iOS drives 57.6% of app revenue — App Store and iOS-targeted placements should take the majority of mobile spend.

### By category

| Category | Revenue Share | Recommended Budget |
|---|---|---|
| Home & Kitchen | 21.96% | **$109,810** |
| Fashion | 21.72% | **$108,579** |
| Sports | 20.13% | **$100,657** |
| Electronics | 19.17% | **$95,859** |
| Beauty | 10.51% | **$52,556** |
| Books | 6.51% | **$32,539** |

The top four categories sit within a tight 2.8% revenue-share band — no single one dominates, so category-level cuts carry real revenue risk. Home & Kitchen, at $160.67 AOV, is the highest-value category per order and earns the top allocation. Books, at $72.81 AOV, is the lowest and should be watched for efficiency.

### Strategic overlay

Three high-conviction moves stand out within the $500K:

1. **Over-index on UK website acquisition.** The $100K UK allocation should skew disproportionately toward the website channel — the $170.61 AOV signal points to the highest-value customer profile in the dataset.
2. **Retarget iOS users across channels.** The highest-value customers are cross-channel, and iOS accounts for 57.5% of app revenue. A retargeting push converting iOS-only app users to also engage the website (or vice versa) targets the segment with the clearest upside.
3. **Frontload Q3 for Q4 payoff.** November and December consistently carry a disproportionate share of annual revenue. Shifting budget into Q3 brand-building (July–September) primes demand ahead of the Q4 spike — the most efficient use of the annual cycle.

---

**Analysis based on 76,685 order lines | January 2023 – December 2024 | ShopSphere E-Commerce**
**All revenue figures in USD using fixed conversion rates: GBP × 1.27, EUR × 1.08**
