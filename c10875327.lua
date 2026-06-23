--地縛神 Aslla piscu
-- 效果：
-- ①：「地缚神」怪兽在场上只能有1只表侧表示存在。
-- ②：这张卡可以直接攻击。
-- ③：对方怪兽不能选择这张卡作为攻击对象。
-- ④：没有场地魔法卡表侧表示存在的场合这张卡破坏。
-- ⑤：表侧表示的这张卡因这张卡的效果以外的方法从场上离开的场合发动。对方场上的表侧表示怪兽全部破坏，给与对方破坏数量×800伤害。
function c10875327.initial_effect(c)
	-- 设置场上只能存在1只表侧表示的「地缚神」怪兽
	c:SetUniqueOnField(1,1,aux.FilterBoolFunction(Card.IsSetCard,0x1021),LOCATION_MZONE)
	-- ④：没有场地魔法卡表侧表示存在的场合这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetCondition(c10875327.sdcon)
	c:RegisterEffect(e4)
	-- ③：对方怪兽不能选择这张卡作为攻击对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	-- 效果值设为不能成为攻击对象的过滤函数
	e5:SetValue(aux.imval1)
	c:RegisterEffect(e5)
	-- ②：这张卡可以直接攻击。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e6)
	-- ⑤：表侧表示的这张卡因这张卡的效果以外的方法从场上离开的场合发动。对方场上的表侧表示怪兽全部破坏，给与对方破坏数量×800伤害。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(10875327,0))  --"伤害"
	e7:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e7:SetCode(EVENT_LEAVE_FIELD)
	e7:SetCondition(c10875327.descon)
	e7:SetTarget(c10875327.destg)
	e7:SetOperation(c10875327.desop)
	c:RegisterEffect(e7)
end
-- 判断是否满足效果④的发动条件
function c10875327.sdcon(e)
	-- 检查对方场上是否存在表侧表示的场地魔法卡
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 判断是否满足效果⑤的发动条件
function c10875327.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and not c:IsLocation(LOCATION_DECK)
		and (not re or re:GetOwner()~=c)
end
-- 用于过滤场上表侧表示怪兽的函数
function c10875327.desfilter(c)
	return c:IsFaceup()
end
-- 设置效果⑤的发动时处理目标
function c10875327.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有表侧表示怪兽组成组
	local g=Duel.GetMatchingGroup(c10875327.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息为破坏对方场上怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	if g:GetCount()~=0 then
		-- 设置连锁操作信息为对对方造成伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*800)
	end
end
-- 效果⑤的处理函数
function c10875327.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示怪兽组成组
	local g=Duel.GetMatchingGroup(c10875327.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 将对方场上所有表侧表示怪兽破坏
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct~=0 then
		-- 对对方造成破坏怪兽数量×800的伤害
		Duel.Damage(1-tp,ct*800,REASON_EFFECT)
	end
end
