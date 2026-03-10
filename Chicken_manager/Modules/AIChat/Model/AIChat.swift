import Foundation

struct AIChat: Identifiable, Equatable {
    let id: UUID
    var messages: [Message]
    
    init(isMock: Bool) {
        self.id = UUID()
        
        let text = """
            # How to Raise Chickens

            Raising chickens is a practical way to produce **eggs**, **meat**, or both, but it requires proper housing, nutrition, and consistent daily care.

            ---

            ## 1. Define Your Goal

            Before starting, decide why you are raising chickens:

            - **Egg production**
            - **Meat production**
            - **Dual-purpose (eggs and meat)**

            Your goal determines the breed, feed type, and overall management strategy.

            ---

            ## 2. Prepare the Coop

            Chickens need a **safe, dry, and predator-proof** shelter.

            **Space requirements:**

            - **3–4 sq ft per bird (indoors)**
            - **8–10 sq ft per bird (outdoor run)**

            **Essential coop elements:**

            - Good **ventilation** (without strong drafts)
            - **Roosting bars** for sleeping
            - **Nest boxes** (1 per 3–4 hens)
            - Clean bedding (**straw** or **wood shavings**)

            Keep the coop clean and dry to reduce disease risk.

            ---

            ## 3. Raising Chicks (0–6 Weeks)

            If starting with baby chicks:

            - Use a **heat lamp**
            - Week 1 temperature: **95°F (35°C)**
            - Reduce temperature by **5°F each week**
            - Remove heat once fully feathered

            Provide **chick starter feed** and fresh water at all times.

            ---

            ## 4. Feeding by Age

            **0–6 weeks:**  
            - Starter feed (**20–22% protein**)

            **6–18 weeks:**  
            - Grower feed (**16–18% protein**)

            **18+ weeks (laying hens):**  
            - Layer feed with added **calcium**

            Always ensure **constant access to clean water**.

            ---

            ## 5. Health & Maintenance

            - Clean the coop **regularly**
            - Remove **wet bedding**
            - Watch for signs of illness: **weakness, coughing, diarrhea, loss of appetite**
            - **Isolate sick birds** immediately

            ---

            ## 6. Production Timeline

            - **Meat chickens:** Ready in **6–8 weeks**
            - **Egg-laying hens:** Start at **18–24 weeks**
            - Average production: **4–6 eggs per week per hen**

            ---

            ## 7. Check Local Regulations

            Before starting, verify that **backyard chickens are allowed** in your area.
            """
        self.messages = isMock ? [Message(isMock: true)] : []
    }
}
