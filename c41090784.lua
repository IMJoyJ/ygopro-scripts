--氷結界の大僧正
-- 效果：
-- ①：这张卡召唤·反转召唤的场合发动。这张卡变成守备表示。
-- ②：只要这张卡在怪兽区域存在，自己场上的「冰结界」怪兽不会被魔法·陷阱卡的效果破坏。
function c41090784.initial_effect(c)
	-- ①：这张卡召唤·反转召唤的场合发动。这张卡变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41090784,0))  --"变成守备表示"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c41090784.potg)
	e1:SetOperation(c41090784.poop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，自己场上的「冰结界」怪兽不会被魔法·陷阱卡的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置效果目标为场上所有属于「冰结界」的怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2f))
	e3:SetValue(c41090784.indval)
	c:RegisterEffect(e3)
end
-- 效果处理时判断发动者是否处于攻击表示
function c41090784.potg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackPos() end
	-- 设置连锁操作信息为改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 效果处理时将发动者变为守备表示
function c41090784.poop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e) then
		-- 将目标怪兽改变为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 返回值为true表示该效果对魔法·陷阱卡的效果无效
function c41090784.indval(e,re,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
