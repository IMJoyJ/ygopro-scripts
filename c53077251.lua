--単一化
-- 效果：
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。作为对象的怪兽以外的场上的全部怪兽的攻击力直到回合结束时变成和作为对象的怪兽相同。
function c53077251.initial_effect(c)
	-- ①：以对方场上1只表侧表示怪兽为对象才能发动。作为对象的怪兽以外的场上的全部怪兽的攻击力直到回合结束时变成和作为对象的怪兽相同。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 设置效果只能在伤害步骤且伤害计算前发动，防止在伤害计算时或之后发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c53077251.target)
	e1:SetOperation(c53077251.activate)
	c:RegisterEffect(e1)
end
-- 定义对象选择过滤器：候选为对方场上的表侧表示怪兽，且场上还存在其他表侧表示、攻击力与之不同的怪兽，以保证效果有可适用的对象。
function c53077251.filter(c,tp)
	-- 判断候选怪兽是否表侧表示，并且场上存在至少1只表侧表示且攻击力不等于该怪兽攻击力的其他怪兽。
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c53077251.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetAttack())
end
-- 定义攻击力变更对象过滤器：选出表侧表示且当前攻击力不等于指定攻击力atk的怪兽。
function c53077251.filter2(c,atk)
	return c:IsFaceup() and not c:IsAttack(atk)
end
-- 定义效果发动时的target函数：负责检查发动条件、合法性提示以及选择对象。
function c53077251.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c53077251.filter(chkc,tp) end
	-- 在发动确认时，检查对方场上是否存在满足filter条件的表侧表示怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(c53077251.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 弹出选择提示，让玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从对方场上选择1只满足filter条件的表侧表示怪兽，并将其登记为这张卡效果的对象。
	Duel.SelectTarget(tp,c53077251.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
end
-- 定义效果处理时的activate函数：获取对象怪兽，若对象仍有效且表侧表示，则取得其攻击力，并让场上其他表侧表示且攻击力不同的怪兽的攻击力在回合结束时变为该数值。
function c53077251.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的对象怪兽（即对方场上被指定的表侧表示怪兽）。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	local atk=tc:GetAttack()
	-- 取得场上除对象怪兽以外，所有表侧表示且攻击力不等于对象怪兽攻击力的怪兽集合。
	local g=Duel.GetMatchingGroup(c53077251.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,tc,atk)
	-- 遍历该怪兽集合，对每一只符合条件的怪兽赋予攻击力变化效果。
	for sc in aux.Next(g) do
		-- 作为对象的怪兽以外的场上的全部怪兽的攻击力直到回合结束时变成和作为对象的怪兽相同。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		sc:RegisterEffect(e1)
	end
end
