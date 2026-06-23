--ヴェルズ・アザトホース
-- 效果：
-- 反转：选择场上1只特殊召唤的怪兽回到持有者卡组。
function c42679662.initial_effect(c)
	-- 反转：选择场上1只特殊召唤的怪兽回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42679662,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c42679662.target)
	e1:SetOperation(c42679662.operation)
	c:RegisterEffect(e1)
end
-- 筛选满足条件的怪兽：特殊召唤且可以送入卡组
function c42679662.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsAbleToDeck()
end
-- 设置效果目标：选择场上1只满足条件的怪兽
function c42679662.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c42679662.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家提示“请选择要返回卡组的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c42679662.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果操作信息，指定将目标怪兽送入卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理函数：将目标怪兽送入卡组
function c42679662.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽送入卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
