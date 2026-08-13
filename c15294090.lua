--デステニー・ミラージュ
-- 效果：
-- 自己场上名字带有「命运英雄」的怪兽被对方的卡的效果破坏送去墓地时才能发动。把这个回合被破坏送去墓地的名字带有「命运英雄」的怪兽全部在自己场上特殊召唤。
function c15294090.initial_effect(c)
	-- 自己场上名字带有「命运英雄」的怪兽被对方的卡的效果破坏送去墓地时才能发动。把这个回合被破坏送去墓地的名字带有「命运英雄」的怪兽全部在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c15294090.condition)
	e1:SetTarget(c15294090.target)
	e1:SetOperation(c15294090.operation)
	c:RegisterEffect(e1)
end
-- 设定诱发条件的筛选函数：判断送入墓地的怪兽之前是否满足「自己场上表侧表示的名字带有『命运英雄』的怪兽，且原控制者是发动者」，即是否为我方被对方效果破坏的场上表侧表示命运英雄怪兽。
function c15294090.cfilter(c,tp)
	return c:IsPreviousSetCard(0xc008) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 发动条件判定：此次送去墓地的原因必须包含效果破坏，且破坏者是对方玩家，并且存在至少1只满足条件的我方命运英雄怪兽被送去墓地。
function c15294090.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and rp==1-tp and eg:IsExists(c15294090.cfilter,1,nil,tp)
end
-- 设定特殊召唤对象的筛选函数：选择墓地中满足「本回合被破坏送去墓地、卡名带有『命运英雄』、可以被当前效果特殊召唤」的怪兽。
function c15294090.spfilter(c,e,tp)
	-- 筛选条件的一部分：该怪兽必须是被破坏送去墓地的，且进入墓地的回合是当前回合。
	return c:IsReason(REASON_DESTROY) and c:GetTurnID()==Duel.GetTurnCount() and c:IsSetCard(0xc008)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的目标选择与合法性确认：检索墓地所有符合条件的命运英雄怪兽，若存在且我方主要怪兽区空格足够，则返回可发动，并设置特殊召唤的操作信息。
function c15294090.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方墓地中所有满足特殊召唤筛选条件的命运英雄怪兽，作为可能被特殊召唤的群体。
	local g=Duel.GetMatchingGroup(c15294090.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp)
	-- 发动时点检查：若墓地存在符合条件的怪兽，且我方主要怪兽区可用空格数不少于这些怪兽的数量，则允许发动。
	if chk==0 then return g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=g:GetCount() end
	-- 将本次效果的特殊召唤信息登记到连锁中，表示之后会进行特殊召唤（目标数量为g:GetCount()），供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 效果处理时执行特殊召唤：重新获取墓地符合条件的命运英雄怪兽，再次确认可用区域数量；若因场地空格不足或青眼精灵龙等限制不能同时特殊召唤2只以上怪兽，则不处理；否则全部以表侧表示特殊召唤到我方场上。
function c15294090.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取所有符合条件的命运英雄怪兽，确保实际特殊召唤的是处理时仍满足条件的怪兽。
	local g=Duel.GetMatchingGroup(c15294090.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp)
	-- 获取我方主要怪兽区当前可用的空格数，用于判断能否全部特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft<=0 or ft<g:GetCount() or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if g:GetCount()>0 then
		-- 将符合条件的全部命运英雄怪兽以表侧攻击表示特殊召唤到我方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
