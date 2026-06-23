--フォーミュラ・シンクロン
-- 效果：
-- 调整＋调整以外的怪兽1只
-- ①：这张卡同调召唤时才能发动。自己抽1张。
-- ②：对方主要阶段才能发动（同一连锁上最多1次）。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
function c50091196.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整作为调整，1只调整以外的怪兽作为素材
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
-- 效果条件：确认此卡是否为同调召唤成功
function c50091196.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果处理：检查玩家是否可以抽卡并设置抽卡目标
function c50091196.drtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足抽卡条件
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的参数为抽卡数量1
	Duel.SetTargetParam(1)
	-- 设置操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：执行抽卡操作
function c50091196.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡，原因设为效果抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 效果条件：确认是否在对方主要阶段且不是当前回合玩家
function c50091196.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return Duel.GetTurnPlayer()~=tp
		-- 判断是否处于主要阶段1或主要阶段2
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 效果处理：检查是否有可同调召唤的怪兽并设置操作信息
function c50091196.sctarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否存在满足条件的同调怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,c) end
	-- 设置操作信息为特殊召唤效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：执行同调召唤操作
function c50091196.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取场上满足同调召唤条件的怪兽数组
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 执行同调召唤手续
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
