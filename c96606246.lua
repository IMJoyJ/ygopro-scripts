--EMフレンドンキー
-- 效果：
-- ①：这张卡召唤成功时才能发动。从自己的手卡·墓地选1只4星以下的「娱乐伙伴」怪兽特殊召唤。
function c96606246.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从自己的手卡·墓地选1只4星以下的「娱乐伙伴」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96606246,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c96606246.sptg)
	e1:SetOperation(c96606246.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否为「娱乐伙伴」怪兽、等级4以下，且可以被特殊召唤
function c96606246.filter(c,e,tp)
	return c:IsSetCard(0x9f) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标：检查自身怪兽区域是否有空位，以及手卡或墓地是否存在满足条件的怪兽
function c96606246.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动阶段，检查自己的手卡或墓地是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c96606246.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁信息，表示该效果包含从手卡或墓地特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理：在怪兽区域有空位的情况下，让玩家从手卡或墓地选择1只满足条件的怪兽特殊召唤
function c96606246.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，如果自己场上没有可用的怪兽区域，则不进行处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡或墓地选择1只满足过滤条件且不受「王家长眠之谷」影响的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c96606246.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
