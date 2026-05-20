--XX－セイバー ボガーナイト
-- 效果：
-- 把这张卡作为同调素材的场合，不是「X-剑士」怪兽的同调召唤不能使用。
-- ①：这张卡召唤时才能发动。从手卡把1只4星以下的「X-剑士」怪兽特殊召唤。
function c5998840.initial_effect(c)
	-- ①：这张卡召唤时才能发动。从手卡把1只4星以下的「X-剑士」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5998840,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c5998840.sumtg)
	e1:SetOperation(c5998840.sumop)
	c:RegisterEffect(e1)
	-- 把这张卡作为同调素材的场合，不是「X-剑士」怪兽的同调召唤不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(c5998840.synlimit)
	c:RegisterEffect(e2)
end
-- 限制该卡只能作为「X-剑士」怪兽同调召唤的素材
function c5998840.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x100d)
end
-- 过滤手卡中等级4以下且卡名含有「X-剑士」的可以特殊召唤的怪兽
function c5998840.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x100d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的可行性检查与操作信息设置
function c5998840.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足条件的「X-剑士」怪兽
		and Duel.IsExistingMatchingCard(c5998840.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息，表示将从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理，从手卡特殊召唤1只「X-剑士」怪兽
function c5998840.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上已无可用怪兽区域，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡选择1只满足条件的「X-剑士」怪兽
	local g=Duel.SelectMatchingCard(tp,c5998840.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
