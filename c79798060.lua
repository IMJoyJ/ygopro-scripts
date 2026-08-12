--地縛神 Ccarayhua
-- 效果：
-- 名字带有「地缚神」的怪兽在场上只能有1只表侧表示存在。场上没有表侧表示场地魔法卡存在的场合这张卡破坏。对方不能选择这张卡作为攻击对象。这张卡可以直接攻击对方玩家。这张卡的效果以外的效果让这张卡破坏时，场上存在的卡全部破坏。
function c79798060.initial_effect(c)
	-- 设置双方场上只能有1只表侧表示的「地缚神」怪兽存在（在怪兽区域生效）。
	c:SetUniqueOnField(1,1,aux.FilterBoolFunction(Card.IsSetCard,0x1021),LOCATION_MZONE)
	-- 场上没有表侧表示场地魔法卡存在的场合这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetCondition(c79798060.sdcon)
	c:RegisterEffect(e4)
	-- 对方不能选择这张卡作为攻击对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	-- 设置不能成为攻击对象的过滤函数（不受效果影响的怪兽除外）。
	e5:SetValue(aux.imval1)
	c:RegisterEffect(e5)
	-- 这张卡可以直接攻击对方玩家。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e6)
	-- 这张卡的效果以外的效果让这张卡破坏时，场上存在的卡全部破坏。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(79798060,0))  --"破坏"
	e7:SetCategory(CATEGORY_DESTROY)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e7:SetCode(EVENT_DESTROYED)
	e7:SetCondition(c79798060.descon)
	e7:SetTarget(c79798060.destg)
	e7:SetOperation(c79798060.desop)
	c:RegisterEffect(e7)
end
-- 自我破坏效果的条件函数：检查场上是否存在表侧表示的场地魔法卡。
function c79798060.sdcon(e)
	-- 若双方的场地区域都不存在表侧表示的卡，则满足自我破坏条件。
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 全场破坏效果的发动条件：此卡因战斗以外的方式被破坏，且破坏源为其他卡的效果。
function c79798060.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsReason(REASON_BATTLE) and re and re:GetOwner()~=c
end
-- 全场破坏效果的目标确认与操作信息设置函数。
function c79798060.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上的所有卡片。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 向系统宣告将要破坏场上所有的卡片。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 全场破坏效果的执行函数。
function c79798060.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上的所有卡片。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 以效果破坏的方式破坏获取到的所有场上卡片。
	Duel.Destroy(g,REASON_EFFECT)
end
