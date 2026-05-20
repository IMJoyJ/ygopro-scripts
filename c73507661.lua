--妖精の風
-- 效果：
-- 场上表侧表示存在的魔法·陷阱卡全部破坏，双方受到破坏的卡数量×300的数值的伤害。
function c73507661.initial_effect(c)
	-- 场上表侧表示存在的魔法·陷阱卡全部破坏，双方受到破坏的卡数量×300的数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c73507661.target)
	e1:SetOperation(c73507661.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的魔法·陷阱卡
function c73507661.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动时的目标确认与操作信息设置
function c73507661.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否存在除这张卡以外的表侧表示的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c73507661.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 获取场上除这张卡以外的所有表侧表示的魔法·陷阱卡
	local sg=Duel.GetMatchingGroup(c73507661.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置操作信息：破坏场上所有符合条件的魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	-- 设置操作信息：双方玩家受到等同于破坏数量×300的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,sg:GetCount()*300)
end
-- 效果处理：执行破坏并给予双方伤害
function c73507661.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上除这张卡以外的所有表侧表示的魔法·陷阱卡
	local sg=Duel.GetMatchingGroup(c73507661.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 破坏选定的卡片，并记录实际被破坏的卡片数量
	local ct=Duel.Destroy(sg,REASON_EFFECT)
	-- 分步处理：给予发动玩家等同于破坏数量×300的伤害
	Duel.Damage(tp,ct*300,REASON_EFFECT,true)
	-- 分步处理：给予对方玩家等同于破坏数量×300的伤害
	Duel.Damage(1-tp,ct*300,REASON_EFFECT,true)
	-- 完成伤害处理，触发相关的伤害/生命值变化时点
	Duel.RDComplete()
end
