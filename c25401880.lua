--サイコパス
-- 效果：
-- ①：支付800基本分，以除外的最多2只自己的念动力族怪兽为对象才能发动。那些怪兽加入手卡。
function c25401880.initial_effect(c)
	-- ①：支付800基本分，以除外的最多2只自己的念动力族怪兽为对象才能发动。那些怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c25401880.cost)
	e1:SetTarget(c25401880.target)
	e1:SetOperation(c25401880.activate)
	c:RegisterEffect(e1)
end
-- cost函数：作为发动代价，检查并支付800基本分。
function c25401880.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家tp是否能支付800LP；若不能则不能发动。
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 实际支付800LP作为发动代价。
	Duel.PayLPCost(tp,800)
end
-- 过滤器：选择自己除外区表侧表示的念动力族怪兽，且该卡可以加入手牌。
function c25401880.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO) and c:IsAbleToHand()
end
-- target函数：进行取对象与发动合法性的检查，选择1~2张符合条件的除外区怪兽，并设置回手牌的操作信息。
function c25401880.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c25401880.filter(chkc) end
	-- 发动时确认：是否存在至少1张符合条件的念动力族怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(c25401880.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 弹出选择提示，让玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己除外区选择1~2张符合条件的念动力族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c25401880.filter,tp,LOCATION_REMOVED,0,1,2,nil)
	-- 设置操作信息：本次效果将把选择的对象加入手牌，数量为g中卡的数量。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- activate函数：效果处理时，取得对象卡并确认其仍与效果相关，然后将相关对象加入手牌，并让对方确认。
function c25401880.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理中的效果对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将相关对象以效果原因送入其持有者的手牌。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,sg)
	end
end
