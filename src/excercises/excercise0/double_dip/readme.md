![_dd](https://github.com/anubhav11156/Pharaonik/assets/86551390/f4ae97bb-4aa2-476e-9253-8f3712f4c4df)
# Double Dip
![Static Badge](https://img.shields.io/badge/Medium-orange?style=flat-square)  ![Static Badge](https://img.shields.io/badge/Reentrancy-blue?style=flat-square)  ![Static Badge](https://img.shields.io/badge/Double%20Spending-blue?style=flat-square)  ![Static Badge](https://img.shields.io/badge/Input%20Validation-blue?style=flat-square)

SubDeFi, a DeFi protocol, provides various markets for liquidity provision, allowing users to earn dynamic APR on their deposits. It issues sdTokens ( sdETH, sdBTC,  etc ) based on a rate, which represents  user deposits. These tokens can be redeemed to retrieve their deposited amounts along with the gains accumulated over time.

SubDeFi operates a router contract for user interactions and maintains multiple vault contracts for each market. Each market has its own liquid tokens and associated exchange rate.
However, the smart contract contains a severe bug that enables any exploiter to double their benefits. You have one task, exploiting this vulnerability!

### Objective
- You have deposited **5 ETH** into the ETH market. Your objective is to exploit the vulnerability present in the system, aiming to achieve a return of **10 ETH** —all within a **single transaction**.
### Instruction
- You have been allocated 5 ETH, and the ETH vault currently contains 1000 ETH.
- A [False ERC20](https://github.com/anubhav11156/Pharaonik/blob/main/src/excercises/excercise0/double_dip/false_erc_20.cairo) contract has been deployed to exploit the vulnerability. You are permitted to modify only its functions, without altering the constructor or storage struct.
- After modifying the False ERC20 contract, execute the pre-written [test](https://github.com/anubhav11156/Pharaonik/blob/main/tests/test_double_dip.cairo). The test will only succeed if you manage to acquire 10 ETH.
- Test Command :
    ```bash
     snforge test tests::test_double_dip::TestDoubleDip::test_exploit --exact
    ```
### Hint
- Examine the deposit flow meticulously, starting from the router, and scrutinize it for potential reentrancy exploits. Bugs are lurking! 
  
