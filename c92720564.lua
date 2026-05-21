--D・ラジカッセン
-- 效果：
-- 这张卡得到这张卡的表示形式的以下效果。
-- ●攻击表示：这张卡在同1次的战斗阶段中可以作2次攻击。
-- ●守备表示：自己场上表侧表示存在的名字带有「变形斗士」的怪兽被选择作为攻击对象时，可以把那次战斗无效。这个效果1回合只能使用1次。
function c92720564.initial_effect(c)
	-- ●攻击表示：这张卡在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetCondition(c92720564.cona)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ●守备表示：自己场上表侧表示存在的名字带有「变形斗士」的怪兽被选择作为攻击对象时，可以把那次战斗无效。这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92720564,0))  --"战斗无效"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c92720564.cond)
	e2:SetOperation(c92720564.opd)
	c:RegisterEffect(e2)
end
-- 判断自身是否处于攻击表示，作为追加攻击效果的生效条件
function c92720564.cona(e)
	return e:GetHandler():IsAttackPos()
end
-- 判断自身未被无效且处于守备表示，且被攻击的怪兽是表侧表示的「变形斗士」怪兽，作为效果发动条件
function c92720564.cond(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前被选择作为攻击对象的怪兽
	local d=Duel.GetAttackTarget()
	return not c:IsDisabled() and c:IsDefensePos() and d:IsFaceup() and d:IsSetCard(0x26)
end
-- 执行无效攻击的效果处理
function c92720564.opd(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前的攻击无效
	Duel.NegateAttack()
end
