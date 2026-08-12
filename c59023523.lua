--サイバネティック・マジシャン
-- 效果：
-- 丢弃1张手卡。直到这个回合的结束阶段前，把场上表侧表示存在的1只怪兽的攻击力变为2000。
function c59023523.initial_effect(c)
	-- 丢弃1张手卡。直到这个回合的结束阶段前，把场上表侧表示存在的1只怪兽的攻击力变为2000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59023523,0))  --"攻击变化"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c59023523.cost)
	e1:SetTarget(c59023523.target)
	e1:SetOperation(c59023523.operation)
	c:RegisterEffect(e1)
end
-- 发动代价：丢弃1张手卡。
function c59023523.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择并丢弃1张手卡。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤场上表侧表示且攻击力不为2000的怪兽。
function c59023523.filter(c)
	return c:IsFaceup() and not c:IsAttack(2000)
end
-- 效果的目标选择与合法性检查。
function c59023523.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c59023523.filter(chkc) and chkc:IsLocation(LOCATION_MZONE) end
	-- 检查场上是否存在可以作为对象的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c59023523.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 在界面上提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的怪兽作为效果对象。
	Duel.SelectTarget(tp,c59023523.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：将选择的怪兽攻击力变为2000，持续到回合结束。
function c59023523.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 直到这个回合的结束阶段前，把场上表侧表示存在的1只怪兽的攻击力变为2000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(2000)
		tc:RegisterEffect(e1)
	end
end
