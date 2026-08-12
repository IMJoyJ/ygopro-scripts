--魔神アーク・マキナ
-- 效果：
-- ①：这张卡给与对方战斗伤害时才能发动。从自己的手卡·墓地选1只通常怪兽特殊召唤。
function c93715853.initial_effect(c)
	-- ①：这张卡给与对方战斗伤害时才能发动。从自己的手卡·墓地选1只通常怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c93715853.spcon)
	e1:SetTarget(c93715853.sptg)
	e1:SetOperation(c93715853.spop)
	c:RegisterEffect(e1)
end
-- 发动条件：检查受到战斗伤害的是否为对方玩家
function c93715853.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤条件：手卡·墓地中可以特殊召唤的通常怪兽
function c93715853.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标检查与操作信息设置
function c93715853.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己手卡或墓地存在至少1只满足条件的通常怪兽
		and Duel.IsExistingMatchingCard(c93715853.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理：从手卡·墓地选1只通常怪兽特殊召唤
function c93715853.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡或墓地选择1只满足条件的通常怪兽（适用王家长眠之谷的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c93715853.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
