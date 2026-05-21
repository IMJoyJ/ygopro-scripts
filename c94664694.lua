--マッド・デーモン
-- 效果：
-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ②：攻击表示的这张卡被选择作为攻击对象的场合发动。这张卡变成守备表示。
function c94664694.initial_effect(c)
	-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	-- ②：攻击表示的这张卡被选择作为攻击对象的场合发动。这张卡变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94664694,0))  --"变成守备表示"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetTarget(c94664694.target)
	e2:SetOperation(c94664694.operation)
	c:RegisterEffect(e2)
end
-- 效果②的发动准备：检查自身是否处于攻击表示，并设置改变表示形式的操作信息
function c94664694.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackPos() end
	-- 设置操作信息，表示将要改变这张卡的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 效果②的处理：若自身仍与效果关联且处于表侧攻击表示，则将其变为表侧守备表示
function c94664694.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsPosition(POS_FACEUP_ATTACK) then
		-- 将这张卡变为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
