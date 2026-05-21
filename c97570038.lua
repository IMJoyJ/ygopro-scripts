--ゴッドハンド・スマッシュ
-- 效果：
-- 自己场上「格斗鼠 吱助」「武僧战士」「武僧大师」内1只以上存在时发动。这个回合和这些怪兽进行战斗的怪兽在伤害步骤结束时破坏。
function c97570038.initial_effect(c)
	-- 在卡片中注册关联的卡片密码列表，表明本卡效果记述了「格斗鼠 吱助」「武僧战士」「武僧大师」的卡名
	aux.AddCodeList(c,8508055,3810071,49814180)
	-- 自己场上「格斗鼠 吱助」「武僧战士」「武僧大师」内1只以上存在时发动。这个回合和这些怪兽进行战斗的怪兽在伤害步骤结束时破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c97570038.condition)
	e1:SetOperation(c97570038.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示且卡名为「格斗鼠 吱助」、「武僧战士」或「武僧大师」的怪兽
function c97570038.filter(c)
	return c:IsFaceup() and c:IsCode(8508055,3810071,49814180)
end
-- 发动条件：检查自己场上是否存在满足条件的怪兽
function c97570038.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽区是否存在至少1只表侧表示的「格斗鼠 吱助」、「武僧战士」或「武僧大师」
	return Duel.IsExistingMatchingCard(c97570038.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果处理：注册一个在伤害步骤结束时触发、持续到回合结束的全局效果
function c97570038.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合和这些怪兽进行战斗的怪兽在伤害步骤结束时破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetOperation(c97570038.desop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将创建的全局效果注册给玩家，使其在全局环境中生效
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件：卡名为「格斗鼠 吱助」、「武僧战士」或「武僧大师」的怪兽
function c97570038.cfilter(c)
	return c:IsCode(8508055,3810071,49814180)
end
-- 伤害步骤结束时的效果处理：判断进行战斗的怪兽中是否包含指定的怪兽，并破坏与其战斗的怪兽
function c97570038.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local at=Duel.GetAttackTarget()
	if not at then return end
	local g=Group.CreateGroup()
	if c97570038.cfilter(a) and at:IsLocation(LOCATION_MZONE) then g:AddCard(at) end
	if c97570038.cfilter(at) and a:IsLocation(LOCATION_MZONE) then g:AddCard(a) end
	if g:GetCount()>0 then
		-- 将目标怪兽因效果破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
