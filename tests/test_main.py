"""
tests/test_main.py
Pytest unit tests for the calculator application.
Each test exercises one function and covers both
the happy path and expected error conditions.
"""

import pytest

from app.main import add, divide, main, multiply, power, square_root, subtract


# ──────────────────────────────────────────────
# add()
# ──────────────────────────────────────────────
class TestAdd:
    def test_add_two_positive_integers(self) -> None:
        assert add(3, 4) == 7

    def test_add_negative_numbers(self) -> None:
        assert add(-5, -3) == -8

    def test_add_float_and_int(self) -> None:
        assert add(1.5, 2) == 3.5

    def test_add_zero(self) -> None:
        assert add(0, 0) == 0


# ──────────────────────────────────────────────
# subtract()
# ──────────────────────────────────────────────
class TestSubtract:
    def test_subtract_basic(self) -> None:
        assert subtract(10, 4) == 6

    def test_subtract_negative_result(self) -> None:
        assert subtract(2, 9) == -7

    def test_subtract_floats(self) -> None:
        assert subtract(5.5, 2.5) == 3.0


# ──────────────────────────────────────────────
# multiply()
# ──────────────────────────────────────────────
class TestMultiply:
    def test_multiply_positive(self) -> None:
        assert multiply(3, 7) == 21

    def test_multiply_by_zero(self) -> None:
        assert multiply(99, 0) == 0

    def test_multiply_negatives(self) -> None:
        assert multiply(-4, -3) == 12

    def test_multiply_float(self) -> None:
        assert multiply(2.5, 4) == 10.0


# ──────────────────────────────────────────────
# divide()
# ──────────────────────────────────────────────
class TestDivide:
    def test_divide_basic(self) -> None:
        assert divide(10, 2) == 5.0

    def test_divide_float_result(self) -> None:
        assert divide(7, 2) == 3.5

    def test_divide_by_zero_raises(self) -> None:
        with pytest.raises(ValueError, match="Cannot divide by zero"):
            divide(5, 0)

    def test_divide_negative(self) -> None:
        assert divide(-10, 2) == -5.0


# ──────────────────────────────────────────────
# power()
# ──────────────────────────────────────────────
class TestPower:
    def test_power_basic(self) -> None:
        assert power(2, 10) == 1024

    def test_power_zero_exponent(self) -> None:
        assert power(5, 0) == 1

    def test_power_float_base(self) -> None:
        assert power(2.0, 3) == 8.0

    def test_power_negative_exponent(self) -> None:
        assert power(2, -1) == 0.5


# ──────────────────────────────────────────────
# square_root()
# ──────────────────────────────────────────────
class TestSquareRoot:
    def test_sqrt_perfect_square(self) -> None:
        assert square_root(25) == 5.0

    def test_sqrt_zero(self) -> None:
        assert square_root(0) == 0.0

    def test_sqrt_float(self) -> None:
        assert abs(square_root(2.0) - 1.41421356) < 1e-5

    def test_sqrt_negative_raises(self) -> None:
        with pytest.raises(ValueError, match="negative number"):
            square_root(-9)


class TestMainCLI:

    def test_main_invalid_choice(self, monkeypatch: pytest.MonkeyPatch) -> None:
        # Simulate typing an invalid choice "9"
        monkeypatch.setattr("builtins.input", lambda _: "9")

        # Ensure it runs through and exits cleanly
        assert main() is None

    def test_main_square_root_happy_path(self, monkeypatch: pytest.MonkeyPatch) -> None:

        # Simulate selecting choice '6' then typing '16'
        inputs = iter(["6", "16"])

        monkeypatch.setattr("builtins.input", lambda _: next(inputs))

        assert main() is None

    def test_main_square_root_error_path(self, monkeypatch: pytest.MonkeyPatch) -> None:

        # Simulate selecting choice '6' then typing negative number '-4'
        inputs = iter(["6", "-4"])

        monkeypatch.setattr("builtins.input", lambda _: next(inputs))

        assert main() is None

    def test_main_two_argument_operation_happy_path(
        self, monkeypatch: pytest.MonkeyPatch
    ) -> None:

        # Simulate selecting addition '1',
        # entering '10', then '20'

        inputs = iter(["1", "10", "20"])

        monkeypatch.setattr("builtins.input", lambda _: next(inputs))

        assert main() is None

    def test_main_two_argument_operation_value_error(
        self, monkeypatch: pytest.MonkeyPatch
    ) -> None:

        # Simulate selecting addition '1',
        # entering invalid numeric string 'abc'

        inputs = iter(["1", "abc"])

        monkeypatch.setattr("builtins.input", lambda _: next(inputs))

        assert main() is None
