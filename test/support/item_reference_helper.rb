module ItemReferenceHelper
  def add_single_reference(id, name)
    within(id) do
      find(".css-g1d714-ValueContainer").click # Click on the filter input
      sleep(2)

      within(".css-4ljt47-MenuList") do # Within the filter list
        find('div', text: name, match: :first, visible: false).click
      end
    end
    find("body").click
  end

  def add_multiple_reference(id, name)
    assert(page.has_css?("#{id} div.item"), :wait => 30)
    page.execute_script(
      "Array.from(document.querySelectorAll(" \
      "'#{id} div.availableReferences div'" \
      ")).find(el => el.textContent === '#{name}').click();"
    )
  end
end
