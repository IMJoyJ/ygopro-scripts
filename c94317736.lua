--極東秘泉郷
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：双方玩家1回合1次，自己主要阶段2才能发动。自己回复500基本分，这个回合中，以下效果适用。
-- ●自己怪兽的召唤·特殊召唤不会被无效化。
-- ●包含把怪兽特殊召唤效果的怪兽的效果·魔法·陷阱卡由自己发动的场合，那个发动不会被无效化。
-- ●自己场上盖放的魔法·陷阱卡不会成为对方的效果的对象，不会被对方的效果破坏。
function c94317736.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,94317736+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	-- ①：双方玩家1回合1次，自己主要阶段2才能发动。自己回复500基本分，这个回合中，以下效果适用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e2:SetCountLimit(1)
	e2:SetCondition(c94317736.effcon)
	e2:SetOperation(c94317736.effop)
	c:RegisterEffect(e2)
end
-- 发动条件函数：判断当前是否为主要阶段2
function c94317736.effcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 效果处理函数：回复500基本分，并注册本回合适用的各项持续效果
function c94317736.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若成功回复500基本分，则适用后续效果
	if Duel.Recover(tp,500,REASON_EFFECT)~=0 then
		-- ●自己怪兽的召唤·特殊召唤不会被无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
		e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册本回合自己怪兽的特殊召唤不会被无效化的效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
		-- 注册本回合自己怪兽的召唤不会被无效化的效果
		Duel.RegisterEffect(e2,tp)
		-- ●包含把怪兽特殊召唤效果的怪兽的效果·魔法·陷阱卡由自己发动的场合，那个发动不会被无效化。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_INACTIVATE)
		e3:SetValue(c94317736.effectfilter)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 注册本回合自己包含特召效果的卡片或效果的发动不会被无效化的效果
		Duel.RegisterEffect(e3,tp)
		-- ●自己场上盖放的魔法·陷阱卡不会成为对方的效果的对象，不会被对方的效果破坏。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e4:SetTargetRange(LOCATION_SZONE,0)
		-- 设置效果影响的目标为魔法·陷阱卡
		e4:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_SPELL+TYPE_TRAP))
		-- 设置不受对方效果对象影响的过滤条件
		e4:SetValue(aux.tgoval)
		e4:SetReset(RESET_PHASE+PHASE_END)
		-- 注册本回合自己场上盖放的魔陷不会成为对方效果对象的效果
		Duel.RegisterEffect(e4,tp)
		local e5=e4:Clone()
		e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		-- 设置不受对方效果破坏影响的过滤条件
		e5:SetValue(aux.indoval)
		-- 注册本回合自己场上盖放的魔陷不会被对方效果破坏的效果
		Duel.RegisterEffect(e5,tp)
	end
end
-- 过滤函数：筛选出由自己发动的、且包含特殊召唤效果的怪兽效果或魔法·陷阱卡的发动
function c94317736.effectfilter(e,ct)
	local p=e:GetHandlerPlayer()
	-- 获取当前连锁中触发的效果和触发玩家
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and (te:IsActiveType(TYPE_MONSTER) or te:IsHasType(EFFECT_TYPE_ACTIVATE)) and te:IsHasCategory(CATEGORY_SPECIAL_SUMMON)
end
