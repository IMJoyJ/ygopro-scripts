--創世の預言者
-- 效果：
-- ①：1回合1次，丢弃1张手卡，以自己墓地1只7星以上的怪兽为对象才能发动。那只怪兽加入手卡。
function c66337215.initial_effect(c)
	-- ①：1回合1次，丢弃1张手卡，以自己墓地1只7星以上的怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66337215,0))  --"7星以上的怪兽加入手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c66337215.thcost)
	e1:SetTarget(c66337215.thtg)
	e1:SetOperation(c66337215.thop)
	c:RegisterEffect(e1)
end
-- 定义发动代价：丢弃1张手卡
function c66337215.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查手牌中是否存在至少1张可以丢弃的卡（排除自身）
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 作为发动代价，从手牌中选择1张可以丢弃的卡丢弃到墓地
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：等级在7星以上且可以加入手牌的怪兽
function c66337215.filter(c)
	return c:IsLevelAbove(7) and c:IsAbleToHand()
end
-- 定义发动条件与对象选择（Target）
function c66337215.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c66337215.filter(chkc) end
	-- 在发动阶段（chk==0）检查自己墓地是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c66337215.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只满足过滤条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c66337215.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 定义效果处理（Operation）
function c66337215.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
