--H・C ダブル・ランス
-- 效果：
-- 这张卡召唤成功时，可以从自己的手卡·墓地选1只「英豪挑战者 双长枪兵」表侧守备表示特殊召唤。这张卡不能作为同调素材。此外，把这张卡作为超量素材的场合，不是战士族怪兽的超量召唤不能使用。
function c89774530.initial_effect(c)
	-- 这张卡召唤成功时，可以从自己的手卡·墓地选1只「英豪挑战者 双长枪兵」表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89774530,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c89774530.sptg)
	e1:SetOperation(c89774530.spop)
	c:RegisterEffect(e1)
	-- 这张卡不能作为同调素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 此外，把这张卡作为超量素材的场合，不是战士族怪兽的超量召唤不能使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetValue(c89774530.xyzlimit)
	c:RegisterEffect(e3)
end
-- 过滤函数：寻找手卡或墓地中可以表侧守备表示特殊召唤的「英豪挑战者 双长枪兵」
function c89774530.filter(c,e,tp)
	return c:IsCode(89774530) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特殊召唤效果的发动条件与效果处理确定
function c89774530.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 以及手卡或墓地是否存在至少1只满足过滤条件的卡
		and Duel.IsExistingMatchingCard(c89774530.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，包含特殊召唤分类、数量1、位置为手卡或墓地
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 特殊召唤效果的具体效果处理
function c89774530.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上怪兽区域是否已满，若无空位则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 在客户端显示“请选择要特殊召唤的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或墓地选择1只满足条件的卡（适用墓地相关卡片效果的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c89774530.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 超量素材限制函数：限制不能作为非战士族怪兽的超量召唤素材
function c89774530.xyzlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_WARRIOR)
end
