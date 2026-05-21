--万華鏡－華麗なる分身－
-- 效果：
-- ①：场上有「鹰身女郎」存在的场合才能发动。从手卡·卡组把1只「鹰身女郎」或「鹰身女郎三姐妹」特殊召唤。
function c90219263.initial_effect(c)
	-- 在卡片中记录其记载了「鹰身女郎三姐妹」的卡片密码
	aux.AddCodeList(c,12206212)
	-- ①：场上有「鹰身女郎」存在的场合才能发动。从手卡·卡组把1只「鹰身女郎」或「鹰身女郎三姐妹」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c90219263.condition)
	e1:SetTarget(c90219263.target)
	e1:SetOperation(c90219263.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的「鹰身女郎」
function c90219263.cfilter(c)
	return c:IsFaceup() and c:IsCode(76812113)
end
-- 发动条件：场上有「鹰身女郎」存在
function c90219263.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场上是否存在至少1张表侧表示的「鹰身女郎」
	return Duel.IsExistingMatchingCard(c90219263.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 过滤条件：手卡或卡组中可以特殊召唤的「鹰身女郎」或「鹰身女郎三姐妹」
function c90219263.filter(c,e,tp)
	return c:IsCode(76812113,12206212) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 发动时的效果目标检查：检查怪兽区域空位以及手卡、卡组中是否存在可特殊召唤的怪兽
function c90219263.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否存在至少1只满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c90219263.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，涉及手卡和卡组中的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理：从手卡或卡组将1只「鹰身女郎」或「鹰身女郎三姐妹」特殊召唤
function c90219263.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时己方主要怪兽区域没有空位，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只满足特殊召唤条件的「鹰身女郎」或「鹰身女郎三姐妹」
	local g=Duel.SelectMatchingCard(tp,c90219263.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功选择怪兽，则将其无视召唤条件以表侧表示特殊召唤
	if tc and Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)~=0 then
		tc:CompleteProcedure()
	end
end
