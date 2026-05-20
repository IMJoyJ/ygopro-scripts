--パトロール・ロボ
-- 效果：
-- 只要这张卡在场上表侧表示存在，自己的准备阶段可以把对方场上盖放的1张卡确认。
function c76775123.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，自己的准备阶段可以把对方场上盖放的1张卡确认。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76775123,0))  --"确认盖卡"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c76775123.condition)
	e1:SetTarget(c76775123.target)
	e1:SetOperation(c76775123.operation)
	c:RegisterEffect(e1)
end
-- 发动条件判定函数：判定是否为自己的准备阶段
function c76775123.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己
	return tp==Duel.GetTurnPlayer()
end
-- 效果目标选择函数：判定并选择对方场上1张里侧表示的卡作为效果对象
function c76775123.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsFacedown() end
	-- 在发动效果的准备阶段，判定对方场上是否存在至少1张里侧表示的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 设置选择卡片时的提示信息为“请选择里侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 选择对方场上1张里侧表示的卡作为效果对象
	Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,1,nil)
end
-- 效果处理函数：确认作为对象的里侧表示卡片
function c76775123.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 获取在发动时选择的效果对象卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFacedown() then
		-- 向发动效果的玩家展示并确认该里侧表示的卡片
		Duel.ConfirmCards(tp,tc)
	end
end
