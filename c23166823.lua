--影霊獣使い－セフィラウェンディ
-- 效果：
-- ←7 【灵摆】 7→
-- ①：自己不是「灵兽」怪兽以及「神数」怪兽不能灵摆召唤。这个效果不会被无效化。
-- 【怪兽效果】
-- 自己对「影灵兽使-神数文蒂」1回合只能有1次特殊召唤。
-- ①：这张卡召唤·灵摆召唤时才能发动。从自己的额外卡组（表侧）把「影灵兽使-神数文蒂」以外的1只「神数」怪兽加入手卡。
function c23166823.initial_effect(c)
	c:SetSPSummonOnce(23166823)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「灵兽」怪兽以及「神数」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c23166823.splimit)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤·灵摆召唤时才能发动。从自己的额外卡组（表侧）把「影灵兽使-神数文蒂」以外的1只「神数」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetTarget(c23166823.thtg)
	e3:SetOperation(c23166823.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c23166823.condition)
	c:RegisterEffect(e4)
end
-- 设置灵摆召唤限制条件，只有非「灵兽」和「神数」怪兽不能进行灵摆召唤
function c23166823.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0xb5,0xc4) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 判断该怪兽是否为灵摆召唤成功
function c23166823.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 过滤函数，筛选满足条件的「神数」灵摆怪兽（不包括自身）
function c23166823.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xc4) and c:IsType(TYPE_PENDULUM) and not c:IsCode(23166823) and c:IsAbleToHand()
end
-- 设置效果发动时的处理信息，确定将从额外卡组选择1只怪兽加入手牌
function c23166823.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即自己额外卡组存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c23166823.filter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁操作信息，指定效果处理时将把1张卡从额外卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数，提示玩家选择要加入手牌的卡并执行加入手牌操作
function c23166823.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从额外卡组中选择1张符合条件的卡
	local g=Duel.SelectMatchingCard(tp,c23166823.filter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
