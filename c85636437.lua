--土俵間際
-- 效果：
-- ①：自己基本分比对方少的场合，以对方场上1只表侧表示怪兽为对象才能发动。给与对方那只怪兽的原本攻击力一半数值的伤害。这张卡的发动后，直到回合结束时对方受到的全部伤害变成0。
function c85636437.initial_effect(c)
	-- ①：自己基本分比对方少的场合，以对方场上1只表侧表示怪兽为对象才能发动。给与对方那只怪兽的原本攻击力一半数值的伤害。这张卡的发动后，直到回合结束时对方受到的全部伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c85636437.condition)
	e1:SetTarget(c85636437.target)
	e1:SetOperation(c85636437.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件：自己基本分比对方少
function c85636437.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的基本分是否小于对方的基本分
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
-- 定义过滤条件：表侧表示且原本攻击力大于0的怪兽
function c85636437.filter(c)
	return c:IsFaceup() and c:GetBaseAttack()>0
end
-- 定义效果发动的对象选择与操作信息设置
function c85636437.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c85636437.filter(chkc) end
	-- 在发动阶段，检查对方场上是否存在符合条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c85636437.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只符合条件的表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c85636437.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：给与对方相当于该怪兽原本攻击力一半数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,math.floor(g:GetFirst():GetBaseAttack()/2))
end
-- 定义效果处理：给与伤害并适用后续的免伤效果
function c85636437.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 给与对方该怪兽原本攻击力一半数值的伤害
		Duel.Damage(1-tp,math.floor(tc:GetBaseAttack()/2),REASON_EFFECT)
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时对方受到的全部伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetTargetRange(0,1)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果：使对方受到的全部伤害变成0
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果：使对方受到的效果伤害判定为0（用于系统检测）
	Duel.RegisterEffect(e2,tp)
end
