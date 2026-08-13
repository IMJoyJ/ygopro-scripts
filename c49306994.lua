--白のヴェール
-- 效果：
-- ①：装备怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ②：装备怪兽进行战斗的攻击宣言时发动。对方场上的表侧表示的魔法·陷阱卡的效果直到伤害步骤结束时无效化。
-- ③：装备怪兽战斗破坏对方怪兽时才能发动。对方场上的魔法·陷阱卡全部破坏。
-- ④：魔法与陷阱区域的表侧表示的这张卡从场上离开时自己受到3000伤害。
function c49306994.initial_effect(c)
	-- 装备魔法卡的发动处理：以场上1只表侧表示怪兽为对象，将这张卡装备给那只怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c49306994.target)
	e1:SetOperation(c49306994.operation)
	c:RegisterEffect(e1)
	-- 装备对象限制：只能装备给怪兽（对应效果原文中的「装备怪兽」）。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ①：装备怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetTargetRange(0,1)
	e3:SetValue(c49306994.aclimit)
	e3:SetCondition(c49306994.actcon)
	c:RegisterEffect(e3)
	-- ②：装备怪兽进行战斗的攻击宣言时发动。对方场上的表侧表示的魔法·陷阱卡的效果直到伤害步骤结束时无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetCondition(c49306994.discon)
	e4:SetOperation(c49306994.disop)
	c:RegisterEffect(e4)
	-- ③：装备怪兽战斗破坏对方怪兽时才能发动。对方场上的魔法·陷阱卡全部破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(49306994,0))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_BATTLE_DESTROYING)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(c49306994.descon)
	e5:SetTarget(c49306994.destg)
	e5:SetOperation(c49306994.desop)
	c:RegisterEffect(e5)
	-- ④：魔法与陷阱区域的表侧表示的这张卡从场上离开时自己受到3000伤害。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetCode(EVENT_LEAVE_FIELD_P)
	e6:SetOperation(c49306994.checkop)
	c:RegisterEffect(e6)
	-- ④：魔法与陷阱区域的表侧表示的这张卡从场上离开时自己受到3000伤害。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_LEAVE_FIELD)
	e7:SetLabelObject(e6)
	e7:SetOperation(c49306994.leave)
	c:RegisterEffect(e7)
end
-- 发动时选择对象：从自己或对方场上选择1只表侧表示怪兽作为这张卡的装备对象，并登记装备操作信息。
function c49306994.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查是否存在至少1只表侧表示怪兽可供选择；没有则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择装备对象的提示文字。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择1只表侧表示怪兽作为装备对象（取对象）。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记操作信息：本连锁处理为装备效果，将这张卡装备给对象。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 处理装备：确认这张卡和对象仍与效果关联且对象表侧表示后，进行装备。
function c49306994.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的装备对象。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 把这张卡作为装备卡装备给对象怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 过滤条件：仅当对方发动的动作是魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE）时才限制。
function c49306994.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 适用条件：装备怪兽正在进行战斗（是攻击怪兽或攻击对象），此时对方不能发动魔陷。
function c49306994.actcon(e)
	local tc=e:GetHandler():GetEquipTarget()
	-- 判断当前战斗的攻击怪兽或攻击对象是否为装备怪兽。
	return Duel.GetAttacker()==tc or Duel.GetAttackTarget()==tc
end
-- 触发条件：攻击宣言时，装备怪兽是攻击方或攻击对象则触发②。
function c49306994.discon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetEquipTarget()
	-- 判断攻击宣言中涉及攻击方或攻击对象的怪兽是否为装备怪兽。
	return Duel.GetAttacker()==tc or Duel.GetAttackTarget()==tc
end
-- 筛选可被无效的卡片：表侧表示且可被无效的魔法·陷阱卡（包含陷阱怪兽）。
function c49306994.disfilter(c)
	-- 卡片必须是表侧表示且是可以被无效的魔法·陷阱卡。
	return aux.NegateAnyFilter(c) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 把对方场上的表侧表示魔法·陷阱卡全部无效化直到伤害步骤结束，陷阱怪兽的怪兽效果同样无效。
function c49306994.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得对方场上所有满足disfilter的魔法·陷阱卡。
	local g=Duel.GetMatchingGroup(c49306994.disfilter,tp,0,LOCATION_ONFIELD,c)
	local tc=g:GetFirst()
	while tc do
		-- 对方场上的表侧表示的魔法·陷阱卡的效果直到伤害步骤结束时无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
		-- 对方场上的表侧表示的魔法·陷阱卡的效果直到伤害步骤结束时无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 对方场上的表侧表示的魔法·陷阱卡（包括陷阱怪兽）的效果直到伤害步骤结束时无效化。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
			tc:RegisterEffect(e3)
		end
		tc=g:GetNext()
	end
end
-- 发动条件：装备怪兽战斗破坏对方怪兽（被破坏怪兽正是装备怪兽的战斗对象）。
function c49306994.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()==eg:GetFirst()
end
-- 筛选要破坏的卡：魔法·陷阱卡。
function c49306994.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 目标合法与登记：对方场上有魔法·陷阱卡时，将对方场上全部魔法·陷阱卡登记为破坏对象。
function c49306994.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c49306994.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 取得对方场上全部魔法·陷阱卡（用于破坏）。
	local sg=Duel.GetMatchingGroup(c49306994.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 登记操作信息：破坏对象为这些卡，数量为当前数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 实际处理：破坏对方场上全部魔法·陷阱卡。
function c49306994.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时重新取得对方场上全部魔法·陷阱卡。
	local sg=Duel.GetMatchingGroup(c49306994.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 以效果破坏这些魔法·陷阱卡。
	Duel.Destroy(sg,REASON_EFFECT)
end
-- 离场前检查：若这张卡效果被无效，则标记1，否则标记0，供④判断是否免除伤害。
function c49306994.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 离场处理：若离开魔陷区前未被无效、离开前控制者是原控制者且表侧表示，则自己受到3000伤害。
function c49306994.leave(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabelObject():GetLabel()==0 and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEUP) then
		-- 给这张卡的控制者（自己）造成3000点效果伤害。
		Duel.Damage(tp,3000,REASON_EFFECT)
	end
end
