--ゼンマイニャンコ
-- 效果：
-- 自己的主要阶段时才能发动。选择对方场上存在的1只怪兽回到持有者手卡。这个效果只在这张卡在场上表侧表示存在能使用1次。
function c25716180.initial_effect(c)
	-- 效果原文内容：自己的主要阶段时才能发动。选择对方场上存在的1只怪兽回到持有者手卡。这个效果只在这张卡在场上表侧表示存在能使用1次。
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
-- 效果作用：设置效果目标为对方场上可以送回手卡的怪兽
function c25716180.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 效果作用：检查是否存在可以送回手卡的对方怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) end
	-- 效果作用：向玩家提示选择要送回手卡的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 效果作用：选择对方场上可以送回手卡的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	-- 效果作用：设置效果处理信息，表明将要将怪兽送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果作用：处理效果的发动，将选定的怪兽送回手卡
function c25716180.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前效果选定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 效果作用：将目标怪兽以效果原因送回持有者手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
