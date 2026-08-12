--マタドール降臨の儀式 ダーク・パセオ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：等级合计直到6以上的自己的手卡·场上的怪兽解放，从手卡把「恶魔斗牛士」仪式召唤。
-- ②：把墓地的这张卡除外才能发动。从手卡把仪式怪兽以外的1只「恶魔」怪兽特殊召唤。
local s,id,o=GetID()
-- 定义卡片效果的初始化函数，注册仪式召唤效果和墓地除外特召效果。
function s.initial_effect(c)
	-- 注册仪式召唤效果，指定仪式怪兽为「恶魔斗牛士」，解放等级合计需在6以上。
	aux.AddRitualProcGreaterCode(c,7622360)
	-- 这个卡名的②的效果1回合只能使用1次。②：把墓地的这张卡除外才能发动。从手卡把仪式怪兽以外的1只「恶魔」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从手卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 设置发动代价为把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选手卡中非仪式怪兽的「恶魔」怪兽，且该怪兽可以被特殊召唤。
function s.spfilter(c,e,tp)
	return not c:IsType(TYPE_RITUAL) and c:IsSetCard(0x45) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标检查函数，判断是否满足发动条件并设置操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动时，检查手卡中是否存在至少1只满足条件的「恶魔」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,e:GetHandler(),e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数，执行从手卡特殊召唤「恶魔」怪兽的操作。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域，则不处理效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的「恶魔」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
