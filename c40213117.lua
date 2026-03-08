--魔導弓士 ラムール
-- 效果：
-- 1回合1次，把手卡1张名字带有「魔导书」的魔法卡给对方观看才能发动。从手卡把1只4星以下的魔法师族怪兽特殊召唤。
function c40213117.initial_effect(c)
	-- 效果原文内容：1回合1次，把手卡1张名字带有「魔导书」的魔法卡给对方观看才能发动。从手卡把1只4星以下的魔法师族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40213117,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c40213117.spcost)
	e1:SetTarget(c40213117.sptg)
	e1:SetOperation(c40213117.spop)
	c:RegisterEffect(e1)
end
-- 规则层面作用：定义过滤函数，用于筛选手卡中未公开的「魔导书」魔法卡。
function c40213117.cffilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and not c:IsPublic()
end
-- 规则层面作用：效果发动时的费用处理，选择并确认一张手卡中的「魔导书」魔法卡。
function c40213117.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查是否满足发动条件，即手卡中存在至少一张未公开的「魔导书」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c40213117.cffilter,tp,LOCATION_HAND,0,1,nil) end
	-- 规则层面作用：向玩家提示选择要确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 规则层面作用：选择满足条件的「魔导书」魔法卡。
	local g=Duel.SelectMatchingCard(tp,c40213117.cffilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 规则层面作用：将所选卡确认给对方玩家观看。
	Duel.ConfirmCards(1-tp,g)
	-- 规则层面作用：将玩家手卡洗牌。
	Duel.ShuffleHand(tp)
end
-- 规则层面作用：定义过滤函数，用于筛选手卡中4星以下的魔法师族怪兽。
function c40213117.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：效果发动时的取对象处理，检查是否有满足条件的怪兽可特殊召唤。
function c40213117.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查玩家场上是否有空位可进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：检查手卡中是否存在满足条件的魔法师族怪兽。
		and Duel.IsExistingMatchingCard(c40213117.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 规则层面作用：设置连锁操作信息，表示本次效果将特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 规则层面作用：效果发动时的处理，选择并特殊召唤满足条件的魔法师族怪兽。
function c40213117.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查玩家场上是否有空位可进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面作用：向玩家提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：选择满足条件的魔法师族怪兽。
	local g=Duel.SelectMatchingCard(tp,c40213117.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面作用：将所选怪兽以正面表示形式特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
