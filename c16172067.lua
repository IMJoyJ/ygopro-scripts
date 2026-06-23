--レッド・デーモンズ・ドラゴン・タイラント
-- 效果：
-- 调整2只＋调整以外的怪兽1只以上
-- 这张卡不用同调召唤不能特殊召唤。「红莲魔龙·暴君」的①②的效果1回合各能使用1次。
-- ①：自己主要阶段1才能发动。这张卡以外的场上的卡全部破坏。这个回合，这张卡以外的自己怪兽不能攻击。
-- ②：战斗阶段有魔法·陷阱卡发动时才能发动。那个发动无效并破坏，这张卡的攻击力上升500。
function c16172067.initial_effect(c)
	-- 添加同调召唤手续，要求2只调整+1只以上调整以外的怪兽参与同调召唤
	aux.AddSynchroMixProcedure(c,aux.Tuner(nil),aux.Tuner(nil),nil,aux.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	-- 这张卡不用同调召唤不能特殊召唤
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡的特殊召唤条件为必须通过同调召唤
	e0:SetValue(aux.synlimit)
	c:RegisterEffect(e0)
	-- ①：自己主要阶段1才能发动。这张卡以外的场上的卡全部破坏。这个回合，这张卡以外的自己怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,16172067)
	e2:SetCondition(c16172067.descon)
	e2:SetTarget(c16172067.destg)
	e2:SetOperation(c16172067.desop)
	c:RegisterEffect(e2)
	-- ②：战斗阶段有魔法·陷阱卡发动时才能发动。那个发动无效并破坏，这张卡的攻击力上升500。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,16172068)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCondition(c16172067.discon)
	e3:SetTarget(c16172067.distg)
	e3:SetOperation(c16172067.disop)
	c:RegisterEffect(e3)
	-- 不能复制的原始效果（效果外文本）
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(21142671)
	c:RegisterEffect(e4)
end
-- 效果发动条件：当前阶段为自己的主要阶段1
function c16172067.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为自己的主要阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 效果发动时的处理：检索满足条件的场上卡并设置破坏操作信息
function c16172067.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取满足条件的场上卡组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果发动时的处理：破坏场上所有卡并设置自己怪兽不能攻击的效果
function c16172067.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除自身外的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	if g:GetCount()>0 then
		-- 将场上卡组全部破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
	-- 创建一个影响全场怪兽的不能攻击效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c16172067.ftarget)
	e1:SetLabel(e:GetHandler():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到场上
	Duel.RegisterEffect(e1,tp)
end
-- 设置不能攻击效果的目标为非自身怪兽
function c16172067.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 效果发动条件：当前阶段为战斗阶段且发动的卡为魔法或陷阱卡
function c16172067.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 当前阶段为战斗阶段且该连锁可被无效
		and Duel.IsChainNegatable(ev) and (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
-- 效果发动时的处理：设置连锁操作信息为无效并破坏
function c16172067.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息为无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁操作信息为破坏
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果发动时的处理：无效发动并破坏，同时提升自身攻击力
function c16172067.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否成功无效发动且目标卡存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将发动的卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
		if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
		-- 提升自身攻击力500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(500)
		c:RegisterEffect(e1)
	end
end
