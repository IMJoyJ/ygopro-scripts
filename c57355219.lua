--パラドックス・フュージョン
-- 效果：
-- ①：可以把自己场上1只表侧表示的融合怪兽除外把以下效果发动。发动后第2次的自己结束阶段，除外的那只怪兽表侧攻击表示回到自己场上。
-- ●魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ●自己或者对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。
function c57355219.initial_effect(c)
	-- ①：可以把自己场上1只表侧表示的融合怪兽除外把以下效果发动。●自己或者对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON)
	-- 设置效果的发动条件为不在连锁处理中（即非连锁中特殊召唤之际）
	e1:SetCondition(aux.NegateSummonCondition)
	e1:SetCost(c57355219.cost)
	e1:SetTarget(c57355219.target1)
	e1:SetOperation(c57355219.activate1)
	c:RegisterEffect(e1)
	-- ①：可以把自己场上1只表侧表示的融合怪兽除外把以下效果发动。●魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(c57355219.condition2)
	e2:SetCost(c57355219.cost)
	e2:SetTarget(c57355219.target2)
	e2:SetOperation(c57355219.activate2)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示、融合怪兽、可以作为代价值除外、且未确定被战斗破坏的怪兽
function c57355219.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsAbleToRemoveAsCost() and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 定义发动代价：将自己场上1只表侧表示的融合怪兽暂时除外，并记录该怪兽
function c57355219.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在满足条件的融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c57355219.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家发送提示信息，提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己场上1只满足条件的融合怪兽
	local g=Duel.SelectMatchingCard(tp,c57355219.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选中的怪兽作为代价暂时除外
	Duel.Remove(g,0,REASON_COST+REASON_TEMPORARY)
	e:SetLabelObject(g:GetFirst())
end
-- 定义效果1的靶向处理：设置无效召唤和破坏的操作信息
function c57355219.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：无效特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息：破坏特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 定义效果1的处理：无效特殊召唤并破坏，然后注册回归效果
function c57355219.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 使正在特殊召唤的怪兽的召唤无效
	Duel.NegateSummon(eg)
	-- 以效果原因破坏那些特殊召唤被无效的怪兽
	Duel.Destroy(eg,REASON_EFFECT)
	c57355219.retreg(e,tp)
end
-- 定义效果2的发动条件：魔法·陷阱卡发动时，且该发动可以被无效
function c57355219.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查触发连锁的效果是否为魔法·陷阱卡的发动，且该发动可以被无效
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 定义效果2的靶向处理：设置无效发动和破坏的操作信息
function c57355219.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该魔法·陷阱卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义效果2的处理：使发动无效并破坏，然后注册回归效果
function c57355219.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使发动无效，且该卡在场上或与效果相关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏该魔法·陷阱卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
	c57355219.retreg(e,tp)
end
-- 定义注册除外怪兽回归场上的延迟效果的函数
function c57355219.retreg(e,tp)
	local tc=e:GetLabelObject()
	e:SetLabelObject(nil)
	if not tc then return end
	-- 发动后第2次的自己结束阶段，除外的那只怪兽表侧攻击表示回到自己场上。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	e1:SetLabelObject(tc)
	e1:SetCountLimit(1)
	e1:SetCondition(c57355219.retcon)
	e1:SetOperation(c57355219.retop)
	tc:SetTurnCounter(0)
	-- 把延迟效果作为玩家的效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 定义回归效果的发动条件：必须是自己的回合
function c57355219.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 定义回归效果的处理：在第2次自己结束阶段，将除外的怪兽表侧攻击表示返回场上
function c57355219.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	local ct=c:GetTurnCounter()
	c:SetTurnCounter(ct+1)
	if ct==1 then
		-- 将暂时除外的怪兽表侧攻击表示返回到场上
		Duel.ReturnToField(c,POS_FACEUP_ATTACK)
	end
end
