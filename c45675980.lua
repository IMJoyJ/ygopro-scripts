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
	-- ①：自己·对方回合可以发动。用包含龙族怪兽的自己场上的怪兽为素材进行同调召唤。
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
-- 检查同调素材是否包含龙族怪兽，并验证手卡同调和同调召唤的合法性。
function c45675980.syncheck(g,tp,syncard)
	return g:IsExists(Card.IsRace,1,nil,RACE_DRAGON)
		-- 验证手卡同调和同调召唤的合法性。
		and aux.SynMixHandCheck(g,tp,syncard) and syncard:IsSynchroSummonable(nil,g,#g-1,#g-1)
end
-- 筛选满足同调召唤条件的额外怪兽。
function c45675980.spfilter(c,tp,mg)
	if not c:IsType(TYPE_SYNCHRO) then return false end
	-- 设置同调召唤的等级检查条件。
	aux.GCheckAdditional=aux.SynGroupCheckLevelAddition(c)
	local res=mg:CheckSubGroup(c45675980.syncheck,2,#mg,tp,c)
	-- 清除同调召唤的等级检查条件。
	aux.GCheckAdditional=nil
	return res
end
-- 判断是否可以发动效果并设置操作信息。
function c45675980.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家是否可以特殊召唤。
		if not Duel.IsPlayerCanSpecialSummon(tp) then return false end
		-- 获取玩家的同调素材。
		local mg=Duel.GetSynchroMaterial(tp)
		if mg:IsExists(Card.GetHandSynchro,1,nil) then
			-- 获取玩家手牌中的同调素材。
			local mg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
			if mg2:GetCount()>0 then mg:Merge(mg2) end
		end
		-- 检查是否存在满足条件的同调怪兽。
		return Duel.IsExistingMatchingCard(c45675980.spfilter,tp,LOCATION_EXTRA,0,1,nil,tp,mg)
	end
	-- 设置操作信息，指定将要特殊召唤的卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行同调召唤操作。
function c45675980.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家的同调素材。
	local mg=Duel.GetSynchroMaterial(tp)
	if mg:IsExists(Card.GetHandSynchro,1,nil) then
		-- 获取玩家手牌中的同调素材。
		local mg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
		if mg2:GetCount()>0 then mg:Merge(mg2) end
	end
	-- 筛选满足同调召唤条件的额外怪兽。
	local g=Duel.GetMatchingGroup(c45675980.spfilter,tp,LOCATION_EXTRA,0,nil,tp,mg)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		-- 提示玩家选择要作为同调素材的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)  --"请选择要作为同调素材的卡"
		local tg=mg:SelectSubGroup(tp,c45675980.syncheck,false,2,#mg,tp,sc)
		-- 执行同调召唤手续。
		Duel.SynchroSummon(tp,sc,nil,tg,#tg-1,#tg-1)
	end
end
-- 判断是否满足效果发动条件。
function c45675980.rmcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查场上是否存在「深渊之兽」怪兽。
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,1,nil,0x188)
end
-- 判断卡牌是否因仪式召唤或融合/同调/连接召唤而被送去墓地。
function c45675980.rmtg(e,c)
	local tp=e:GetHandlerPlayer()
	local b1=c:IsReason(REASON_RITUAL) and c:IsReason(REASON_RELEASE)
	local b2=c:IsReason(REASON_FUSION+REASON_SYNCHRO+REASON_LINK)
	return c:GetOwner()==1-tp and c:GetReasonPlayer()==1-tp and (b1 or b2)
end
