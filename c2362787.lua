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
-- 效果的发动代价处理：定义支付800基本分作为代价，并确认能否支付。
function c2362787.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动确认阶段检查当前玩家能否支付800基本分；若不能则效果不能发动。
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 实际扣除800基本分作为发动代价。
	Duel.PayLPCost(tp,800)
end
-- 对象筛选条件：该卡在除外区表侧表示、属性为光属性、且可以被加入手卡。
function c2362787.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 效果发动时的目标选择与操作信息设定：从自己除外区选择1只满足条件的光属性怪兽为对象，并设置回手牌的处理信息。
function c2362787.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c2362787.filter(chkc) end
	-- 在发动确认阶段检查自己除外区是否存在至少1只满足条件的光属性怪兽；若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c2362787.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 弹出选择提示，让玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 实际选择自己除外区的1只满足条件的光属性怪兽，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c2362787.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置当前连锁的操作信息：将对象卡加入手牌，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：取得对象卡，若其仍与该效果关联则将其加入手卡，并向对方展示。
function c2362787.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者的手卡（原因为效果）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,tc)
	end
end
