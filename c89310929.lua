--霞の谷の雷神鬼
-- 效果：
-- 调整＋调整以外的名字带有「霞之谷」的怪兽1只以上
-- 1回合1次，选择这张卡以外的自己场上1张卡才能发动。选择的自己的卡回到持有者手卡，这张卡的攻击力直到结束阶段时上升500。这个效果在对方回合也能发动。
function c89310929.initial_effect(c)
	-- 为卡片添加同调召唤手续：调整＋调整以外的「霞之谷」怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSetCard,0x37),1)
	c:EnableReviveLimit()
	-- 1回合1次，选择这张卡以外的自己场上1张卡才能发动。选择的自己的卡回到持有者手卡，这张卡的攻击力直到结束阶段时上升500。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89310929,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	-- 设置效果发动条件为不在伤害计算后（限制在伤害步骤的伤害计算前才能发动）
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c89310929.target)
	e1:SetOperation(c89310929.operation)
	c:RegisterEffect(e1)
end
-- 效果的发动目标选择与处理信息注册函数
function c89310929.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc:IsAbleToHand() end
	-- 在发动准备阶段，检测自己场上是否存在除这张卡以外、可以回到手牌的卡作为可选对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 向发动玩家提示“请选择要返回手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择自己场上除这张卡以外的1张可以回到手牌的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 向系统注册该连锁的处理信息为“将选中的1张卡送回手牌”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果的处理函数，执行回手牌和增加攻击力的具体操作
function c89310929.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象卡
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 因效果将选中的对象卡送回持有者的手牌
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or not tc:IsLocation(LOCATION_HAND) then return end
	-- 这张卡的攻击力直到结束阶段时上升500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
