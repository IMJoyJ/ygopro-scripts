--隠されし機殻
-- 效果：
-- 「隐藏的机壳」在1回合只能发动1张。
-- ①：从自己的额外卡组把最多3只表侧表示的「机壳」灵摆怪兽加入手卡。
function c4450854.initial_effect(c)
	-- 效果原文：「隐藏的机壳」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,4450854+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c4450854.target)
	e1:SetOperation(c4450854.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择满足表侧表示、机壳系列、灵摆类型且能加入手卡的怪兽
function c4450854.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xaa) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 效果处理时点：检查自己额外卡组是否存在满足条件的怪兽
function c4450854.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己额外卡组是否存在至少1张满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c4450854.filter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁操作信息：准备将1张卡从额外卡组加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 效果发动处理：提示选择并选择最多3张满足条件的怪兽
function c4450854.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己额外卡组中最多3张满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c4450854.filter,tp,LOCATION_EXTRA,0,1,3,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽以效果原因加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选怪兽的卡面信息
		Duel.ConfirmCards(1-tp,g)
	end
end
