--TG カタパルト・ドラゴン
-- 效果：
-- 1回合1次，可以从手卡把1只3星以下的名字带有「科技属」的调整特殊召唤。
function c64898834.initial_effect(c)
	-- 1回合1次，可以从手卡把1只3星以下的名字带有「科技属」的调整特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64898834,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c64898834.sptg)
	e1:SetOperation(c64898834.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡中等级3以下的名字带有「科技属」的调整怪兽，且该怪兽可以被特殊召唤
function c64898834.filter(c,e,tp)
	return c:IsSetCard(0x27) and c:IsLevelBelow(3) and c:IsType(TYPE_TUNER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标检查与信息设置：检查怪兽区域是否有空位，以及手卡中是否存在满足过滤条件的怪兽
function c64898834.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c64898834.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁信息：该效果包含从手卡特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：在怪兽区域有空位的情况下，让玩家选择手卡中满足条件的怪兽并特殊召唤
function c64898834.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空位，若无则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c64898834.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
