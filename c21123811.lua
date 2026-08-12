--コズミック・ブレイザー・ドラゴン
-- 效果：
-- 同调怪兽调整＋调整以外的同调怪兽2只以上
-- 这张卡不用同调召唤不能特殊召唤。
-- ①：可以把场上的这张卡直到结束阶段除外，从以下效果选择1个发动。
-- ●对方把魔法·陷阱·怪兽的效果发动时才能发动。那个发动无效并破坏。
-- ●对方把怪兽召唤·反转召唤·特殊召唤之际才能发动。那个无效，那些怪兽破坏。
-- ●对方怪兽的攻击宣言时才能发动。那次攻击无效，那之后战斗阶段结束。
local s,id,o=GetID()
-- 初始化效果函数，设置同调召唤程序、启用复活限制并注册特殊召唤条件
function c21123811.initial_effect(c)
	-- 设置同调召唤的条件为：1只调整+2只以上调整以外的同调怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSynchroType,TYPE_SYNCHRO),aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),2)
	c:EnableReviveLimit()
	-- 设置该卡不能通过非同调方式特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡只能通过同调召唤方式特殊召唤
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
	-- 设置第一个诱发效果：对方发动魔法·陷阱·怪兽效果时才能发动，使发动无效并破坏
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
	-- 设置第二个诱发效果：对方怪兽召唤·反转召唤·特殊召唤时才能发动，使召唤无效并破坏
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
	-- 设置第三个诱发效果：对方怪兽攻击宣言时才能发动，使攻击无效并跳过战斗阶段
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
-- 判断是否满足第一个效果的发动条件：对方发动效果且该卡未在战斗阶段被破坏且该连锁可被无效
function c21123811.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方发动效果且该卡未在战斗阶段被破坏且该连锁可被无效
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 设置发动效果的费用：将自身除外作为费用
function c21123811.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	-- 将自身除外作为费用并注册返回场上的效果
	if Duel.Remove(c,0,REASON_COST+REASON_TEMPORARY)~=0 and c:GetOriginalCode()==id then
		-- 注册一个在结束阶段将自身返回场上的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(c21123811.retop)
		-- 将效果注册到玩家环境中
		Duel.RegisterEffect(e1,tp)
	end
end
-- 设置第一个效果的处理目标：使发动无效并破坏
function c21123811.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏发动的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 处理第一个效果：使发动无效并破坏
function c21123811.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使发动无效且发动的卡存在并关联到效果
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏发动的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 判断是否满足第二个效果的发动条件：对方召唤且当前无连锁
function c21123811.dscon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方召唤且当前无连锁
	return ep==1-tp and Duel.GetCurrentChain()==0
end
-- 设置第二个效果的处理目标：使召唤无效并破坏
function c21123811.dstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使召唤无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息：破坏召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 处理第二个效果：使召唤无效并破坏
function c21123811.dsop(e,tp,eg,ep,ev,re,r,rp)
	-- 使召唤无效
	Duel.NegateSummon(eg)
	-- 破坏召唤的怪兽
	Duel.Destroy(eg,REASON_EFFECT)
end
-- 判断是否满足第三个效果的发动条件：攻击方控制该卡
function c21123811.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 攻击方控制该卡
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 处理第三个效果：使攻击无效并跳过战斗阶段
function c21123811.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使攻击无效
	if Duel.NegateAttack() then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 跳过对方的战斗阶段
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
-- 返回场上的效果处理函数
function c21123811.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将卡返回场上
	Duel.ReturnToField(e:GetLabelObject())
end
