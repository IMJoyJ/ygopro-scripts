--竜魔王レクターP
-- 效果：
-- ←5 【灵摆】 5→
-- ①：只要这张卡在灵摆区域存在，对方场上的表侧表示的灵摆怪兽的效果无效化。
-- 【怪兽效果】
-- ①：这张卡和灵摆怪兽进行战斗的伤害步骤开始时发动。那只怪兽和这张卡破坏。
function c7127502.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性（注册灵摆召唤和灵摆卡的发动等基本规则）
	aux.EnablePendulumAttribute(c)
	-- ①：只要这张卡在灵摆区域存在，对方场上的表侧表示的灵摆怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(c7127502.distg)
	c:RegisterEffect(e1)
	-- ①：这张卡和灵摆怪兽进行战斗的伤害步骤开始时发动。那只怪兽和这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetTarget(c7127502.destg)
	e2:SetOperation(c7127502.desop)
	c:RegisterEffect(e2)
end
-- 过滤出属于灵摆类型的卡片，作为无效效果的目标过滤条件
function c7127502.distg(e,c)
	return c:IsType(TYPE_PENDULUM)
end
-- 破坏效果的发动条件判定与目标设置：检查与这张卡战斗的怪兽是否是表侧表示的灵摆怪兽，并设置破坏2张卡的操作信息
function c7127502.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if chk==0 then return tc and tc:IsFaceup() and tc:IsType(TYPE_PENDULUM) end
	local g=Group.FromCards(c,tc)
	-- 设置当前连锁的操作信息为：破坏包含这张卡和战斗对手在内的2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 破坏效果的执行：若这张卡和战斗对手都仍处于战斗关联状态，则将这两张卡用效果破坏
function c7127502.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if c:IsRelateToBattle() and tc:IsRelateToBattle() then
		local g=Group.FromCards(c,tc)
		-- 因效果原因破坏目标卡片组
		Duel.Destroy(g,REASON_EFFECT)
	end
end
