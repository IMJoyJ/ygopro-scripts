--煉獄の契約
-- 效果：
-- ①：这张卡以外的自己手卡是3张以上的场合才能发动。自己手卡全部丢弃。那之后，可以从自己墓地选1只「永火」怪兽或者龙族·暗属性·8星的同调怪兽特殊召唤。
function c19828680.initial_effect(c)
	-- 效果定义：发动条件、目标设置与效果处理流程
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c19828680.condition)
	e1:SetTarget(c19828680.target)
	e1:SetOperation(c19828680.activate)
	c:RegisterEffect(e1)
end
-- 效果原文：这张卡以外的自己手卡是3张以上的场合才能发动
function c19828680.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断自己手牌数量是否不少于3张
	return Duel.GetMatchingGroupCount(nil,tp,LOCATION_HAND,0,e:GetHandler())>=3
end
-- 效果原文：自己手卡全部丢弃
function c19828680.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local exc=nil
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():IsLocation(LOCATION_HAND) then exc=e:GetHandler() end
	-- 规则层面：获取自己手牌组
	local sg=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,exc)
	if chk==0 then return sg:GetCount()>0 end
	-- 规则层面：设置操作信息为丢弃手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,sg,sg:GetCount(),0,0)
end
-- 效果原文：从自己墓地选1只「永火」怪兽或者龙族·暗属性·8星的同调怪兽特殊召唤
function c19828680.spfilter(c,e,tp)
	return (c:IsSetCard(0xb) or c:IsType(TYPE_SYNCHRO) and c:IsLevel(8) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面：处理效果发动后的连锁流程
function c19828680.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取自己手牌组
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 规则层面：将手牌全部送去墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)~=0
		-- 规则层面：判断场上是否有可用怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面：检查墓地是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c19828680.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 规则层面：询问玩家是否进行特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(19828680,0)) then  --"是否特殊召唤？"
		-- 规则层面：中断当前效果处理
		Duel.BreakEffect()
		-- 规则层面：提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 规则层面：选择符合条件的墓地怪兽
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c19828680.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 规则层面：将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
