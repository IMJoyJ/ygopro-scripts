--素早いビーバー
-- 效果：
-- ①：这张卡召唤成功时才能发动。从自己的卡组·墓地选1只3星以下的「迅捷」怪兽特殊召唤。
function c68353324.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从自己的卡组·墓地选1只3星以下的「迅捷」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68353324,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c68353324.sptg)
	e1:SetOperation(c68353324.spop)
	c:RegisterEffect(e1)
end
-- 过滤出卡名含有「迅捷」、等级在3星以下且可以被特殊召唤的怪兽
function c68353324.filter(c,e,tp)
	return c:IsSetCard(0x78) and c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的可行性检查，确认自身主要怪兽区域有空位，且卡组或墓地存在至少1只符合条件的怪兽
function c68353324.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家的主要怪兽区域是否有可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的卡组或墓地中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c68353324.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果包含从卡组或墓地特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理，在怪兽区域有空位的情况下，从卡组或墓地选择1只符合条件的怪兽特殊召唤
function c68353324.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家的主要怪兽区域是否仍有空位，若无则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向发动效果的玩家发送提示信息，提示其选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的卡组或墓地中选择1只满足过滤条件且不受「王家长眠之谷」影响的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c68353324.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到当前玩家的场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
