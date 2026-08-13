--ペンデュラム・パラドックス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的额外卡组的表侧表示的灵摆怪兽之中选2只灵摆刻度相同而卡名不同的怪兽加入手卡。
function c38203732.initial_effect(c)
	-- ①：从自己的额外卡组的表侧表示的灵摆怪兽之中选2只灵摆刻度相同而卡名不同的怪兽加入手卡。且这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,38203732+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c38203732.target)
	e1:SetOperation(c38203732.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断候选怪兽c是否满足作为第一张卡的条件——自身是额外卡组表侧表示的灵摆怪兽且能加入手牌，并且额外卡组还存在另一张灵摆刻度相同、卡名不同的灵摆怪兽可作为第二张。
function c38203732.filter1(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
		-- 并检查额外卡组中是否存在至少1张与c灵摆刻度相同、卡名不同的另一只符合条件的灵摆怪兽。
		and Duel.IsExistingMatchingCard(c38203732.filter2,tp,LOCATION_EXTRA,0,1,c,c:GetLeftScale(),c:GetCode())
end
-- 过滤函数：判断候选怪兽c是否满足作为第二张卡的条件——与已选定的第一张卡灵摆刻度相同、卡名不同，且自身是额外卡组表侧表示的灵摆怪兽并能加入手牌。
function c38203732.filter2(c,sc,cd)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
		and c:GetLeftScale()==sc and not c:IsCode(cd)
end
-- 效果发动时的目标函数：检查是否满足发动条件（存在至少1组符合条件的怪兽），并设置将进行的“从额外卡组将2只怪兽加入手牌”的操作信息。
function c38203732.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查（chk==0）：确认额外卡组是否存在至少1只可以作为第一张卡的灵摆怪兽（即存在一对可选的怪兽），若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c38203732.filter1,tp,LOCATION_EXTRA,0,1,nil,tp) end
	-- 设置操作信息：本次效果处理将把2张卡从额外卡组加入持有者手牌（CATEGORY_TOHAND），供后续连锁判定和效果互动使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_EXTRA)
end
-- 效果处理阶段：先选择第一张符合条件的灵摆怪兽，再选择第二张与第一张灵摆刻度相同且卡名不同的灵摆怪兽，然后将两张一起加入手牌。
function c38203732.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给操作玩家发出选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从额外卡组中选取1只满足filter1的灵摆怪兽作为第一张选中的卡，并取出该卡（若未选择则返回nil）。
	local tc1=Duel.SelectMatchingCard(tp,c38203732.filter1,tp,LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
	if not tc1 then return end
	-- 再次发出选择提示，让玩家选择第二张要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从额外卡组中选取1只满足filter2的灵摆怪兽作为第二张选中的卡，filter2限定了其与第一张灵摆刻度相同、卡名不同，并排除tc1本身。
	local tc2=Duel.SelectMatchingCard(tp,c38203732.filter2,tp,LOCATION_EXTRA,0,1,1,tc1,tc1:GetLeftScale(),tc1:GetCode()):GetFirst()
	-- 将选中的两张灵摆怪兽以效果原因（REASON_EFFECT）送去其持有者的手牌。
	Duel.SendtoHand(Group.FromCards(tc1,tc2),nil,REASON_EFFECT)
end
