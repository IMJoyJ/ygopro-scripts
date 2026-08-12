--Emヒグルミ
-- 效果：
-- ←5 【灵摆】 5→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己场上的表侧表示的「娱乐法师」怪兽被战斗·效果破坏的场合才能发动。这张卡特殊召唤。那之后，自己受到500伤害。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：场上的这张卡被战斗·效果破坏的场合才能发动。从手卡·卡组把「娱乐法师 火布偶」以外的1只「娱乐法师」怪兽特殊召唤。
function c7563579.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（包括灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上的表侧表示的「娱乐法师」怪兽被战斗·效果破坏的场合才能发动。这张卡特殊召唤。那之后，自己受到500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,7563579)
	e2:SetCondition(c7563579.spcon1)
	e2:SetTarget(c7563579.sptg1)
	e2:SetOperation(c7563579.spop1)
	c:RegisterEffect(e2)
	-- ①：场上的这张卡被战斗·效果破坏的场合才能发动。从手卡·卡组把「娱乐法师 火布偶」以外的1只「娱乐法师」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,7563580)
	e3:SetCondition(c7563579.spcon2)
	e3:SetTarget(c7563579.sptg2)
	e3:SetOperation(c7563579.spop2)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「娱乐法师」怪兽因战斗或效果被破坏
function c7563579.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsSetCard(0xc6)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
end
-- 灵摆效果发动条件：检查被破坏的卡中是否存在满足过滤条件的卡
function c7563579.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c7563579.cfilter,1,nil,tp)
end
-- 灵摆效果靶向/发动准备：检查自身能否特殊召唤，并设置特殊召唤和伤害的操作信息
function c7563579.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示准备将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置伤害的操作信息，表示准备给与玩家500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,500)
end
-- 灵摆效果处理：将自身特殊召唤，之后给与自己500点伤害
function c7563579.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将自身以表侧表示特殊召唤，并检查是否特殊召唤成功
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 中断当前效果处理，使后续的伤害处理与特殊召唤不视为同时进行（造成错时点）
		Duel.BreakEffect()
		-- 给与自己500点效果伤害
		Duel.Damage(tp,500,REASON_EFFECT)
	end
end
-- 怪兽效果发动条件：检查自身是否在场上被战斗或效果破坏
function c7563579.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：手卡或卡组中「娱乐法师 火布偶」以外的、可以特殊召唤的「娱乐法师」怪兽
function c7563579.spfilter(c,e,tp)
	return c:IsSetCard(0xc6) and not c:IsCode(7563579) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 怪兽效果靶向/发动准备：检查是否有可用怪兽区域以及手卡或卡组中是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息
function c7563579.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否存在至少1张满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c7563579.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示准备从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 怪兽效果处理：从手卡或卡组选择1只「娱乐法师 火布偶」以外的「娱乐法师」怪兽特殊召唤
function c7563579.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否没有可用的怪兽区域空格，若无则直接结束效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组中选择1张满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c7563579.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
