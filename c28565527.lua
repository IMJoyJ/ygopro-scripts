--黄龍の召喚士
-- 效果：
-- 「黄龙召唤士」的效果1回合只能使用1次。
-- ①：把自己场上1只怪兽解放，以场上1只怪兽为对象才能发动。那只怪兽回到持有者手卡。
function c28565527.initial_effect(c)
	-- 效果原文内容：「黄龙召唤士」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28565527,0))  --"回到手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,28565527)
	e1:SetCost(c28565527.cost)
	e1:SetTarget(c28565527.target)
	e1:SetOperation(c28565527.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：检查场上是否存在可返回手牌的怪兽
function c28565527.cfilter(c)
	-- 效果作用：检查场上是否存在可返回手牌的怪兽
	return Duel.IsExistingTarget(Card.IsAbleToHand,0,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 效果原文内容：①：把自己场上1只怪兽解放，以场上1只怪兽为对象才能发动。
function c28565527.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否满足解放怪兽的条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,c28565527.cfilter,1,nil) end
	-- 效果作用：选择1张可解放的怪兽
	local g=Duel.SelectReleaseGroup(tp,c28565527.cfilter,1,1,nil)
	-- 效果作用：将选中的怪兽解放作为效果的代价
	Duel.Release(g,REASON_COST)
end
-- 效果原文内容：那只怪兽回到持有者手卡。
function c28565527.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	if chk==0 then return true end
	-- 效果作用：提示玩家选择要返回手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 效果作用：选择1只可返回手牌的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 效果作用：设置效果处理时的操作信息，确定将怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果作用：将选定的怪兽送回持有者手牌
function c28565527.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 效果作用：将目标怪兽送回持有者手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
