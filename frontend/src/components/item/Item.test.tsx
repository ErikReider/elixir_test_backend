import { render, screen, fireEvent } from "@testing-library/react";
import Item from "./Item";
import Mocks from "../../mockData";

test("callback fired on click", () => {
  const handleClick = jest.fn();
  render(<Item beer={Mocks.MOCK_BEER_1} clickCb={handleClick} />);
  fireEvent.click(screen.getByText("Trashy Blonde"));
  expect(handleClick).toHaveBeenCalledTimes(1);
  expect(handleClick).toHaveBeenCalledWith(Mocks.MOCK_BEER_1);
});

test("images are correct", () => {
  render(<Item beer={Mocks.MOCK_BEER_1} clickCb={(_beer) => {}} />);

  const img = screen.getByRole("img") as HTMLImageElement;

  expect(img).toBeInTheDocument();
  expect(img.src).toBe("https://images.punkapi.com/v2/2.png");
  expect(img.alt).toBe("Image of Trashy Blonde");
});

test("texts exist", () => {
  render(<Item beer={Mocks.MOCK_BEER_1} clickCb={(_beer) => {}} />);

  const title1 = screen.getByText("Trashy Blonde");
  expect(title1).toBeInTheDocument();
  const sub1 = screen.getByText("4.1% · You Know You Shouldn't");
  expect(sub1).toBeInTheDocument();
});
