--二重の落とし穴
-- 效果：
-- ①：再1次召唤状态的二重怪兽被战斗破坏时才能发动。对方场上的怪兽全部破坏。
function c67045174.initial_effect(c)
	-- ①：再1次召唤状态的二重怪兽被战斗破坏时才能发动。对方场上的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c67045174.condition)
	e1:SetTarget(c67045174.target)
	e1:SetOperation(c67045174.activate)
	c:RegisterEffect(e1)
	if not c67045174.global_check then
		c67045174.global_check=true
		-- 再1次召唤状态的二重怪兽被战斗破坏时
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLED)
		ge1:SetOperation(c67045174.checkop)
		-- 注册全局环境效果，用于在伤害步骤中检测并标记被战斗破坏的再1次召唤状态的二重怪兽
		Duel.RegisterEffect(ge1,0)
	end
end
c67045174.has_text_type=TYPE_DUAL
-- 在伤害计算后，检查进行战斗的怪兽是否为处于再1次召唤状态且已被战斗破坏的二重怪兽，并为其添加标识
function c67045174.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local t=Duel.GetAttackTarget()
	if a and a:IsDualState() and a:IsStatus(STATUS_BATTLE_DESTROYED) then
		a:RegisterFlagEffect(67045174,RESET_PHASE+PHASE_DAMAGE,0,1)
	end
	if t and t:IsDualState() and t:IsStatus(STATUS_BATTLE_DESTROYED) then
		t:RegisterFlagEffect(67045174,RESET_PHASE+PHASE_DAMAGE,0,1)
	end
end
-- 过滤函数：检查怪兽是否带有被战斗破坏的再1次召唤状态二重怪兽的标识
function c67045174.filter(c)
	return c:GetFlagEffect(67045174)~=0
end
-- 发动条件：被战斗破坏送去墓地的怪兽中存在带有特定标识的二重怪兽
function c67045174.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c67045174.filter,1,nil)
end
-- 效果的目标：检查对方场上是否存在怪兽，并设置破坏对方场上所有怪兽的操作信息
function c67045174.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查对方场上是否存在至少1张怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上的所有怪兽
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁的操作信息，表明该效果的处理为破坏对方场上的所有怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果的处理：获取并破坏对方场上的全部怪兽
function c67045174.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有怪兽
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 因效果破坏获取到的对方场上的所有怪兽
	Duel.Destroy(sg,REASON_EFFECT)
end
