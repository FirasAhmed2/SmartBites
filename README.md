

Software Engineering – Sprint 1 Report  

 

 

<Recipe Finder> 

<3> 

<Ahly> 

ID 

Name 

22016668 

Omar Nader 

2200081 

Firas Ahmed 

2200780 

Abdelrahman Tag Eldin 

2400003 

Selim Hafez 

 



 

 

 

 

 

 

 

 

 

 

​​

​ 

​ 

​ 

​ 

​ 

​​ 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

Introduction 

Project Overview 

 

Our SmartBites application is designed to provide a vast selection of recipes tailored to each and every user’s need. These needs could be healthy, dietary, medical, or influencer recipes. This application doesn’t just offer a recipe for each specific request from the user, but it also delivers the ingredients all the way to the users’ home. This makes it easy for users to find the recipe they want without having to worry about what ingredients they’ll be able to find from their local supermarkets. This makes it a no-effort app for the user, targeting to solve all missing functionalities from similar applications/websites. 

 

Target Audience  

Food hobbyists. 

Home Cooks. 

Busy families who are looking for a quick recipe during tight schedules. 

Fans of influencers. 

Fans of food trends. 

People that are part of the fitness community. 

Patients who need to adhere to strict food regiments (Medical). 

People who are looking for diets to follow. 

College students. 

 

Functional Requirements: 

Register new users. 

Login users. 

Subscription plans. 

Provide an interface for users. 

Searching and Filtering results (dietary, cooking time, and level of difficulty). 

Nutritional information of recipe (calories, macronutrients, etc). 

Record users’ favorite recipes. 

Allow users to like recipes they enjoyed (add to favorites). 

Load recipe pictures. 

Recipe Instructions. 

User reviews on recipes. 

Notifications and alerts. 

Customer support. 

Two-factor authentication. 

Allows several language options. 

 

Non-Functional Requirement: 

Save user credentials to a database 

Recipes load within 2 seconds. 

App should be able to handle 1,000 users at the same time before there’s a system slowdown. 

Checking out and paying should not take more than 6 seconds. 

Api response time should range from 0.1-1 seconds. 

As the business grows so should the ability for the system to handle more users while also maintaining the quality of the system. 

If the system fails, there’s a background server that activates within 3 minutes. 

Users can still access and add recipes to their cart/plan even if delivery is down. 

Secure payments. 

Auto logouts if user is inactive for a period of time.  

Very easy-to-use UI with very little learning curves. 

Enables dark mode. 

Compatible for all platforms. 

Database backups every 24 hours 

RTO should be a maximum of 2 downtime in case failure occurs. 

RPO should be a maximum of 30 minutes of data loss. 

Chosen Technology-Stack & platform  

This app will be entirely built using Flutter and Firebase for the database. Flutter allows for easy cross-platform development and offers ease of usability with it’s hot reload feature. It also offers many widget and theme packages giving the user and Opportunity to create user-friendly and visually pleasing UI. Firebase provides a cloud-based NoSQL database making it easy to store and sync recipes in real-time. Firebase also offers built-in authentication systems with google Facebook and email login, and the ability to engage with users using the Firebase Cloud Messaging feature which can be used to send users recipe recommendations using push notifications. 

 
