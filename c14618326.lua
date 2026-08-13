--赤い忍者
-- 效果：
-- ①：这张卡反转的场合，以场上1张表侧表示的陷阱卡或者场上盖放的1张魔法·陷阱卡为对象发动。那张陷阱卡破坏（那张卡在场上盖放中的场合，翻开确认）。
function c14618326.initial_effect(c)
	-- ①：这张卡反转的场合，以场上1张表侧表示的陷阱卡或者场上盖放的1张魔法·陷阱卡为对象发动。那张陷阱卡破坏（那张卡在场上盖放中的场合，翻开确认）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14618326,0))  --"陷阱破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c14618326.target)
	e1:SetOperation(c14618326.operation)
	c:RegisterEffect(e1)
end
-- 选择对象用的过滤器：可选的卡必须是表侧表示的陷阱卡，或是里侧表示且位于魔法与陷阱区域（不含场地魔法区域的里侧魔法·陷阱卡）。
function c14618326.filter(c)
	return c:IsType(TYPE_TRAP) or (c:IsFacedown() and c:IsLocation(LOCATION_SZONE) and c:GetSequence()~=5)
end
-- 发动时的目标选择处理：效果发动时选择场上1张符合条件的魔法·陷阱卡作为对象，并根据对象是否为表侧表示设置对应的破坏操作信息。
function c14618326.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c14618326.filter(chkc) end
	if chk==0 then return true end
	-- 向当前玩家显示“请选择要破坏的卡”的提示文字，用于选择对象时的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1张满足过滤条件的卡作为效果对象，此处为取对象效果。
	local g=Duel.SelectTarget(tp,c14618326.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 and g:GetFirst():IsFaceup() then
		-- 若选择的对象是表侧表示，则设置破坏效果的操作信息，使该对象加入破坏相关的效果处理；里侧对象因种类未确认，暂不设置破坏信息。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果处理时的操作：先取得对象卡，确认对象仍与此效果有关；若对象里侧则翻开确认，最后若对象是陷阱卡则将其破坏。
function c14618326.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取这张卡发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 若对象卡处于里侧表示，则向当前玩家展示该卡，以确认其卡面信息。
		if tc:IsFacedown() then Duel.ConfirmCards(tp,tc) end
		-- 若对象卡是陷阱卡，则将其以效果破坏送入墓地。
		if tc:IsType(TYPE_TRAP) then Duel.Destroy(tc,REASON_EFFECT) end
	end
end
