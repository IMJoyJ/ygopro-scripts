--掃射特攻
-- 效果：
-- ①：1回合1次，把自己场上的机械族超量怪兽的超量素材任意数量取除，以那个数量的场上的卡为对象才能发动。那些卡破坏。
-- ②：这张卡在墓地存在的状态，自己场上的机械族超量怪兽被战斗或者对方的效果破坏的场合，从自己墓地把这张卡和1只机械族超量怪兽除外才能发动。给与对方除外的怪兽的阶级×200伤害。
function c51369889.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- ①：1回合1次，把自己场上的机械族超量怪兽的超量素材任意数量取除，以那个数量的场上的卡为对象才能发动。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCost(c51369889.descost)
	e2:SetTarget(c51369889.destg)
	e2:SetOperation(c51369889.desop)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在的状态，自己场上的机械族超量怪兽被战斗或者对方的效果破坏的场合，从自己墓地把这张卡和1只机械族超量怪兽除外才能发动。给与对方除外的怪兽的阶级×200伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(c51369889.damcon)
	e3:SetCost(c51369889.damcost)
	e3:SetTarget(c51369889.damtg)
	e3:SetOperation(c51369889.damop)
	c:RegisterEffect(e3)
end
-- 过滤函数，检查场上是否存在满足条件的机械族超量怪兽（可取除素材）
function c51369889.rmfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_XYZ) and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
end
-- 设置标签为100，用于判断是否进入效果处理阶段
function c51369889.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 效果处理函数：选择要取除超量素材的怪兽并选择要破坏的卡
function c51369889.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then
		if e:GetLabel()==100 then
			e:SetLabel(0)
			-- 检查场上是否存在至少1只可以取除素材的机械族超量怪兽
			return Duel.IsExistingMatchingCard(c51369889.rmfilter,tp,LOCATION_MZONE,0,1,tp)
				-- 检查场地上是否存在至少1张可作为对象的卡
				and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		else return false end
	end
	-- 获取当前可选目标数量
	local rt=Duel.GetTargetCount(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local ct=0
	local min=1
	while ct<rt do
		-- 提示玩家选择要取除超量素材的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)  --"请选择要取除超量素材的怪兽"
		-- 选择满足条件的怪兽并执行取除操作
		local sg=Duel.SelectMatchingCard(tp,c51369889.rmfilter,tp,LOCATION_MZONE,0,min,1,nil,tp)
		if #sg==0 then break end
		sg:GetFirst():RemoveOverlayCard(tp,1,1,REASON_COST)
		ct=ct+1
		min=0
	end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择要破坏的目标卡
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil)
	-- 设置效果操作信息，准备破坏目标卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理函数：破坏目标卡
function c51369889.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的目标卡组并过滤出与当前效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将目标卡组进行破坏处理
	Duel.Destroy(g,REASON_EFFECT)
end
-- 过滤函数，检查被破坏的怪兽是否满足条件（战斗或对方效果破坏、在场上、是机械族超量怪兽）
function c51369889.cfilter(c,e,tp)
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp))
		and c:IsPreviousPosition(POS_FACEUP) and c:IsType(TYPE_XYZ) and c:IsRace(RACE_MACHINE)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 判断是否有符合条件的怪兽被破坏
function c51369889.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c51369889.cfilter,1,nil,e,tp)
end
-- 过滤函数，检查墓地是否存在可作为代价的机械族超量怪兽
function c51369889.damfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsRace(RACE_MACHINE) and c:IsAbleToRemoveAsCost() and c:GetRank()>0
end
-- 效果处理函数：支付代价（将卡和一只机械族超量怪兽除外）
function c51369889.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 检查墓地中是否存在满足条件的机械族超量怪兽
		and Duel.IsExistingMatchingCard(c51369889.damfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的机械族超量怪兽作为代价
	local g=Duel.SelectMatchingCard(tp,c51369889.damfilter,tp,LOCATION_GRAVE,0,1,1,c)
	e:SetLabel(g:GetFirst():GetRank())
	g:AddCard(c)
	-- 将选中的卡除外作为效果代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果处理函数：设置伤害目标和伤害值
function c51369889.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害对象为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害值为除外怪兽阶级×200
	Duel.SetTargetParam(e:GetLabel()*200)
	-- 设置操作信息，准备对对方造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel()*200)
end
-- 效果处理函数：对对方造成伤害
function c51369889.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的目标玩家和目标参数（伤害值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对指定玩家造成相应伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
