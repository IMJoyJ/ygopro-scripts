--伊弉波
-- 效果：
-- 这张卡不能特殊召唤。召唤·反转的回合的结束阶段时回到持有者手卡。这张卡召唤·反转时，可以丢弃1张手卡把自己墓地存在的1只灵魂怪兽加入手卡。
function c43543777.initial_effect(c)
	-- 为伊奘波注册灵魂怪兽特有的回归效果：在它召唤或反转成功的回合的结束阶段时，强制回到持有者手卡。
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件判定值设定为恒 false，使这张卡永远无法被特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 这张卡召唤·反转时，可以丢弃1张手卡把自己墓地存在的1只灵魂怪兽加入手卡。
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
-- 定义筛选条件：这张卡必须是灵魂怪兽并且能够被加入手卡。
function c43543777.filter(c)
	return c:IsType(TYPE_SPIRIT) and c:IsAbleToHand()
end
-- 定义效果发动所需支付的代价：丢弃自己 1 张手卡。
function c43543777.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价判定阶段检查手牌中是否存在至少 1 张可丢弃的手卡（不包括伊奘波自身）。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择并丢弃自己的 1 张手卡，作为发动效果的代价。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义目标选择阶段：以自己墓地的 1 只灵魂怪兽为对象，并设置将其加入手卡的操作信息。
function c43543777.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c43543777.filter(chkc) end
	-- 目标判定阶段检查自己墓地是否存在至少 1 只满足条件且能成为效果对象的灵魂怪兽。
	if chk==0 then return Duel.IsExistingTarget(c43543777.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，让玩家选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择 1 只符合条件的灵魂怪兽作为效果对象并登记到当前连锁。
	local g=Duel.SelectTarget(tp,c43543777.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本次效果处理将把所选择的 1 张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 定义效果处理阶段：取得对象卡，若仍与效果关联则将其加入手卡并让对方确认。
function c43543777.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的目标卡（即选择的对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送去其持有者的手卡，处理原因是效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的那张卡，以确认操作。
		Duel.ConfirmCards(1-tp,tc)
	end
end
