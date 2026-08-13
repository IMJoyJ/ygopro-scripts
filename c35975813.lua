--ジェノサイドキングデーモン
-- 效果：
-- 这张卡仅当自己场上存在名称中含有「恶魔」字样的怪兽卡时才能进行召唤·反转召唤。这张卡的控制者在自己的每1个准备阶段支付800基本分。当这张卡成为对方所控制的卡的效果对象时，在效果处理时掷1次骰子，若掷出2或5，则使此效果无效并将其破坏。被这张卡战斗破坏的效果怪兽的效果无效化。
function c35975813.initial_effect(c)
	-- 这张卡仅当自己场上存在名称中含有「恶魔」字样的怪兽卡时才能进行召唤·反转召唤。（此处实现其中“召唤”的限制）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c35975813.excon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	-- 这张卡的控制者在自己的每1个准备阶段支付800基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c35975813.mtcon)
	e3:SetOperation(c35975813.mtop)
	c:RegisterEffect(e3)
	-- 当这张卡成为对方所控制的卡的效果对象时，在效果处理时掷1次骰子，若掷出2或5，则使此效果无效并将其破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCategory(CATEGORY_DICE)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetOperation(c35975813.disop)
	c:RegisterEffect(e4)
	-- 被这张卡战斗破坏的效果怪兽的效果无效化。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_BATTLED)
	e5:SetRange(LOCATION_MZONE)
	e5:SetOperation(c35975813.disop2)
	c:RegisterEffect(e5)
end
-- 过滤出自己场上表侧表示且种族为「恶魔」的怪兽卡。
function c35975813.exfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x45)
end
-- 当自己场上不存在表侧表示且种族为「恶魔」的怪兽时，召唤限制效果适用（不能进行召唤）。
function c35975813.excon(e)
	-- 若自己场上不存在任何表侧表示且种族为「恶魔」的怪兽，则返回 true，使不能召唤的限制生效。
	return not Duel.IsExistingMatchingCard(c35975813.exfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 触发条件：当前回合玩家是本卡的控制者，即只在控制者的准备阶段才发动。
function c35975813.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为效果控制者（tp），用于限定准备阶段属于控制者。
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段维持处理：若控制者能支付800LP或万魔殿效果适用，则在万魔殿不适用或玩家拒绝使用万魔殿代替时支付800LP，否则不支付；若两者皆不满足，则将这张卡破坏。
function c35975813.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查控制者是否能支付800基本分，或是否受到万魔殿-恶魔的巢窟-的效果影响（可以不支付维持基本分）。
	if Duel.CheckLPCost(tp,800) or Duel.IsPlayerAffectedByEffect(tp,94585852) then
		-- 判断控制者是否没有受到万魔殿-恶魔的巢窟-的效果影响。
		if not Duel.IsPlayerAffectedByEffect(tp,94585852)
			-- 判断玩家是否选择不使用万魔殿-恶魔的巢窟-的代替效果；若选择不使用，则仍需支付800基本分。
			or not Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(94585852,1)) then  --"是否使用「万魔殿-恶魔的巢窟-」的效果不支付基本分？"
			-- 实际支付800基本分作为维持费用。
			Duel.PayLPCost(tp,800)
		end
	else
		-- 由于不能支付维持费用（或无万魔殿代替）而将这张卡破坏，破坏原因按规则处理为COST。
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
-- 连锁处理时：当对方发动的取对象效果以这张卡为对象且该效果可被无效时，掷1次骰子，若掷出2或5，则无效该连锁效果，并将那个效果的发动卡（若仍与效果关联）破坏。
function c35975813.disop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁（ev）的对象卡组，用于检查这张卡是否被选为对象。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 若没有对象、对象中不包含这张卡，或该连锁效果不能被无效，则不进行无效处理。
	if not tg or not tg:IsContains(e:GetHandler()) or not Duel.IsChainDisablable(ev) then return false end
	local rc=re:GetHandler()
	-- 由这张卡的控制者掷1次骰子。
	local dc=Duel.TossDice(tp,1)
	if dc~=2 and dc~=5 then return end
	-- 若成功无效该连锁效果，且效果发动卡仍与效果关联，则继续破坏该卡。
	if Duel.NegateEffect(ev,true) and rc:IsRelateToEffect(re) then
		-- 将发动那个效果的卡破坏（效果处理破坏）。
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
-- 伤害计算后，若这张卡战斗破坏的是效果怪兽，则对该怪兽附加效果无效化与效果发动无效化的状态，使其离场后解除。
function c35975813.disop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if tc and tc:IsType(TYPE_EFFECT) and tc:IsStatus(STATUS_BATTLE_DESTROYED) then
		-- 被这张卡战斗破坏的效果怪兽的效果无效化。（赋予EFFECT_DISABLE）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x17a0000)
		tc:RegisterEffect(e1)
		-- 被这张卡战斗破坏的效果怪兽的效果无效化。（赋予EFFECT_DISABLE_EFFECT，使其效果发动也无效）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+0x17a0000)
		tc:RegisterEffect(e2)
	end
end
