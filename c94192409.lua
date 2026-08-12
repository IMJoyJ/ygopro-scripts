--強制脱出装置
-- 效果：
-- ①：以场上1只怪兽为对象才能发动。那只怪兽回到手卡。
function c94192409.initial_effect(c)
	-- ①：以场上1只怪兽为对象才能发动。那只怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c94192409.target)
	e1:SetOperation(c94192409.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的目标选择与检测（确认场上是否存在可以回到手牌的怪兽，并进行取对象选择）
function c94192409.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	-- 检查场上是否存在至少1只可以回到手牌的怪兽作为合法的效果对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给发动效果的玩家发送“请选择要返回手牌的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家选择场上1只可以回到手牌的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息，表明此效果的处理为将选中的1张卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理的执行（将作为对象的怪兽送回持有者手牌）
function c94192409.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在效果发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 因效果将目标怪兽送回其持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
