require 'spec_helper'

describe DatabaseScriptsController do
  describe "forbidden actions" do
    context "when not signed in" do
      specify { expect(get(:index)).to redirect_to_signin_form }
      specify { expect(get(:show, params: { id: 1 })).to redirect_to_signin_form }
    end
  end
end
