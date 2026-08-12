--救援光
-- 效果：
-- ①：支付800基本分，以除外的1只自己的光属性怪兽为对象才能发动。那只怪兽加入手卡。
function c2362787.initial_effect(c)
	-- ①：支付800基本分，以除外的1只自己的光属性怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c2362787.cost)
	e1:SetTarget(c2362787.target)
	e1:SetOperation(c2362787.activate)
	c:RegisterEffect(e1)
end
-- 支付800基本分
function c2362787.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付800基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 让玩家支付800基本分
	Duel.PayLPCost(tp,800)
end
-- 过滤器函数：检查目标是否为表侧表示的光属性怪兽且能加入手卡
function c2362787.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 选择效果对象：选择一名玩家除外区的一只符合条件的光属性怪兽
function c2362787.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c2362787.filter(chkc) end
	-- 检查玩家除外区是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c2362787.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择符合条件的除外区怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c2362787.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置连锁操作信息为回手牌效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 发动效果：将选择的除外怪兽加入手牌并确认对方看到
function c2362787.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以效果原因送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认看到该怪兽被送入手牌
		Duel.ConfirmCards(1-tp,tc)
	end
end
