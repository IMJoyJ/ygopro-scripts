--万華鏡－華麗なる分身－
-- 效果：
-- ①：场上有「鹰身女郎」存在的场合才能发动。从手卡·卡组把1只「鹰身女郎」或「鹰身女郎三姐妹」特殊召唤。
function c90219263.initial_effect(c)
	-- 记录这张卡文本中记述了「鹰身女郎」(76812113)和「鹰身女郎三姐妹」(12206212)卡名的事实
	aux.AddCodeList(c,76812113,12206212)
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
-- 过滤函数，筛选表侧表示且卡号为「鹰身女郎」(76812113)的卡
function c90219263.cfilter(c)
	return c:IsFaceup() and c:IsCode(76812113)
end
-- ①效果的Condition函数，检查双方场上是否存在表侧表示的「鹰身女郎」
function c90219263.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场上是否存在至少1张满足cfilter条件的「鹰身女郎」
	return Duel.IsExistingMatchingCard(c90219263.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 过滤函数，筛选卡号为「鹰身女郎」(76812113)或「鹰身女郎三姐妹」(12206212)且可无视召唤条件特殊召唤的怪兽
function c90219263.filter(c,e,tp)
	return c:IsCode(76812113,12206212) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ①效果的Target函数，检测怪兽区空格及手卡·卡组存在可特招的「鹰身女郎」或「鹰身女郎三姐妹」，并设置特殊召唤操作信息
function c90219263.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测时，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡·卡组是否存在至少1只满足filter条件可特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c90219263.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，声明将从自己的手卡·卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ①效果的Operation函数，从自己手卡·卡组选择1只「鹰身女郎」或「鹰身女郎三姐妹」无视召唤条件特殊召唤并完成正规召唤程序
function c90219263.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己怪兽区没有可用空格则终止效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向自己发送选择提示信息：“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己在手卡·卡组中选择1只满足filter条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c90219263.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若存在选中怪兽tc，则将其无视召唤条件以表侧表示特殊召唤到自己场上并判断是否成功
	if tc and Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)~=0 then
		tc:CompleteProcedure()
	end
end
