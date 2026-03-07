--ペンデュラム・パラドックス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的额外卡组的表侧表示的灵摆怪兽之中选2只灵摆刻度相同而卡名不同的怪兽加入手卡。
function c38203732.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,38203732+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c38203732.target)
	e1:SetOperation(c38203732.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查额外卡组中是否存在满足条件的灵摆怪兽（表侧表示、灵摆类型、可送入手卡，并且存在另一张满足条件的灵摆怪兽）
function c38203732.filter1(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
		-- 效果作用：检查是否存在一张灵摆怪兽与当前选中的怪兽刻度相同且卡名不同
		and Duel.IsExistingMatchingCard(c38203732.filter2,tp,LOCATION_EXTRA,0,1,c,c:GetLeftScale(),c:GetCode())
end
-- 效果作用：检查额外卡组中是否存在满足条件的灵摆怪兽（表侧表示、灵摆类型、可送入手卡、刻度等于sc、卡名不等于cd）
function c38203732.filter2(c,sc,cd)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
		and c:GetLeftScale()==sc and not c:IsCode(cd)
end
-- 效果原文内容：①：从自己的额外卡组的表侧表示的灵摆怪兽之中选2只灵摆刻度相同而卡名不同的怪兽加入手卡。
function c38203732.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否满足发动条件，即额外卡组中是否存在至少一张满足filter1条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c38203732.filter1,tp,LOCATION_EXTRA,0,1,nil,tp) end
	-- 效果作用：设置连锁操作信息，表示将要处理2张灵摆怪兽送入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_EXTRA)
end
-- 效果作用：执行效果处理，选择并送入手卡2只符合条件的灵摆怪兽
function c38203732.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 效果作用：从额外卡组中选择一张满足filter1条件的灵摆怪兽
	local tc1=Duel.SelectMatchingCard(tp,c38203732.filter1,tp,LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
	if not tc1 then return end
	-- 效果作用：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 效果作用：从额外卡组中选择一张与tc1刻度相同且卡名不同的灵摆怪兽
	local tc2=Duel.SelectMatchingCard(tp,c38203732.filter2,tp,LOCATION_EXTRA,0,1,1,tc1,tc1:GetLeftScale(),tc1:GetCode()):GetFirst()
	-- 效果作用：将选中的2只灵摆怪兽以效果原因送入手卡
	Duel.SendtoHand(Group.FromCards(tc1,tc2),nil,REASON_EFFECT)
end
