#pragma once

#include <iostream>

namespace test {

inline void fizz_buzz(unsigned int n) {
  for (unsigned int i = 1; i <= n; ++i) {
    if (i % 3 == 0 && i % 5 == 0) {
      std::cout << "FizzBuzz" << std::endl;
    } else if (i % 3 == 0) {
      std::cout << "Fizz" << std::endl;
    } else if (i % 5 == 0) {
      std::cout << "Buzz" << std::endl;
    } else {
      std::cout << i << std::endl;
    }
  }
}

inline auto factorial(int n) {
  if (n == 0 || n == 1) {
    return 1;
  } else {
    return n * factorial(n - 1);
  }
}

} // namespace test
