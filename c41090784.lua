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
	-- 设定效果的对象筛选函数，使该保护效果仅适用于自己场上持有「冰结界」字段（0x2f）的怪兽。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2f))
	e3:SetValue(c41090784.indval)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件检查与操作登记：仅当这张卡为表侧攻击表示时才满足发动条件；满足后登记变更表示形式的操作信息。
function c41090784.potg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackPos() end
	-- 将本次连锁的处理信息登记为“变更表示形式”，对象为这张卡自身，数量为1，供效果处理及相关判定使用。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 效果①处理时执行的操作：若这张卡仍在场上、表侧攻击表示且与效果保持关联，则将其变更为表侧守备表示。
function c41090784.poop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e) then
		-- 将这张卡的表示形式变更为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 判定相关的效果是否为魔法或陷阱卡的效果；若是则使被保护怪兽不会被该效果破坏。
function c41090784.indval(e,re,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
