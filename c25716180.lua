--ゼンマイニャンコ
-- 效果：
-- 自己的主要阶段时才能发动。选择对方场上存在的1只怪兽回到持有者手卡。这个效果只在这张卡在场上表侧表示存在能使用1次。
function c25716180.initial_effect(c)
	-- 对应效果原文：自己的主要阶段时才能发动。选择对方场上存在的1只怪兽回到持有者手卡。这个效果只在这张卡在场上表侧表示存在能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25716180,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c25716180.target)
	e1:SetOperation(c25716180.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标选取函数：确认对方场上有可回手牌的怪兽时，提示玩家选择1只对方场上的怪兽作为对象，并登记回手牌的操作信息。
function c25716180.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 发动时点合法性检查：确认对方场上有1只满足‘可以被送回手牌’的怪兽存在，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，要求玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从对方场上选择1只可回手牌的怪兽，并将该怪兽登记为本次效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	-- 登记本次效果处理时将进行‘回到手牌’的操作信息（回手1张对象怪兽），供后续时点及连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理时的执行函数：取得发动的对象怪兽，若对象仍与效果关联，则将其送回持有者手卡。
function c25716180.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽（本效果取对象且只有1只，因此取第一个目标）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因将对象怪兽送回其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
