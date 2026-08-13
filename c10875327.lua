--地縛神 Aslla piscu
-- 效果：
-- ①：「地缚神」怪兽在场上只能有1只表侧表示存在。
-- ②：这张卡可以直接攻击。
-- ③：对方怪兽不能选择这张卡作为攻击对象。
-- ④：没有场地魔法卡表侧表示存在的场合这张卡破坏。
-- ⑤：表侧表示的这张卡因这张卡的效果以外的方法从场上离开的场合发动。对方场上的表侧表示怪兽全部破坏，给与对方破坏数量×800伤害。
function c10875327.initial_effect(c)
	-- 设置「地缚神」怪兽在场上只能有1只表侧表示存在的唯一限制：双方场上存在其他表侧表示的地缚神怪兽时，此卡不能上场。
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
	-- 设置该攻击限制效果的判定值：对方怪兽若不免疫此效果，则不能选择这张卡作为攻击对象。
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
-- 自我破坏效果的发动条件：场上不存在表侧表示的场地魔法卡时条件成立。
function c10875327.sdcon(e)
	-- 判断双方场地魔法区域是否没有表侧表示的卡（即没有场地魔法卡），没有则返回真。
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- ⑤效果的发动条件：这张卡离场前是表侧表示，离场后不在卡组，且离场原因不是这张卡自身的效果。
function c10875327.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and not c:IsLocation(LOCATION_DECK)
		and (not re or re:GetOwner()~=c)
end
-- 过滤函数：筛出表侧表示的怪兽，用于确定对方场上要被破坏的怪兽。
function c10875327.desfilter(c)
	return c:IsFaceup()
end
-- ⑤效果的发动前操作：获取对方场上所有表侧表示怪兽，设置破坏对象及数量，并按破坏数量设置伤害值。
function c10875327.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上满足表侧表示条件的所有怪兽，作为可能被破坏的卡组。
	local g=Duel.GetMatchingGroup(c10875327.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置破坏效果的操作信息：将g中的怪兽全部破坏，破坏数量为g的卡数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	if g:GetCount()~=0 then
		-- 设置伤害效果的操作信息：对对方玩家造成破坏数量×800点伤害。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*800)
	end
end
-- ⑤效果处理：获取当前对方场上所有表侧表示怪兽并全部破坏，若实际破坏数大于0，对对方造成破坏数量×800伤害。
function c10875327.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时重新获取对方场上所有表侧表示怪兽，确定实际破坏的对象。
	local g=Duel.GetMatchingGroup(c10875327.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 以效果原因破坏g中的所有怪兽，返回实际破坏的数量ct。
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct~=0 then
		-- 给与对方玩家1-tp造成ct×800点效果伤害。
		Duel.Damage(1-tp,ct*800,REASON_EFFECT)
	end
end
