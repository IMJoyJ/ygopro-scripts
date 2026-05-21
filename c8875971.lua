--光天使ウィングス
-- 效果：
-- 这张卡召唤成功时，可以从手卡把1只名字带有「光天使」的怪兽特殊召唤。
function c8875971.initial_effect(c)
	-- 这张卡召唤成功时，可以从手卡把1只名字带有「光天使」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8875971,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c8875971.sptg)
	e1:SetOperation(c8875971.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：手牌中可以特殊召唤的「光天使」怪兽
function c8875971.spfilter(c,e,tp)
	return c:IsSetCard(0x86) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标：检查怪兽区域是否有空位，以及手牌中是否存在可特殊召唤的「光天使」怪兽
function c8875971.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足特殊召唤条件的「光天使」怪兽
		and Duel.IsExistingMatchingCard(c8875971.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁信息，表示该效果包含从手牌特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：在怪兽区域有空位的情况下，让玩家从手牌选择1只「光天使」怪兽特殊召唤
function c8875971.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查怪兽区域空位数，若无空位则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1只满足条件的「光天使」怪兽
	local g=Duel.SelectMatchingCard(tp,c8875971.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
