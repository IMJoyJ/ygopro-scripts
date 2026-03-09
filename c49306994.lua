--白のヴェール
-- 效果：
-- ①：装备怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ②：装备怪兽进行战斗的攻击宣言时发动。对方场上的表侧表示的魔法·陷阱卡的效果直到伤害步骤结束时无效化。
-- ③：装备怪兽战斗破坏对方怪兽时才能发动。对方场上的魔法·陷阱卡全部破坏。
-- ④：魔法与陷阱区域的表侧表示的这张卡从场上离开时自己受到3000伤害。
function c49306994.initial_effect(c)
	-- ①：装备怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c49306994.target)
	e1:SetOperation(c49306994.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
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
-- 选择装备目标怪兽
function c49306994.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 判断是否满足装备条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备目标怪兽
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作
function c49306994.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的装备目标
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断是否为魔法或陷阱卡的发动
function c49306994.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 判断是否为装备怪兽进行战斗
function c49306994.actcon(e)
	local tc=e:GetHandler():GetEquipTarget()
	-- 判断是否为装备怪兽进行战斗
	return Duel.GetAttacker()==tc or Duel.GetAttackTarget()==tc
end
-- 判断是否为装备怪兽进行战斗
function c49306994.discon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetEquipTarget()
	-- 判断是否为装备怪兽进行战斗
	return Duel.GetAttacker()==tc or Duel.GetAttackTarget()==tc
end
-- 筛选可被无效化的魔法或陷阱卡
function c49306994.disfilter(c)
	-- 筛选可被无效化的魔法或陷阱卡
	return aux.NegateAnyFilter(c) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 对目标魔法或陷阱卡施加无效化效果
function c49306994.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取所有可被无效化的魔法或陷阱卡
	local g=Duel.GetMatchingGroup(c49306994.disfilter,tp,0,LOCATION_ONFIELD,c)
	local tc=g:GetFirst()
	while tc do
		-- 使目标卡无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
		-- 使目标卡的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 使陷阱怪兽无效化
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
			tc:RegisterEffect(e3)
		end
		tc=g:GetNext()
	end
end
-- 判断是否为装备怪兽破坏对方怪兽
function c49306994.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()==eg:GetFirst()
end
-- 筛选魔法或陷阱卡
function c49306994.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置破坏效果的目标
function c49306994.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否存在魔法或陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c49306994.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取所有魔法或陷阱卡
	local sg=Duel.GetMatchingGroup(c49306994.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置效果处理信息为破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 执行破坏操作
function c49306994.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有魔法或陷阱卡
	local sg=Duel.GetMatchingGroup(c49306994.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 破坏目标魔法或陷阱卡
	Duel.Destroy(sg,REASON_EFFECT)
end
-- 记录装备卡是否被无效化
function c49306994.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 判断装备卡离开场时是否满足伤害条件
function c49306994.leave(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabelObject():GetLabel()==0 and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEUP) then
		-- 对玩家造成3000伤害
		Duel.Damage(tp,3000,REASON_EFFECT)
	end
end
