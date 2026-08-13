--コズミック・ブレイザー・ドラゴン
-- 效果：
-- 同调怪兽调整＋调整以外的同调怪兽2只以上
-- 这张卡不用同调召唤不能特殊召唤。
-- ①：可以把场上的这张卡直到结束阶段除外，从以下效果选择1个发动。
-- ●对方把魔法·陷阱·怪兽的效果发动时才能发动。那个发动无效并破坏。
-- ●对方把怪兽召唤·反转召唤·特殊召唤之际才能发动。那个无效，那些怪兽破坏。
-- ●对方怪兽的攻击宣言时才能发动。那次攻击无效，那之后战斗阶段结束。
local s,id,o=GetID()
-- 初始化宇宙耀变龙的效果：注册同调召唤手续与召唤限制，并注册①的三种可选诱发即时效果（无效发动、无效召唤、无效攻击）及其共通的除外自身代价和结束阶段返回处理。
function c21123811.initial_effect(c)
	-- 添加同调召唤手续：素材要求为“同调怪兽调整＋调整以外的同调怪兽2只以上”（FilterBoolFunction(Card.IsSynchroType,TYPE_SYNCHRO)表示同调怪兽，NonTuner(...)表示调整以外的同调怪兽）。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSynchroType,TYPE_SYNCHRO),aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),2)
	c:EnableReviveLimit()
	-- 这张卡不用同调召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件判定函数：只有通过同调召唤方式才能特殊召唤，其他召唤方式禁止。
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
	-- ①：可以把场上的这张卡直到结束阶段除外，从以下效果选择1个发动。●对方把魔法·陷阱·怪兽的效果发动时才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21123811,0))  --"发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c21123811.discon)
	e2:SetCost(c21123811.cost)
	e2:SetTarget(c21123811.distg)
	e2:SetOperation(c21123811.disop)
	c:RegisterEffect(e2)
	-- ①：可以把场上的这张卡直到结束阶段除外，从以下效果选择1个发动。●对方把怪兽召唤·反转召唤·特殊召唤之际才能发动。那个无效，那些怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(21123811,1))  --"召唤无效并破坏"
	e3:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SUMMON)
	e3:SetCondition(c21123811.dscon)
	e3:SetCost(c21123811.cost)
	e3:SetTarget(c21123811.dstg)
	e3:SetOperation(c21123811.dsop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e5)
	-- ①：可以把场上的这张卡直到结束阶段除外，从以下效果选择1个发动。●对方怪兽的攻击宣言时才能发动。那次攻击无效，那之后战斗阶段结束。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(21123811,2))  --"攻击无效"
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_ATTACK_ANNOUNCE)
	e6:SetCountLimit(1)
	e6:SetCondition(c21123811.negcon)
	e6:SetCost(c21123811.cost)
	e6:SetOperation(c21123811.negop)
	c:RegisterEffect(e6)
end
c21123811.material_type=TYPE_SYNCHRO
c21123811.cosmic_quasar_dragon_summon=true
-- 判定e2（发动无效并破坏）能否发动的条件：由对方发动效果、自身未被战斗破坏、且该连锁的发动可以被无效。
function c21123811.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体条件：效果控制者是对方，且这张卡没有“战斗破坏”状态，且Duel.IsChainNegatable(ev)为真。
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- ①效果的共同代价函数：将这张卡作为代价除外（暂时除外），并注册结束阶段将其返回场上的效果。
function c21123811.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	-- 以除外自身作为代价（REASON_COST+REASON_TEMPORARY），若成功且原卡号是本卡，则创建一个结束阶段返回的效果并注册。
	if Duel.Remove(c,0,REASON_COST+REASON_TEMPORARY)~=0 and c:GetOriginalCode()==id then
		-- 可以把场上的这张卡直到结束阶段除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(c21123811.retop)
		-- 将返回效果e1注册到场上，使这张卡在结束阶段被送回场上。
		Duel.RegisterEffect(e1,tp)
	end
end
-- e2的目标确定：必定选择无效对方发动的效果；若该效果来源卡可被破坏且仍与效果关联，则同时加入破坏目标。
function c21123811.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次连锁处理将无效对象连锁（eg），数量为1，供系统判定相关联动。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：若条件满足，将破坏对象连锁的来源卡（eg）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- e2的解决处理：无效对方效果的发动；若该卡仍与效果关联，则将其破坏。
function c21123811.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 先尝试无效该连锁；只有无效成功且发动的卡仍与效果关联时，才继续执行破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将发动被无效的那张卡（eg）以效果原因破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- e3（无效召唤）的发动条件：对方进行召唤，且当前没有连锁处理中，才能在该召唤之际发动。
function c21123811.dscon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件是召唤的玩家为对方（ep==1-tp），且当前连锁数为0（不在连锁处理中）。
	return ep==1-tp and Duel.GetCurrentChain()==0
end
-- e3的目标设置：将这次召唤的所有怪兽（eg）作为无效并破坏的对象，并写入操作信息。
function c21123811.dstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：无效这次召唤，对象为eg中的全部怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息：破坏这些召唤的怪兽，数量为eg的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- e3的解决处理：使这次召唤无效，并将那些怪兽破坏。
function c21123811.dsop(e,tp,eg,ep,ev,re,r,rp)
	-- 使本次召唤无效（对应“那个无效”）。
	Duel.NegateSummon(eg)
	-- 将召唤被无效的怪兽以效果原因破坏。
	Duel.Destroy(eg,REASON_EFFECT)
end
-- e6（无效攻击）的发动条件：攻击怪兽是对方控制的怪兽。
function c21123811.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 攻击宣言的怪兽的控制者是与本卡控制者不同的对手（1-tp）。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- e6的解决处理：无效攻击，若成功则中断连锁处理并跳过对方战斗阶段。
function c21123811.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 若无效攻击成功，则继续执行后续的跳过战斗阶段处理。
	if Duel.NegateAttack() then
		-- 中断当前效果处理，使后续处理与之前的效果处理不在同一时点，以符合“那之后”的语义。
		Duel.BreakEffect()
		-- 跳过对方的战斗阶段（value=1表示直接进入结束步骤，等同“战斗阶段结束”）。
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
-- 结束阶段返回处理：将被暂时除外的这张卡送回场上。
function c21123811.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将标记的这张卡（e:GetLabelObject()）返回场上，表示形式默认为离场前表示。
	Duel.ReturnToField(e:GetLabelObject())
end
