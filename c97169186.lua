--地砕き
-- 效果：
-- ①：对方场上1只守备力最高的怪兽破坏。
function c97169186.initial_effect(c)
	-- ①：对方场上1只守备力最高的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c97169186.target)
	e1:SetOperation(c97169186.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选对方场上表侧表示且守备力在0以上的怪兽
function c97169186.filter(c)
	return c:IsFaceup() and c:IsDefenseAbove(0)
end
-- 效果发动的目标确认与操作信息设置：检查对方场上是否存在符合条件的怪兽，并获取守备力最高的怪兽组以设置破坏操作信息
function c97169186.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查对方场上是否存在至少1只表侧表示且有守备力的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c97169186.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧表示且有守备力的怪兽组
	local g=Duel.GetMatchingGroup(c97169186.filter,tp,0,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetDefense)
	-- 设置操作信息：在连锁处理中，预计将破坏1张守备力最高的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
end
-- 效果处理：获取对方场上守备力最高的怪兽，若有多个则由发动玩家选择其中1只，最后将其破坏
function c97169186.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，重新获取对方场上所有表侧表示且有守备力的怪兽组
	local g=Duel.GetMatchingGroup(c97169186.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		local tg=g:GetMaxGroup(Card.GetDefense)
		if tg:GetCount()>1 then
			-- 给发动效果的玩家发送提示信息：“请选择要破坏的卡”
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 向双方玩家展示被选择的卡片
			Duel.HintSelection(sg)
			-- 因效果破坏被选中的那1只守备力最高的怪兽
			Duel.Destroy(sg,REASON_EFFECT)
		-- 若守备力最高的怪兽只有1只，则直接因效果破坏该怪兽
		else Duel.Destroy(tg,REASON_EFFECT) end
	end
end
