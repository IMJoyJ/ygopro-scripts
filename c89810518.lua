--レプティレス・メデューサ
-- 效果：
-- 把1张手卡送去墓地，选择对方场上表侧表示存在的1只怪兽发动。选择怪兽攻击力变成0，变成不能把表示形式改变。
function c89810518.initial_effect(c)
	-- 把1张手卡送去墓地，选择对方场上表侧表示存在的1只怪兽发动。选择怪兽攻击力变成0，变成不能把表示形式改变。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89810518,0))  --"攻击变成0，不能改变表示形式"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c89810518.cost)
	e1:SetTarget(c89810518.target)
	e1:SetOperation(c89810518.operation)
	c:RegisterEffect(e1)
end
-- 效果发动代价（Cost）处理函数：检查并执行将手牌送去墓地的操作
function c89810518.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查自己手牌中是否存在至少1张可以作为代价送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 给玩家发送提示信息，提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手牌中选择1张可以作为代价送去墓地的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果目标选择（Target）处理函数：检查并选择对方场上表侧表示的怪兽作为效果对象
function c89810518.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 在发动阶段（chk==0）检查对方场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息，提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择对方场上1只表侧表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果执行（Operation）处理函数：使作为对象的怪兽攻击力变成0，且不能改变表示形式
function c89810518.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择怪兽攻击力变成0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 变成不能把表示形式改变。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
