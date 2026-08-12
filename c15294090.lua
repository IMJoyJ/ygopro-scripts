--デステニー・ミラージュ
-- 效果：
-- 自己场上名字带有「命运英雄」的怪兽被对方的卡的效果破坏送去墓地时才能发动。把这个回合被破坏送去墓地的名字带有「命运英雄」的怪兽全部在自己场上特殊召唤。
function c15294090.initial_effect(c)
	-- 效果发动条件设置为：自己场上名字带有「命运英雄」的怪兽被对方的卡的效果破坏送去墓地时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c15294090.condition)
	e1:SetTarget(c15294090.target)
	e1:SetOperation(c15294090.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断怪兽是否在被破坏前是名字带有「命运英雄」且在自己场上正面表示的怪兽。
function c15294090.cfilter(c,tp)
	return c:IsPreviousSetCard(0xc008) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 条件函数，判断是否满足发动条件：破坏原因是效果且破坏者是对方，且存在满足cfilter条件的怪兽。
function c15294090.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and rp==1-tp and eg:IsExists(c15294090.cfilter,1,nil,tp)
end
-- 特殊召唤过滤函数，用于筛选满足条件的怪兽：被破坏、在本回合被破坏、名字带有「命运英雄」且可以被特殊召唤。
function c15294090.spfilter(c,e,tp)
	-- 筛选条件：被破坏且在本回合被破坏且名字带有「命运英雄」。
	return c:IsReason(REASON_DESTROY) and c:GetTurnID()==Duel.GetTurnCount() and c:IsSetCard(0xc008)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标设定函数，用于判断是否可以发动效果：满足条件的怪兽数量大于0且场上空位足够。
function c15294090.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足特殊召唤条件的怪兽组。
	local g=Duel.GetMatchingGroup(c15294090.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp)
	-- 检查是否满足发动条件：满足条件的怪兽数量大于0且场上空位足够。
	if chk==0 then return g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=g:GetCount() end
	-- 设置操作信息，将要特殊召唤的怪兽组和数量设定为处理对象。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 效果处理函数，执行特殊召唤操作：获取满足条件的怪兽组并进行特殊召唤。
function c15294090.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足特殊召唤条件的怪兽组。
	local g=Duel.GetMatchingGroup(c15294090.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp)
	-- 获取自己场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft<=0 or ft<g:GetCount() or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if g:GetCount()>0 then
		-- 将满足条件的怪兽组特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
