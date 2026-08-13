--フォーミュラ・シンクロン
-- 效果：
-- 调整＋调整以外的怪兽1只
-- ①：这张卡同调召唤时才能发动。自己抽1张。
-- ②：对方主要阶段才能发动（同一连锁上最多1次）。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
function c50091196.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的怪兽1只（任意调整 + 1只调整以外的怪兽）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1,1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤时才能发动。自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50091196,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c50091196.drcon)
	e1:SetTarget(c50091196.drtarg)
	e1:SetOperation(c50091196.drop)
	c:RegisterEffect(e1)
	-- ②：对方主要阶段才能发动（同一连锁上最多1次）。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50091196,1))  --"同调召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c50091196.sccon)
	e2:SetTarget(c50091196.sctarg)
	e2:SetOperation(c50091196.scop)
	c:RegisterEffect(e2)
end
-- 抽卡效果的发动条件：仅当这张卡以同调召唤的方式成功特殊召唤时才允许发动。
function c50091196.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 抽卡效果发动时的目标检测与信息设置：先检测自己能否抽1张，再记录抽卡玩家为自己、抽卡数量为1，并设置操作信息为抽卡。
function c50091196.drtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查（chk==0）时，确认自己玩家能够抽1张卡；若不能则效果不可发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设置为效果发动者tp，即抽卡玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的效果参数设置为1，表示要抽取的卡数为1张。
	Duel.SetTargetParam(1)
	-- 设置操作信息：本连锁处理的是抽卡效果，预计让tp抽1张卡（targets为nil、player为tp、param为1）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果处理时的实际操作：从连锁信息中取出记录的抽卡玩家和抽卡数，让该玩家以效果原因抽对应数量的卡。
function c50091196.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中保存的目标玩家（抽卡者）和目标参数（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡：让玩家p以效果原因（REASON_EFFECT）抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 对方主要阶段同调召唤效果的发动条件：仅在当前不是自己的回合、且处于主要阶段1或主要阶段2时才能发动。
function c50091196.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前回合玩家不是效果发动者tp，即满足“对方主要阶段”的要求。
	return Duel.GetTurnPlayer()~=tp
		-- 并且当前阶段为主要阶段1或主要阶段2（PHASE_MAIN1/PHASE_MAIN2）。
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 对方主要阶段同调召唤效果的目标条件：确认额外卡组存在可用这张卡作为素材进行同调召唤的怪兽，并设置操作信息为特殊召唤。
function c50091196.sctarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在合法性检查时，确认额外卡组中是否存在满足“以这张卡为素材”的同调召唤可能的同调怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,c) end
	-- 设置操作信息：本连锁处理的是特殊召唤效果，预计从额外卡组特殊召唤1只怪兽给tp。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 对方主要阶段同调召唤效果处理时的操作：若这张卡仍在自己场上且与效果关联，则选择额外卡组中1只可同调召唤的怪兽，以这张卡为素材进行同调召唤。
function c50091196.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取额外卡组中所有满足“可以以这张卡为素材进行同调召唤”条件的同调怪兽集合。
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if g:GetCount()>0 then
		-- 向玩家发出选择提示，要求选择要特殊召唤的同调怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 执行同调召唤：将选中的同调怪兽sg:GetFirst()通过这张卡c作为调整素材进行同调召唤。
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
