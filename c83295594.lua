--スチーム・シンクロン
-- 效果：
-- ①：对方主要阶段才能发动。用包含这张卡的自己场上的怪兽为同调素材作同调召唤。
function c83295594.initial_effect(c)
	-- ①：对方主要阶段才能发动。用包含这张卡的自己场上的怪兽为同调素材作同调召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83295594,0))  --"同调召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c83295594.sccon)
	e1:SetTarget(c83295594.sctarg)
	e1:SetOperation(c83295594.scop)
	c:RegisterEffect(e1)
end
-- 定义效果发动的条件函数
function c83295594.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 确保自身不在连锁中，且当前是对方的回合
	return not e:GetHandler():IsStatus(STATUS_CHAINING) and Duel.GetTurnPlayer()~=tp
		-- 且当前处于主要阶段1或主要阶段2
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 定义效果发动的目标与检测函数
function c83295594.sctarg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查额外卡组是否存在以这张卡为素材可以进行同调召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	-- 设置在效果处理时将进行特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 定义效果处理的运行函数
function c83295594.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取额外卡组中所有以这张卡为素材可以进行同调召唤的怪兽
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤（同调召唤）的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 以这张卡为素材，对选定的怪兽进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
