--アクアアクトレス・グッピー
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。从手卡把1只「水伶女」怪兽特殊召唤。
function c66668900.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。从手卡把1只「水伶女」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c66668900.sptg)
	e1:SetOperation(c66668900.spop)
	c:RegisterEffect(e1)
end
-- 过滤手卡中可以特殊召唤的「水伶女」怪兽
function c66668900.filter(c,e,tp)
	return c:IsSetCard(0xcd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标检查，确认怪兽区域有空位且手卡有可特殊召唤的「水伶女」怪兽
function c66668900.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足过滤条件的「水伶女」怪兽
		and Duel.IsExistingMatchingCard(c66668900.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示将从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理的执行，从手卡选择1只「水伶女」怪兽特殊召唤到场上
function c66668900.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足过滤条件的「水伶女」怪兽
	local g=Duel.SelectMatchingCard(tp,c66668900.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
