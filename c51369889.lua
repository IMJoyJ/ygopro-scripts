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
-- 筛选满足条件的怪兽：表侧表示、机械族、超量怪兽，且可以作为代价取除1个超量素材。
function c51369889.rmfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_XYZ) and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
end
-- 代价函数：用标签100标记已在发动时确定过费用条件，实际取除素材在效果目标选择中完成。
function c51369889.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 目标函数：判定可发动后，先反复选择机械族超量怪兽并取除其1个超量素材以决定数量ct，再选择场上ct张卡作为对象，并设置破坏的操作信息。
function c51369889.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then
		if e:GetLabel()==100 then
			e:SetLabel(0)
			-- 检查我方场上是否存在满足rmfilter条件的机械族超量怪兽（表侧表示、机械族、超量、可取除素材）。
			return Duel.IsExistingMatchingCard(c51369889.rmfilter,tp,LOCATION_MZONE,0,1,tp)
				-- 检查场上是否存在可作为效果对象的卡（任意表侧或里侧的场上卡）。
				and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		else return false end
	end
	-- 统计场上所有能够被选为对象的卡的总数rt，用于决定最多可取除素材/破坏卡的数量。
	local rt=Duel.GetTargetCount(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local ct=0
	local min=1
	while ct<rt do
		-- 弹出提示，要求玩家选择要取除超量素材的机械族超量怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)  --"请选择要取除超量素材的怪兽"
		-- 从自己场上选择1只满足rmfilter条件的机械族超量怪兽；min为1时必须有选择，之后为0允许停止取除。
		local sg=Duel.SelectMatchingCard(tp,c51369889.rmfilter,tp,LOCATION_MZONE,0,min,1,nil,tp)
		if #sg==0 then break end
		sg:GetFirst():RemoveOverlayCard(tp,1,1,REASON_COST)
		ct=ct+1
		min=0
	end
	-- 弹出提示，要求玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上ct张卡作为效果对象（数量等于取除的素材数量）。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil)
	-- 设置本次连锁的破坏操作信息：将所选择的对象g作为将被破坏的卡，数量为g的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果处理函数：取回连锁对象中仍与效果相关的卡，将其破坏。
function c51369889.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出当前连锁的对象卡组，并过滤出仍与该效果相关的卡（对象在效果处理时仍在场上且未被移走等）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将过滤后的对象卡以效果原因破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 条件过滤：被破坏的怪兽是此前表侧表示、由我方控制的机械族超量怪兽，且破坏原因为战斗或对方的效果。
function c51369889.cfilter(c,e,tp)
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp))
		and c:IsPreviousPosition(POS_FACEUP) and c:IsType(TYPE_XYZ) and c:IsRace(RACE_MACHINE)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 破坏的怪兽集合中存在满足cfilter条件的怪兽（即我方机械族超量怪兽被战斗或对方效果破坏）。
function c51369889.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c51369889.cfilter,1,nil,e,tp)
end
-- 筛选墓地中可作为除外代价的机械族超量怪兽，要求有阶级（rank>0）且能被除外。
function c51369889.damfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsRace(RACE_MACHINE) and c:IsAbleToRemoveAsCost() and c:GetRank()>0
end
-- 代价函数检查本卡自身可作为除外代价，且墓地存在另一只满足damfilter的机械族超量怪兽。
function c51369889.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 进一步确认墓地存在1只可除外的机械族超量怪兽（除本卡外）。
		and Duel.IsExistingMatchingCard(c51369889.damfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 弹出提示，要求玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地选择1只除本卡外的机械族超量怪兽作为除外代价。
	local g=Duel.SelectMatchingCard(tp,c51369889.damfilter,tp,LOCATION_GRAVE,0,1,1,c)
	e:SetLabel(g:GetFirst():GetRank())
	g:AddCard(c)
	-- 将选择的怪兽和本卡一起除外作为代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 伤害目标函数：设置对方为伤害对象，伤害值为记录的超量怪兽阶级×200，并设置伤害操作信息。
function c51369889.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为对方（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 设置对象参数为记录下的超量怪兽阶级×200。
	Duel.SetTargetParam(e:GetLabel()*200)
	-- 设置操作信息：造成伤害，对象为对方，伤害值来自标签。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel()*200)
end
-- 伤害处理函数：执行给与对方伤害。
function c51369889.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设置的对方玩家和伤害值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给对方造成d点效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
