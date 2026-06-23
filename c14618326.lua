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
-- 过滤满足条件的魔法·陷阱卡，包括表侧表示的陷阱卡和里侧表示的魔法·陷阱卡（不包括场地魔法）
function c14618326.filter(c)
	return c:IsType(TYPE_TRAP) or (c:IsFacedown() and c:IsLocation(LOCATION_SZONE) and c:GetSequence()~=5)
end
-- 设置效果目标，选择场上满足条件的1张魔法·陷阱卡作为对象
function c14618326.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c14618326.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择满足条件的1张魔法·陷阱卡作为目标
	local g=Duel.SelectTarget(tp,c14618326.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 and g:GetFirst():IsFaceup() then
		-- 设置操作信息，确定将要破坏的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果处理函数，执行破坏操作
function c14618326.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 如果目标卡是里侧表示，则翻开确认
		if tc:IsFacedown() then Duel.ConfirmCards(tp,tc) end
		-- 如果目标卡是陷阱卡，则将其破坏
		if tc:IsType(TYPE_TRAP) then Duel.Destroy(tc,REASON_EFFECT) end
	end
end
