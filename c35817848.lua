--シンクロ・トランスミッション
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。进行1只同调怪兽的同调召唤。
-- ②：自己主要阶段，把这个回合没有送去墓地的这张卡从墓地除外，以自己墓地1只同调怪兽为对象才能发动。那只怪兽回到额外卡组。那之后，自己抽1张。
function c35817848.initial_effect(c)
	-- ①：自己·对方的主要阶段才能发动。进行1只同调怪兽的同调召唤。
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
	-- 将这张卡从墓地除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c35817848.tdtg)
	e2:SetOperation(c35817848.tdop)
	c:RegisterEffect(e2)
end
-- ①：自己·对方的主要阶段才能发动。
function c35817848.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- ①：自己·对方的主要阶段才能发动。
function c35817848.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己额外卡组是否存在可同调召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil) end
	-- 设置效果处理时将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①：自己·对方的主要阶段才能发动。
function c35817848.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己额外卡组中所有可同调召唤的怪兽
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 进行一次同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),nil)
	end
end
-- ②：自己主要阶段，把这个回合没有送去墓地的这张卡从墓地除外，以自己墓地1只同调怪兽为对象才能发动。
function c35817848.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查此卡未在本回合送去墓地，且当前为自己的主要阶段
	return aux.exccon(e) and Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 过滤函数：判断是否为同调怪兽且能返回额外卡组
function c35817848.tdfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
end
-- ②：自己主要阶段，把这个回合没有送去墓地的这张卡从墓地除外，以自己墓地1只同调怪兽为对象才能发动。
function c35817848.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c35817848.tdfilter(chkc) end
	-- 检查自己墓地是否存在满足条件的同调怪兽
	if chk==0 then return Duel.IsExistingTarget(c35817848.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择一只满足条件的墓地同调怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c35817848.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理时将要返回额外卡组的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
	-- 设置效果处理时将要抽一张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②：自己主要阶段，把这个回合没有送去墓地的这张卡从墓地除外，以自己墓地1只同调怪兽为对象才能发动。
function c35817848.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽有效且成功送回卡组
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)~=0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 自己抽一张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
