--古代の機械熱核竜
-- 效果：
-- ①：把「古代的机械」怪兽解放作上级召唤的这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ②：把「零件」怪兽解放作上级召唤的这张卡在同1次的战斗阶段中可以作2次攻击。
-- ③：这张卡攻击的场合，对方直到伤害步骤结束时怪兽的效果·魔法·陷阱卡不能发动。
-- ④：这张卡攻击的伤害步骤结束时才能发动。选场上1张魔法·陷阱卡破坏。
function c44874522.initial_effect(c)
	-- ①：把「古代的机械」怪兽解放作上级召唤的这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c44874522.valcheck)
	c:RegisterEffect(e1)
	-- ②：把「零件」怪兽解放作上级召唤的这张卡在同1次的战斗阶段中可以作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(c44874522.regcon)
	e2:SetOperation(c44874522.regop)
	c:RegisterEffect(e2)
	e2:SetLabelObject(e1)
	-- ③：这张卡攻击的场合，对方直到伤害步骤结束时怪兽的效果·魔法·陷阱卡不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(c44874522.aclimit)
	e3:SetCondition(c44874522.actcon)
	c:RegisterEffect(e3)
	-- ④：这张卡攻击的伤害步骤结束时才能发动。选场上1张魔法·陷阱卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(44874522,0))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetCondition(c44874522.condition)
	e4:SetTarget(c44874522.target)
	e4:SetOperation(c44874522.operation)
	c:RegisterEffect(e4)
end
-- 检索上级召唤所用的素材，判断是否包含「古代的机械」或「零件」怪兽，并记录在效果标签中。
function c44874522.valcheck(e,c)
	local g=c:GetMaterial()
	local flag=0
	local tc=g:GetFirst()
	while tc do
		if tc:IsSetCard(0x7) and tc:IsType(TYPE_MONSTER) then flag=bit.bor(flag,0x1) end
		if tc:IsSetCard(0x51) and tc:IsType(TYPE_MONSTER) then flag=bit.bor(flag,0x2) end
		tc=g:GetNext()
	end
	e:SetLabel(flag)
end
-- 判断此卡是否为上级召唤成功。
function c44874522.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 根据上级召唤所用素材类型，为本卡注册贯穿伤害或额外攻击次数效果。
function c44874522.regop(e,tp,eg,ep,ev,re,r,rp)
	local flag=e:GetLabelObject():GetLabel()
	local c=e:GetHandler()
	if bit.band(flag,0x1)~=0 then
		-- 为本卡注册贯穿伤害效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	if bit.band(flag,0x2)~=0 then
		-- 为本卡注册额外攻击次数效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EXTRA_ATTACK)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 判断效果发动时是否为魔法或怪兽卡的发动。
function c44874522.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER)
end
-- 判断当前攻击怪兽是否为本卡。
function c44874522.actcon(e)
	-- 判断当前攻击怪兽是否为本卡。
	return Duel.GetAttacker()==e:GetHandler()
end
-- 判断是否为伤害步骤结束时，并且攻击怪兽为本卡。
function c44874522.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为伤害步骤结束时，并且攻击怪兽为本卡。
	return aux.dsercon(e,tp,eg,ep,ev,re,r,rp) and Duel.GetAttacker()==e:GetHandler()
end
-- 定义魔法·陷阱卡的过滤条件。
function c44874522.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置连锁操作信息，确定要破坏的魔法·陷阱卡。
function c44874522.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c44874522.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有魔法·陷阱卡。
	local g=Duel.GetMatchingGroup(c44874522.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息，确定要破坏的魔法·陷阱卡数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏魔法·陷阱卡的操作。
function c44874522.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的魔法·陷阱卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c44874522.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 显示所选魔法·陷阱卡被破坏的动画效果。
		Duel.HintSelection(g)
		-- 将所选魔法·陷阱卡以效果原因破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
