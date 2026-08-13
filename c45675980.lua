--烙印の即凶劇
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方回合可以发动。用包含龙族怪兽的自己场上的怪兽为素材进行同调召唤。
-- ②：只要自己场上有「深渊之兽」怪兽存在，为对方的仪式召唤而被解放送去对方墓地的怪兽以及成为对方的融合·同调·连接召唤的素材送去对方墓地的怪兽不去墓地而除外。
function c45675980.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己·对方回合可以发动。用包含龙族怪兽的自己场上的怪兽为素材进行同调召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45675980,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,45675980)
	e1:SetTarget(c45675980.sctg)
	e1:SetOperation(c45675980.scop)
	c:RegisterEffect(e1)
	-- ②：只要自己场上有「深渊之兽」怪兽存在，为对方的仪式召唤而被解放送去对方墓地的怪兽以及成为对方的融合·同调·连接召唤的素材送去对方墓地的怪兽不去墓地而除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetValue(LOCATION_REMOVED)
	e2:SetCondition(c45675980.rmcon)
	e2:SetTarget(c45675980.rmtg)
	c:RegisterEffect(e2)
end
-- 检查候选素材组g是否满足本次同调召唤的要求：其中至少包含1只龙族怪兽，通过手牌同调合法性检查，并确认同调怪兽syncard可以用g为素材进行同调召唤（非调整素材数量为#g-1）。
function c45675980.syncheck(g,tp,syncard)
	return g:IsExists(Card.IsRace,1,nil,RACE_DRAGON)
		-- 确认素材组g符合手牌同调规则，且目标同调怪兽syncard能够以g为素材进行同调召唤（非调整素材数量为#g-1）。
		and aux.SynMixHandCheck(g,tp,syncard) and syncard:IsSynchroSummonable(nil,g,#g-1,#g-1)
end
-- 筛选额外卡组中可作为本次同调召唤目标的怪兽：必须为同调怪兽，且当前可用素材组mg中存在至少一组满足syncheck的素材组合。
function c45675980.spfilter(c,tp,mg)
	if not c:IsType(TYPE_SYNCHRO) then return false end
	-- 设置临时的全局附加检查函数，使后续素材组筛选按目标同调怪兽c的等级检查素材等级之和。
	aux.GCheckAdditional=aux.SynGroupCheckLevelAddition(c)
	local res=mg:CheckSubGroup(c45675980.syncheck,2,#mg,tp,c)
	-- 清除临时全局附加检查函数，避免影响其他效果或后续检查。
	aux.GCheckAdditional=nil
	return res
end
-- ①效果发动时的目标判定：确认玩家可以特殊召唤，获取场上可能的手牌同调素材，并确认额外卡组存在符合条件的同调怪兽；满足后登记本次操作信息为从额外卡组特殊召唤1只怪兽。
function c45675980.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 若当前玩家不能进行特殊召唤，则不能发动该效果。
		if not Duel.IsPlayerCanSpecialSummon(tp) then return false end
		-- 获取玩家tp当前可以作为同调素材的怪兽组（通常为场上怪兽）。
		local mg=Duel.GetSynchroMaterial(tp)
		if mg:IsExists(Card.GetHandSynchro,1,nil) then
			-- 获取玩家tp手牌中的全部卡，作为手牌同调时的候选素材。
			local mg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
			if mg2:GetCount()>0 then mg:Merge(mg2) end
		end
		-- 检查额外卡组中是否存在至少1只满足同调召唤条件的同调怪兽（即spfilter为真的怪兽）。
		return Duel.IsExistingMatchingCard(c45675980.spfilter,tp,LOCATION_EXTRA,0,1,nil,tp,mg)
	end
	-- 登记效果操作信息：本效果将特殊召唤1只额外卡组的怪兽，供其他卡的连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果处理：重新获取可用素材，从额外卡组选择要同调召唤的同调怪兽，再选择满足条件的素材组，执行同调召唤。
function c45675980.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取玩家tp当前可以作为同调素材的怪兽组。
	local mg=Duel.GetSynchroMaterial(tp)
	if mg:IsExists(Card.GetHandSynchro,1,nil) then
		-- 效果处理时获取玩家tp手牌中的全部卡作为手牌同调候选素材。
		local mg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
		if mg2:GetCount()>0 then mg:Merge(mg2) end
	end
	-- 筛选出额外卡组中所有可作为本次同调召唤目标的同调怪兽。
	local g=Duel.GetMatchingGroup(c45675980.spfilter,tp,LOCATION_EXTRA,0,nil,tp,mg)
	if g:GetCount()>0 then
		-- 提示玩家在额外卡组中选择要特殊召唤的同调怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		-- 提示玩家选择要作为同调素材的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)  --"请选择要作为同调素材的卡"
		local tg=mg:SelectSubGroup(tp,c45675980.syncheck,false,2,#mg,tp,sc)
		-- 以选择的素材组tg为素材，对sc进行同调召唤，其中非调整素材数量为#tg-1。
		Duel.SynchroSummon(tp,sc,nil,tg,#tg-1,#tg-1)
	end
end
-- ②效果的适用条件：自己场上存在表侧表示的「深渊之兽」怪兽。
function c45675980.rmcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己怪兽区是否存在表侧表示且字段为「深渊之兽」（0x188）的怪兽。
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,1,nil,0x188)
end
-- 当一张卡的持有者以及导致其送去墓地的玩家均为对方，且该卡是因仪式召唤被解放或是作为融合·同调·连接召唤素材而送去墓地时，将其改为除外（不去墓地）。
function c45675980.rmtg(e,c)
	local tp=e:GetHandlerPlayer()
	local b1=c:IsReason(REASON_RITUAL) and c:IsReason(REASON_RELEASE)
	local b2=c:IsReason(REASON_FUSION+REASON_SYNCHRO+REASON_LINK)
	return c:GetOwner()==1-tp and c:GetReasonPlayer()==1-tp and (b1 or b2)
end
