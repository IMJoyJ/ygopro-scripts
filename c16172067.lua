--レッド・デーモンズ・ドラゴン・タイラント
-- 效果：
-- 调整2只＋调整以外的怪兽1只以上
-- 这张卡不用同调召唤不能特殊召唤。「红莲魔龙·暴君」的①②的效果1回合各能使用1次。
-- ①：自己主要阶段1才能发动。这张卡以外的场上的卡全部破坏。这个回合，这张卡以外的自己怪兽不能攻击。
-- ②：战斗阶段有魔法·陷阱卡发动时才能发动。那个发动无效并破坏，这张卡的攻击力上升500。
function c16172067.initial_effect(c)
	-- 设置同调召唤手续：以2只调整为素材，加1只以上的调整以外怪兽，进行同调召唤。
	aux.AddSynchroMixProcedure(c,aux.Tuner(nil),aux.Tuner(nil),nil,aux.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	-- 对应效果原文：这张卡不用同调召唤不能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件设置为只能以同调召唤方式出场。
	e0:SetValue(aux.synlimit)
	c:RegisterEffect(e0)
	-- 对应效果原文：①：自己主要阶段1才能发动。这张卡以外的场上的卡全部破坏。这个回合，这张卡以外的自己怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,16172067)
	e2:SetCondition(c16172067.descon)
	e2:SetTarget(c16172067.destg)
	e2:SetOperation(c16172067.desop)
	c:RegisterEffect(e2)
	-- 对应效果原文：②：战斗阶段有魔法·陷阱卡发动时才能发动。那个发动无效并破坏，这张卡的攻击力上升500。
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
	-- 对应效果原文：这张卡不用同调召唤不能特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(21142671)
	c:RegisterEffect(e4)
end
-- ①效果的发动条件函数：仅在己方主要阶段1时可发动。
function c16172067.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1。
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- ①效果的发动目标函数：确认场上有除自身之外的卡，并将这些卡设为破坏对象。
function c16172067.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：场上存在除自身外的任意卡时，效果才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取除自身以外的场上所有卡（作为本次破坏的对象集合）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置操作信息：宣告本次效果将破坏对象集合中的全部卡，破坏数量为集合卡数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ①效果处理：破坏场上除自身以外的所有卡，并给己方场上施加“这张卡以外的自己怪兽不能攻击”的限制。
function c16172067.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次获取除自身以外的场上全部卡。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	if g:GetCount()>0 then
		-- 以效果原因将这些卡全部破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
	-- 对应效果原文：这个回合，这张卡以外的自己怪兽不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c16172067.ftarget)
	e1:SetLabel(e:GetHandler():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述攻击限制效果注册到场上，持续本回合。
	Duel.RegisterEffect(e1,tp)
end
-- 攻击限制效果的过滤函数：只有不是红莲魔龙·暴君（字段ID不同）的己方怪兽才被禁止攻击。
function c16172067.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- ②效果的发动条件函数：在战斗阶段内且自身未被战斗破坏确定时，有魔法·陷阱卡发动且该发动可被无效，才能发动。
function c16172067.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前阶段。
	local ph=Duel.GetCurrentPhase()
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 确认该发动可被无效并且当前处于战斗阶段开始到战斗步骤的范围内。
		and Duel.IsChainNegatable(ev) and (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
-- ②效果的发动目标函数：不取对象，只要满足条件即可发动，并登记无效与破坏的对象。
function c16172067.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果包含无效发动，对象为正在发动的魔法·陷阱卡。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若该卡可被破坏且仍与效果关联，则追加设置破坏对象信息。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ②效果处理：无效并破坏那张魔法·陷阱卡；若成功，则这张卡攻击力上升500。
function c16172067.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定：该魔法·陷阱卡发动被成功无效，且该卡仍与发动效果相关联。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该魔法·陷阱卡。
		Duel.Destroy(eg,REASON_EFFECT)
		if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
		-- 对应效果原文：这张卡的攻击力上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(500)
		c:RegisterEffect(e1)
	end
end
