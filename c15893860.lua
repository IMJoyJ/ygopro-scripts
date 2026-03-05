--スノーマン・クリエイター
-- 效果：
-- ①：这张卡召唤·反转召唤·特殊召唤成功时才能发动。自己场上的水属性怪兽数量的冰指示物给对方场上的表侧表示怪兽放置。这个效果把冰指示物3个以上放置的场合，可以再选对方场上1张卡破坏。
function c15893860.initial_effect(c)
	-- 效果原文：①：这张卡召唤·反转召唤·特殊召唤成功时才能发动。自己场上的水属性怪兽数量的冰指示物给对方场上的表侧表示怪兽放置。这个效果把冰指示物3个以上放置的场合，可以再选对方场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15893860,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c15893860.target)
	e1:SetOperation(c15893860.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在表侧表示的水属性怪兽。
function c15893860.ctfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果的target函数，用于判断是否满足发动条件，即自己场上存在水属性怪兽且对方场上存在可放置指示物的怪兽。
function c15893860.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的水属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c15893860.ctfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少1只可放置冰指示物的怪兽。
		and Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x1015,1) end
end
-- 效果的operation函数，用于执行效果内容，包括放置冰指示物和可能的破坏对方卡片。
function c15893860.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上表侧表示的水属性怪兽数量，作为要放置的冰指示物数量。
	local ct=Duel.GetMatchingGroupCount(c15893860.ctfilter,tp,LOCATION_MZONE,0,nil)
	if ct==0 then return end
	-- 获取对方场上可放置冰指示物的怪兽数量。
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,nil,0x1015,1)
	if g:GetCount()==0 then return end
	for i=1,ct do
		-- 提示玩家选择要放置冰指示物的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		local tc=g:Select(tp,1,1,nil):GetFirst()
		tc:AddCounter(0x1015,1)
	end
	-- 当放置的冰指示物数量大于等于3时，询问玩家是否选择破坏对方场上的一张卡。
	if ct>=3 and Duel.SelectYesNo(tp,aux.Stringid(15893860,2)) then  --"是否要选择对方场上1张卡破坏？"
		-- 中断当前效果处理，使后续效果不会与当前效果同时处理。
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的对方场上的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上的一张卡作为破坏目标。
		local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		-- 显示被选中的卡作为破坏目标的动画效果。
		Duel.HintSelection(dg)
		-- 将选中的卡以效果原因破坏。
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
