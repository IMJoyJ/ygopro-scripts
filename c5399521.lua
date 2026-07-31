--音響戦士マイクス
-- 效果：
-- ←1 【灵摆】 1→
-- ①：另一边的自己的灵摆区域没有「音响战士」卡存在的场合，这张卡的灵摆刻度变成4。
-- ②：自己结束阶段，以除外的1只自己的「音响战士」怪兽为对象才能发动。那只怪兽加入手卡。
-- 【怪兽效果】
-- ①：这张卡可以把自己场上3个音响指示物取除，从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只怪兽召唤。
function c5399521.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以进行灵摆召唤
	aux.EnablePendulumAttribute(c)
	-- ①：另一边的自己的灵摆区域没有「音响战士」卡存在的场合，这张卡的灵摆刻度变成4。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_LSCALE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c5399521.slcon)
	e2:SetValue(4)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(e3)
	-- ②：自己结束阶段，以除外的1只自己的「音响战士」怪兽为对象才能发动。那只怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c5399521.thcon)
	e4:SetTarget(c5399521.thtg)
	e4:SetOperation(c5399521.thop)
	c:RegisterEffect(e4)
	-- ①：这张卡可以把自己场上3个音响指示物取除，从手卡特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_SPSUMMON_PROC)
	e5:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e5:SetRange(LOCATION_HAND)
	e5:SetCondition(c5399521.spcon)
	e5:SetOperation(c5399521.spop)
	c:RegisterEffect(e5)
	-- ②：这张卡召唤·特殊召唤成功的回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只怪兽召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_SUMMON_SUCCESS)
	e6:SetOperation(c5399521.sumop)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e7)
end
c5399521.mentioned_counter={
	[0x35]=true,
}
-- 判断是否为当前回合玩家
function c5399521.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return Duel.GetTurnPlayer()==tp
end
-- 定义过滤函数，用于筛选满足条件的「音响战士」怪兽
function c5399521.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1066) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果目标选择逻辑，选择除外区中的「音响战士」怪兽
function c5399521.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c5399521.thfilter(chkc) end
	-- 检查是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c5399521.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c5399521.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息，指定将目标怪兽送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果操作，将目标怪兽送入手牌并确认
function c5399521.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认被送入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 判断另一边的自己的灵摆区域是否有「音响战士」卡存在
function c5399521.slcon(e)
	-- 判断另一边的自己的灵摆区域是否有「音响战士」卡存在
	return not Duel.IsExistingMatchingCard(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,e:GetHandler(),0x1066)
end
-- 判断是否满足特殊召唤条件，包括场地空位和移除指示物
function c5399521.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查是否有足够的场上空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否可以移除3个音响指示物作为召唤代价
		and Duel.IsCanRemoveCounter(tp,1,0,0x35,3,REASON_COST)
end
-- 执行特殊召唤操作，移除3个音响指示物
function c5399521.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 移除3个音响指示物作为召唤代价
	Duel.RemoveCounter(tp,1,0,0x35,3,REASON_COST)
end
-- 设置额外召唤次数效果，使玩家在回合内可额外召唤一次
function c5399521.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否已使用过该效果
	if Duel.GetFlagEffect(tp,5399521)~=0 then return end
	-- 注册额外召唤次数效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(5399521,0))  --"使用「音响战士 麦克风」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将额外召唤次数效果注册到场上
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册标识效果，防止重复使用
	Duel.RegisterFlagEffect(tp,5399521,RESET_PHASE+PHASE_END,0,1)
end
