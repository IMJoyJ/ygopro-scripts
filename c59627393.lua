--No.105 BK 流星のセスタス
-- 效果：
-- 4星怪兽×3
-- ①：自己的「燃烧拳击手」怪兽和对方怪兽进行战斗的自己·对方的战斗步骤，把这张卡1个超量素材取除才能发动（同一连锁上最多1次）。直到回合结束时那只对方怪兽的效果只在表侧表示的期间无效化，那只自己怪兽不会被那次战斗破坏，那次战斗发生的对自己的战斗伤害由对方代受。
function c59627393.initial_effect(c)
	-- 设置XYZ召唤手续：4星怪兽×3
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- ①：自己的「燃烧拳击手」怪兽和对方怪兽进行战斗的自己·对方的战斗步骤，把这张卡1个超量素材取除才能发动（同一连锁上最多1次）。直到回合结束时那只对方怪兽的效果只在表侧表示的期间无效化，那只自己怪兽不会被那次战斗破坏，那次战斗发生的对自己的战斗伤害由对方代受。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59627393,0))  --"效果无效"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_PHASE)
	e1:SetCondition(c59627393.condition)
	e1:SetCost(c59627393.cost)
	e1:SetTarget(c59627393.target)
	e1:SetOperation(c59627393.operation)
	c:RegisterEffect(e1)
end
-- 设定该卡为「No.」怪兽，卡片编号为105
aux.xyz_number[59627393]=105
-- 定义效果①的发动条件判定函数
function c59627393.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local at=Duel.GetAttackTarget()
	-- 检查当前是否处于战斗阶段，且有自己场上的「燃烧拳击手」怪兽与对方怪兽进行战斗
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) and at and ((a:IsControler(tp) and a:IsOnField() and a:IsSetCard(0x1084))
		or (at:IsControler(tp) and at:IsOnField() and at:IsFaceup() and at:IsSetCard(0x1084)))
end
-- 定义效果①的发动代价函数
function c59627393.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查同一连锁上是否未发动过此效果，且这张卡是否有至少1个超量素材可以取除
	if chk==0 then return Duel.GetFlagEffect(tp,59627393)==0 and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 给玩家注册一个重置时间为伤害步骤结束的标记，用于限制同一连锁上最多发动1次
	Duel.RegisterFlagEffect(tp,59627393,RESET_PHASE+PHASE_DAMAGE,0,1)
end
-- 定义效果①的靶向目标函数
function c59627393.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将攻击怪兽设为效果处理的对象
	Duel.SetTargetCard(Duel.GetAttacker())
	-- 将被攻击怪兽设为效果处理的对象
	Duel.SetTargetCard(Duel.GetAttackTarget())
end
-- 定义效果①的效果处理（操作）函数
function c59627393.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时获取当前的攻击怪兽
	local a=Duel.GetAttacker()
	-- 在效果处理时获取当前的被攻击怪兽
	local at=Duel.GetAttackTarget()
	if at:IsControler(tp) then a,at=at,a end
	if a:IsFacedown() or not a:IsRelateToEffect(e) or not at:IsRelateToEffect(e) then return end
	-- 那只自己怪兽不会被那次战斗破坏
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	a:RegisterEffect(e1,true)
	-- 那次战斗发生的对自己的战斗伤害由对方代受
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e2:SetValue(1)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
	a:RegisterEffect(e2,true)
	if at:IsType(TYPE_EFFECT) then
		-- 直到回合结束时那只对方怪兽的效果只在表侧表示的期间无效化
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		at:RegisterEffect(e3)
		-- 直到回合结束时那只对方怪兽的效果只在表侧表示的期间无效化
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_DISABLE_EFFECT)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		at:RegisterEffect(e4)
	end
end
