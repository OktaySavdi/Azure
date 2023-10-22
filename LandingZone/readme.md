**What is an Azure landing zone?** 

An Azure landing zone is an environment that follows key design principles across eight design areas. These design principles accommodate all application portfolios and enable application migration,
modernization, and innovation at scale. An Azure landing zone uses subscriptions to isolate and scale application resources and platform resources. 
Subscriptions for application resources are called application landing zones, and subscriptions for platform resources are called platform landing zones.

![image](https://github.com/OktaySavdi/Azure/assets/3519706/98dcbf87-8c66-4f25-9699-9b2876490138)

Design areas: The conceptual architecture illustrates the relationships between its eight design areas. 
These design areas are Azure billing and Microsoft Entra tenant (A), identity and access management (B), 
resource organization (C), network topology and connectivity (E), security (F), management (D, G, H), governance (C, D), and platform automation and DevOps (I).
For more information on the design areas, see the Azure Landing Zone environment design areas.

### Platform landing zones vs. application landing zones

An Azure landing zone consists of platform landing zones and application landing zones. It's worth explaining the function of both in more detail.

**Platform landing zone:**

A platform landing zone is a subscription that provides shared services (identity, connectivity, management) to applications in application landing zones. 
Consolidating these shared services often improves operational efficiency. One or more central teams manage the platform landing zones. 
In the conceptual architecture (see figure 1), the "Identity subscription", "Management subscription", and "Connectivity subscription" represent three different platform landing zones. 
The conceptual architecture shows these three platform landing zones in detail. It depicts representative resources and policies applied to each platform landing zone.

**Application landing zone:** 

An application landing zone is a subscription for hosting an application. 
You pre-provision application landing zones through code and use management groups to assign policy controls to them. In the conceptual architecture (see figure 1), 
the "Landing zone A1 subscription" and "Landing zone A2 subscription" represent two different application landing zones. The conceptual architecture shows only the "Landing zone A2 subscription" in detail. 
It depicts representative resources and policies applied to the application landing zone.

URL -  https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/ 
