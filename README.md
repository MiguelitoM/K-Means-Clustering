# 📊 K-means Clustering in RISC-V

## 🔍 Project Overview

This project was developed for the *Introduction to Computer Architecture* course and implements the k-means clustering algorithm in **RISC-V assembly**. 

The goal is to take a set of 2D points and group them into **k clusters** based on proximity. The algorithm runs iteratively, updating cluster centroids and point assignments until a stopping condition is met.

Throughout the process, the program displays each step on a simulated 2D LED matrix — showing both the clusters and their centroids with distinct colors.

The final implementation is designed to run in the **Ripes simulator** using a 32-bit RISC-V processor, and all calculations are performed using integers only.

This project combines low-level programming with algorithmic reasoning to simulate a commonly used machine learning method from scratch.

