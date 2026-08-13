--究極進化薬
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·墓地把恐龙族怪兽和恐龙族以外的怪兽各1只除外才能发动。从手卡·卡组把1只7星以上的恐龙族怪兽无视召唤条件特殊召唤。
function c38179121.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·墓地把1只恐龙族怪兽和1只恐龙族以外的怪兽除外才能发动。从手卡·卡组把1只7星以上的恐龙族怪兽无视召唤条件特殊召唤。
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
-- 定义可作除外的费用怪兽的筛选条件：必须是怪兽且可以作为代价除外。
function c38179121.spcostfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER)
end
-- 确认所选2张费用卡中恐龙族怪兽恰好1只（另一只即非恐龙族怪兽），并在手卡·卡组中存在另一只满足特殊召唤条件的7星以上恐龙族怪兽（不能是已选费用卡）。
function c38179121.fgoal(sg,e,tp)
	return sg:FilterCount(Card.IsRace,nil,RACE_DINOSAUR)==1
		-- 继续检查：在手卡·卡组中检索是否存在满足特殊召唤条件的7星以上恐龙族怪兽，且该卡不在已选为费用的卡中。
		and Duel.IsExistingMatchingCard(c38179121.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,sg,e,tp)
end
-- 定义可被特殊召唤的怪兽的筛选条件：恐龙族、7星以上、怪兽，且能够无视召唤条件特殊召唤。
function c38179121.filter(c,e,tp)
	return c:IsRace(RACE_DINOSAUR) and c:IsLevelAbove(7) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 代价处理：从手卡·墓地选择恐龙族怪兽和非恐龙族怪兽各1只除外，作为发动效果的费用。
function c38179121.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手卡·墓地中可以作为费用除外的所有怪兽卡。
	local rg=Duel.GetMatchingGroup(c38179121.spcostfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
	if chk==0 then return rg:CheckSubGroup(c38179121.fgoal,2,2,e,tp) end
	-- 向玩家显示选择提示，要求选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=rg:SelectSubGroup(tp,c38179121.fgoal,false,2,2,e,tp)
	-- 将选中的费用卡以表侧表示除外，作为发动代价。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 效果发动时检测：自己主要怪兽区域有空位，且手卡·卡组中存在符合条件的7星以上恐龙族怪兽可以特殊召唤。
function c38179121.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己主要怪兽区域是否有可用的空格，作为发动条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测手卡·卡组中是否存在满足特殊召唤条件的7星以上恐龙族怪兽，作为发动条件之一。
		and Duel.IsExistingMatchingCard(c38179121.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 将本次连锁的操作信息设定为特殊召唤（来源为手卡·卡组，数量为1），用于时点及对应效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理：从自己的手卡·卡组选择1只7星以上的恐龙族怪兽，无视召唤条件以表侧表示特殊召唤到自己场上。
function c38179121.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认己方主要怪兽区域仍有空格，若没有则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡·卡组中选出1只满足条件（恐龙族、7星以上、可特殊召唤）的怪兽。
	local g=Duel.SelectMatchingCard(tp,c38179121.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将所选怪兽无视召唤条件，以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
