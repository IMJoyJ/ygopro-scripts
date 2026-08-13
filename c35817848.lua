--シンクロ・トランスミッション
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。进行1只同调怪兽的同调召唤。
-- ②：自己主要阶段，把这个回合没有送去墓地的这张卡从墓地除外，以自己墓地1只同调怪兽为对象才能发动。那只怪兽回到额外卡组。那之后，自己抽1张。
function c35817848.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己·对方的主要阶段才能发动。进行1只同调怪兽的同调召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,35817848)
	e1:SetCondition(c35817848.sccon)
	e1:SetTarget(c35817848.sctg)
	e1:SetOperation(c35817848.scop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段，把这个回合没有送去墓地的这张卡从墓地除外，以自己墓地1只同调怪兽为对象才能发动。那只怪兽回到额外卡组。那之后，自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,35817849)
	e2:SetCondition(c35817848.tdcon)
	-- 设置②效果的发动代价：从墓地除外这张卡（作为COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c35817848.tdtg)
	e2:SetOperation(c35817848.tdop)
	c:RegisterEffect(e2)
end
-- 定义①效果的发动条件：当前阶段必须处于主要阶段1或主要阶段2（自己或对方的主要阶段均可发动）。
function c35817848.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段并保存到局部变量ph，用于判断是否为主要阶段。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 定义①效果的发动目标处理：确认额外卡组存在可同调召唤的同调怪兽，并设置特殊召唤的操作信息。
function c35817848.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查时，确认自己额外卡组中是否存在至少1只满足同调召唤条件的同调怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil) end
	-- 设置本次效果的处理信息：进行特殊召唤，预计从自己的额外卡组特殊召唤1只怪兽（对象在效果处理时选定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 定义①效果的实际处理：从额外卡组选择1只可同调召唤的同调怪兽，并以场上的怪兽为素材进行同调召唤。
function c35817848.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己额外卡组中所有满足同调召唤条件的同调怪兽，构成可供选择的候选组g。
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
	if g:GetCount()>0 then
		-- 向操作者显示选择提示，要求其选择要特殊召唤的同调怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 执行同调召唤：将选中的同调怪兽以玩家tp进行同调召唤（素材自动选择场上满足条件的调整+调整以外怪兽）。
		Duel.SynchroSummon(tp,sg:GetFirst(),nil)
	end
end
-- 定义②效果的发动条件：该卡不是本回合被送去墓地，且在自己回合的主要阶段1或2才能发动。
function c35817848.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 满足三条件：1)此卡不是本回合送去墓地（aux.exccon）；2)当前回合玩家是自己；3)当前阶段为自己主要阶段1或2。
	return aux.exccon(e) and Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 定义②效果对象筛选条件：对象必须是同调怪兽，并且能够返回额外卡组。
function c35817848.tdfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
end
-- 定义②效果的发动目标处理：确认自己墓地有合法对象，选择1张同调怪兽作为对象，并设置返回额外卡组与抽卡的操作信息。
function c35817848.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c35817848.tdfilter(chkc) end
	-- 在发动合法性检查时，确认自己墓地存在至少1只满足条件（同调怪兽且可回额外）的卡可作为对象，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c35817848.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向操作者显示选择提示，要求其选择要返回卡组的同调怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择1张符合条件的同调怪兽，将其登记为本次连锁的对象。
	local g=Duel.SelectTarget(tp,c35817848.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将对象卡返回额外卡组（CATEGORY_TOEXTRA），对象为已选择的那张卡，数量1。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
	-- 设置操作信息：本次效果包含自己抽1张卡（CATEGORY_DRAW），抽卡玩家为tp，数量1。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义②效果的实际处理：若对象仍与效果相关，将其返回额外卡组顶端；若成功，则随后自己抽1张。
function c35817848.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果发动时选择的对象卡，存入局部变量tc。
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡仍与效果相关且将其返回持有者额外卡组顶端成功（返回值≠0），才继续后续抽卡处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)~=0 then
		-- 中断当前效果处理，使“返回额外卡组”与之后的“抽卡”视为不同时处理，避免造成错误时点。
		Duel.BreakEffect()
		-- 让自己抽1张卡，原因记为效果（REASON_EFFECT）。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
