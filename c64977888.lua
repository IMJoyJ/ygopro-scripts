--見習い魔笛使い
-- 效果：
-- ①：这张卡反转的场合才能发动。从手卡把1只怪兽特殊召唤。
-- ②：这张卡被战斗·效果破坏送去墓地的场合才能发动。从手卡把1只怪兽特殊召唤。
function c64977888.initial_effect(c)
	-- ①：这张卡反转的场合才能发动。从手卡把1只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64977888,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c64977888.sptg)
	e1:SetOperation(c64977888.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗·效果破坏送去墓地的场合才能发动。从手卡把1只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64977888,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c64977888.spcon)
	e2:SetTarget(c64977888.sptg)
	e2:SetOperation(c64977888.spop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中可以特殊召唤的怪兽
function c64977888.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的目标检查与操作信息设置
function c64977888.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只可以特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c64977888.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，表示此效果包含从手卡特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果的具体处理
function c64977888.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足特殊召唤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c64977888.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检查此卡是否因战斗或效果破坏而送去墓地
function c64977888.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
