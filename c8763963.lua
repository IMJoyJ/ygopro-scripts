--魔王超龍 ベエルゼウス
-- 效果：
-- 暗属性调整＋调整以外的怪兽2只以上
-- ①：这张卡不会被战斗·效果破坏。
-- ②：只要这张卡在怪兽区域存在，这张卡以外的自己怪兽不能攻击。
-- ③：1回合1次，以对方场上1只怪兽为对象才能发动。那只怪兽的攻击力变成0，自己基本分回复那个原本攻击力的数值。此外，这个回合这张卡的战斗发生的对对方玩家的战斗伤害变成一半。
function c8763963.initial_effect(c)
	-- 添加同调召唤手续：暗属性调整+调整以外的怪兽2只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),aux.NonTuner(nil),2)
	c:EnableReviveLimit()
	-- ①：这张卡不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，这张卡以外的自己怪兽不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c8763963.antarget)
	c:RegisterEffect(e3)
	-- ③：1回合1次，以对方场上1只怪兽为对象才能发动。那只怪兽的攻击力变成0，自己基本分回复那个原本攻击力的数值。此外，这个回合这张卡的战斗发生的对对方玩家的战斗伤害变成一半。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(8763963,0))  --"吸收攻击力"
	e4:SetCategory(CATEGORY_RECOVER)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c8763963.target)
	e4:SetOperation(c8763963.operation)
	c:RegisterEffect(e4)
end
-- 过滤自身以外的怪兽，用于限制其他怪兽攻击
function c8763963.antarget(e,c)
	return c~=e:GetHandler()
end
-- 过滤对方场上表侧表示且攻击力大于0的怪兽
function c8763963.filter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 效果③的发动准备（检查可行性、选择对象并设置回复LP的操作信息）
function c8763963.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c8763963.filter(chkc) end
	-- 检查对方场上是否存在满足过滤条件的怪兽以确定效果是否可以发动
	if chk==0 then return Duel.IsExistingTarget(c8763963.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 在客户端显示提示信息，要求玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择对方场上1只满足过滤条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c8763963.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理的操作信息，表明此效果包含回复LP的操作，数值为目标怪兽的原本攻击力
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetBaseAttack())
end
-- 效果③的实际处理：使目标怪兽攻击力变为0，回复其原本攻击力数值的LP，并使自身本回合造成的战斗伤害减半
function c8763963.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果发动的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:GetAttack()>0 and not tc:IsImmuneToEffect(e) then
		-- 那只怪兽的攻击力变成0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 执行回复操作，使自己回复目标怪兽原本攻击力数值的生命值
		Duel.Recover(tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
	if c:IsRelateToEffect(e) then
		-- 此外，这个回合这张卡的战斗发生的对对方玩家的战斗伤害变成一半。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_CHANGE_INVOLVING_BATTLE_DAMAGE)
		-- 设置战斗伤害改变效果的值，使对方玩家受到的战斗伤害变成一半
		e2:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
