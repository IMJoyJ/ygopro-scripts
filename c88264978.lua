--レッドアイズ・ダークネスメタルドラゴン
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以把自己场上1只表侧表示的龙族怪兽除外，从手卡特殊召唤。
-- ②：自己主要阶段才能发动。从自己的手卡·墓地把「真红眼暗钢龙」以外的1只龙族怪兽特殊召唤。
function c88264978.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：这张卡可以把自己场上1只表侧表示的龙族怪兽除外，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,88264978+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c88264978.hspcon)
	e1:SetTarget(c88264978.hsptg)
	e1:SetOperation(c88264978.hspop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己主要阶段才能发动。从自己的手卡·墓地把「真红眼暗钢龙」以外的1只龙族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88264978,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,88264979)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c88264978.sptg)
	e2:SetOperation(c88264978.spop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示、可以作为除外Cost、且除外后能腾出怪兽区域的龙族怪兽
function c88264978.spfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAbleToRemoveAsCost()
		-- 检查将该怪兽除外后，自己场上是否有可用于特殊召唤的空怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则的Condition函数，判断手卡特殊召唤的条件是否满足
function c88264978.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1只满足条件的表侧表示龙族怪兽
	return Duel.IsExistingMatchingCard(c88264978.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 特殊召唤规则的Target函数，用于选择除外的怪兽
function c88264978.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足除外条件的龙族怪兽组
	local g=Duel.GetMatchingGroup(c88264978.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 给玩家发送“请选择要除外的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的Operation函数，执行除外并特殊召唤的操作
function c88264978.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的怪兽因特殊召唤原因表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 过滤手卡或墓地中除「真红眼暗钢龙」以外的、可以特殊召唤的龙族怪兽
function c88264978.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and not c:IsCode(88264978) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的Target函数，检查发动条件并设置操作信息
function c88264978.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果时，检查自己场上是否有可用的空怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查自己的手卡或墓地是否存在至少1只满足特殊召唤条件的龙族怪兽
		and Duel.IsExistingMatchingCard(c88264978.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果②的Operation函数，执行特殊召唤的处理
function c88264978.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的空怪兽区域，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送“请选择要特殊召唤的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或墓地选择1只满足条件的龙族怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c88264978.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
