--女王の選択
-- 效果：
-- 自己场上存在的名字带有「亚马逊」的怪兽战斗破坏对方怪兽送去墓地时才能发动。从自己卡组把1只4星以下的名字带有「亚马逊」的怪兽特殊召唤。
function c58477767.initial_effect(c)
	-- 自己场上存在的名字带有「亚马逊」的怪兽战斗破坏对方怪兽送去墓地时才能发动。从自己卡组把1只4星以下的名字带有「亚马逊」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c58477767.condition)
	e1:SetTarget(c58477767.target)
	e1:SetOperation(c58477767.operation)
	c:RegisterEffect(e1)
end
-- 检查c1是否是被战斗破坏送去对方墓地的怪兽，且c2是自己场上的「亚马逊」怪兽
function c58477767.check(c1,c2,tp)
	return c1:IsLocation(LOCATION_GRAVE) and c1:IsReason(REASON_BATTLE) and c1:IsPreviousControler(1-tp) and c2:IsSetCard(0x4)
end
-- 发动条件判断：检查被战斗破坏的怪兽和进行战斗的怪兽是否满足「亚马逊」怪兽战斗破坏对方怪兽送去墓地的条件
function c58477767.condition(e,tp,eg,ep,ev,re,r,rp)
	local dc=eg:GetFirst()
	local bc=dc:GetBattleTarget()
	return c58477767.check(dc,bc,tp) or c58477767.check(bc,dc,tp)
end
-- 过滤卡组中等级4以下、可以特殊召唤的「亚马逊」怪兽
function c58477767.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标选择与检测函数，检查怪兽区域是否有空位以及卡组中是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息
function c58477767.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动时，检查自己卡组中是否存在至少1只满足条件的「亚马逊」怪兽
		and Duel.IsExistingMatchingCard(c58477767.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数，从卡组中选择1只满足条件的「亚马逊」怪兽特殊召唤到场上
function c58477767.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，如果自己场上没有可用的怪兽区域空位，则不进行处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足条件的「亚马逊」怪兽
	local g=Duel.SelectMatchingCard(tp,c58477767.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
