--伊弉波
-- 效果：
-- 这张卡不能特殊召唤。召唤·反转的回合的结束阶段时回到持有者手卡。这张卡召唤·反转时，可以丢弃1张手卡把自己墓地存在的1只灵魂怪兽加入手卡。
function c43543777.initial_effect(c)
	-- 为卡片添加在召唤或反转成功时回到手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡无法被特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 召唤·反转时，可以丢弃1张手卡把自己墓地存在的1只灵魂怪兽加入手卡
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(43543777,1))  --"把自己墓地存在的1只灵魂怪兽加入手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetCost(c43543777.thcost)
	e4:SetTarget(c43543777.thtg)
	e4:SetOperation(c43543777.thop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP)
	c:RegisterEffect(e5)
end
-- 定义筛选灵魂怪兽的条件：类型为灵魂且能加入手牌
function c43543777.filter(c)
	return c:IsType(TYPE_SPIRIT) and c:IsAbleToHand()
end
-- 支付效果代价：丢弃1张手卡
function c43543777.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃1张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 设置效果目标：选择墓地1只灵魂怪兽
function c43543777.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c43543777.filter(chkc) end
	-- 检查是否满足选择墓地灵魂怪兽的条件
	if chk==0 then return Duel.IsExistingTarget(c43543777.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标：从自己墓地选择1只灵魂怪兽
	local g=Duel.SelectTarget(tp,c43543777.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息：将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果操作：将目标怪兽加入手牌并确认对方见卡
function c43543777.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认目标怪兽的卡面
		Duel.ConfirmCards(1-tp,tc)
	end
end
