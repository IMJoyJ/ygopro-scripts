--究極進化薬
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·墓地把恐龙族怪兽和恐龙族以外的怪兽各1只除外才能发动。从手卡·卡组把1只7星以上的恐龙族怪兽无视召唤条件特殊召唤。
function c38179121.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,38179121+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c38179121.cost)
	e1:SetTarget(c38179121.target)
	e1:SetOperation(c38179121.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查手卡·墓地中的怪兽是否满足除外条件
function c38179121.spcostfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER)
end
-- 效果作用：判断所选的除外怪兽中是否包含1只恐龙族怪兽，并且确认卡组·手卡中存在满足条件的7星以上恐龙族怪兽
function c38179121.fgoal(sg,e,tp)
	return sg:FilterCount(Card.IsRace,nil,RACE_DINOSAUR)==1
		-- 效果作用：确认卡组·手卡中存在满足条件的7星以上恐龙族怪兽
		and Duel.IsExistingMatchingCard(c38179121.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,sg,e,tp)
end
-- 效果作用：筛选7星以上且为恐龙族的怪兽，且可以被特殊召唤
function c38179121.filter(c,e,tp)
	return c:IsRace(RACE_DINOSAUR) and c:IsLevelAbove(7) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果作用：发动时从手卡·墓地选择1只恐龙族怪兽和1只非恐龙族怪兽除外作为代价
function c38179121.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：获取手卡·墓地中的所有怪兽作为可选除外对象
	local rg=Duel.GetMatchingGroup(c38179121.spcostfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
	if chk==0 then return rg:CheckSubGroup(c38179121.fgoal,2,2,e,tp) end
	-- 效果作用：提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=rg:SelectSubGroup(tp,c38179121.fgoal,false,2,2,e,tp)
	-- 效果作用：将所选的卡除外作为发动代价
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 效果作用：设置发动时的处理信息，确认场上存在召唤怪兽的空间并卡组·手卡中存在满足条件的怪兽
function c38179121.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：确认场上存在召唤怪兽的空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：确认卡组·手卡中存在满足条件的7星以上恐龙族怪兽
		and Duel.IsExistingMatchingCard(c38179121.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 效果作用：设置连锁操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果作用：发动效果时从卡组·手卡中选择1只7星以上的恐龙族怪兽特殊召唤
function c38179121.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断场上是否还有召唤怪兽的空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：从卡组·手卡中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c38179121.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 效果作用：将所选的怪兽无视召唤条件特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
