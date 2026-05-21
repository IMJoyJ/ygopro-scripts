--D－スピリッツ
-- 效果：
-- 自己场上没有名字带有「命运英雄」的怪兽存在的场合，可以从手卡特殊召唤1只4星以下的名字带有「命运英雄」的怪兽。
function c89899996.initial_effect(c)
	-- 自己场上没有名字带有「命运英雄」的怪兽存在的场合，可以从手卡特殊召唤1只4星以下的名字带有「命运英雄」的怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c89899996.target)
	e1:SetOperation(c89899996.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「命运英雄」怪兽
function c89899996.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc008)
end
-- 过滤条件：手卡中等级4以下且可以特殊召唤的「命运英雄」怪兽
function c89899996.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0xc008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的可行性检查（有可用怪兽区域、手卡有可特召的怪兽、且场上没有「命运英雄」怪兽）
function c89899996.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足特召条件的4星以下「命运英雄」怪兽
		and Duel.IsExistingMatchingCard(c89899996.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 检查自己场上是否不存在表侧表示的「命运英雄」怪兽
		and not Duel.IsExistingMatchingCard(c89899996.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置效果处理信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：若此时场上已存在「命运英雄」怪兽或没有可用怪兽区域，则不处理效果
function c89899996.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查此时自己场上是否已存在表侧表示的「命运英雄」怪兽
	if Duel.IsExistingMatchingCard(c89899996.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 或者自己场上已没有可用的怪兽区域，则直接结束效果处理
		or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡选择1只满足特召条件的4星以下「命运英雄」怪兽
	local g=Duel.SelectMatchingCard(tp,c89899996.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()~=0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
