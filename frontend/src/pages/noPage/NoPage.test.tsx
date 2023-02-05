import { render, screen } from "@testing-library/react";
import NoPage from "./NoPage";

test("renders Page not found...", () => {
  render(<NoPage />);
  const linkElement = screen.getByText(/Page not found.../i);
  expect(linkElement).toBeInTheDocument();
});
