--記憶破壊王
-- 效果：
-- 这张卡直接攻击给与对方基本分战斗伤害时，对方墓地存在的同调怪兽全部从游戏中除外，给与对方基本分那个数量×1000的数值的伤害。
function c75675029.initial_effect(c)
	-- 这张卡直接攻击给与对方基本分战斗伤害时，对方墓地存在的同调怪兽全部从游戏中除外，给与对方基本分那个数量×1000的数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75675029,0))  --"除外并伤害"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c75675029.condition)
	e1:SetTarget(c75675029.target)
	e1:SetOperation(c75675029.operation)
	c:RegisterEffect(e1)
end
-- 设置效果发动条件函数（直接攻击给与对方战斗伤害时）
function c75675029.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断受到伤害的玩家是对方且攻击对象为空（即直接攻击）
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 过滤对方墓地中可以被除外的同调怪兽
function c75675029.filter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsAbleToRemove()
end
-- 设置效果发动时的目标确认与操作信息
function c75675029.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方墓地中所有满足过滤条件的同调怪兽
	local g=Duel.GetMatchingGroup(c75675029.filter,tp,0,LOCATION_GRAVE,nil)
	if g:GetCount()~=0 then
		-- 设置操作信息：除外对方墓地中的这些同调怪兽
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
		-- 设置操作信息：给与对方相当于除外数量×1000的伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*1000)
	end
end
-- 设置效果处理函数：除外对方墓地的同调怪兽并给与对方相应伤害
function c75675029.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方墓地中所有满足过滤条件的同调怪兽
	local g=Duel.GetMatchingGroup(c75675029.filter,tp,0,LOCATION_GRAVE,nil)
	-- 将这些同调怪兽表侧表示除外，并获取实际除外的数量
	local ct=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	if ct~=0 then
		-- 给与对方实际除外数量×1000的伤害
		Duel.Damage(1-tp,ct*1000,REASON_EFFECT)
	end
end
