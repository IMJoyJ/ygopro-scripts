--青い忍者
-- 效果：
-- ①：这张卡反转的场合，以场上1张表侧表示的魔法卡或者场上盖放的1张魔法·陷阱卡为对象发动。那张魔法卡破坏（那张卡在场上盖放中的场合，翻开确认）。
function c9076207.initial_effect(c)
	-- ①：这张卡反转的场合，以场上1张表侧表示的魔法卡或者场上盖放的1张魔法·陷阱卡为对象发动。那张魔法卡破坏（那张卡在场上盖放中的场合，翻开确认）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9076207,0))  --"魔法破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c9076207.target)
	e1:SetOperation(c9076207.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上里侧表示的卡（盖放的卡）或者是魔法卡
function c9076207.filter(c)
	return c:IsFacedown() or c:IsType(TYPE_SPELL)
end
-- 效果①的发动准备：进行对象选择，若选择的对象为表侧表示则设置破坏的操作信息
function c9076207.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c9076207.filter(chkc) end
	if chk==0 then return true end
	-- 给玩家发送提示信息：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择双方魔法与陷阱区域内1张满足过滤条件的卡作为效果的对象
	local g=Duel.SelectTarget(tp,c9076207.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	if g:GetCount()>0 and g:GetFirst():IsFaceup() then
		-- 若选择的对象是表侧表示（即确定为魔法卡），则设置破坏该卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果①的处理：获取对象卡，若为里侧表示则翻开确认，若确认是魔法卡则将其破坏
function c9076207.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 如果对象卡处于里侧表示（盖放状态），则翻开给双方玩家确认
		if tc:IsFacedown() then Duel.ConfirmCards(tp,tc) end
		-- 如果该卡是魔法卡，则将其破坏
		if tc:IsType(TYPE_SPELL) then Duel.Destroy(tc,REASON_EFFECT) end
	end
end
