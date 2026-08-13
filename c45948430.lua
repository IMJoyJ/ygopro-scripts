--超戦士の萌芽
-- 效果：
-- 「混沌战士」仪式怪兽的降临必需。「超战士的萌芽」在1回合只能发动1张。
-- ①：等级合计直到8的以下其中1个组合的怪兽送去墓地，从自己的手卡·墓地把1只「混沌战士」仪式怪兽仪式召唤。
-- ●手卡1只光属性怪兽和卡组1只暗属性怪兽
-- ●手卡1只暗属性怪兽和卡组1只光属性怪兽
function c45948430.initial_effect(c)
	-- 「混沌战士」仪式怪兽的降临必需。「超战士的萌芽」在1回合只能发动1张。①：等级合计直到8的以下其中1个组合的怪兽送去墓地，从自己的手卡·墓地把1只「混沌战士」仪式怪兽仪式召唤。●手卡1只光属性怪兽和卡组1只暗属性怪兽●手卡1只暗属性怪兽和卡组1只光属性怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,45948430+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c45948430.target)
	e1:SetOperation(c45948430.activate)
	c:RegisterEffect(e1)
end
-- 筛选可作为仪式召唤对象的「混沌战士」仪式怪兽：要求是编号0x10cf的仪式怪兽（类型为怪兽+仪式），且能够以仪式召唤方式被特殊召唤（不检查苏生限制）。
function c45948430.filter(c,e,tp)
	if not c:IsSetCard(0x10cf) or bit.band(c:GetType(),0x81)~=0x81
		or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	-- 确认手卡中存在至少1张满足matfilter1条件的素材候选，从而保证该仪式怪兽能够通过组合素材进行仪式召唤。
	return Duel.IsExistingMatchingCard(c45948430.matfilter1,tp,LOCATION_HAND,0,1,c,tp,c)
end
-- 手卡素材的筛选条件：等级7以下、光属性或暗属性、可以送去墓地、可以作为仪式素材，并且卡组中存在与之属性相反且等级合计为8的另一张素材。
function c45948430.matfilter1(c,tp,rc)
	return c:IsLevelBelow(7) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToGrave() and c:IsCanBeRitualMaterial(rc)
		-- 确认卡组中存在与手卡素材属性相反、等级合计为8的怪兽，可作为本次仪式召唤的另一半素材。
		and Duel.IsExistingMatchingCard(c45948430.matfilter2,tp,LOCATION_DECK,0,1,c,c:GetLevel(),c:GetAttribute(),rc)
end
-- 卡组素材的筛选条件：属性与手卡素材相反（手卡光则卡组暗，手卡暗则卡组光），等级恰好为8减去手卡素材的等级，且可以送去墓地、可以作为仪式素材。
function c45948430.matfilter2(c,lv,att,rc)
	return ((c:IsAttribute(ATTRIBUTE_LIGHT) and att==ATTRIBUTE_DARK) or (c:IsAttribute(ATTRIBUTE_DARK) and att==ATTRIBUTE_LIGHT))
		and c:IsLevel(8-lv) and c:IsAbleToGrave() and c:IsCanBeRitualMaterial(rc)
end
-- 效果发动时的合法性与操作信息处理：检查自己场上是否有可用怪兽区域以及手卡·墓地是否存在可仪式召唤的「混沌战士」仪式怪兽；随后登记本次特殊召唤的操作信息。
function c45948430.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 发动条件之一：自己的主要怪兽区域存在空位，用于放置仪式召唤出来的怪兽。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 发动条件之一：手卡·墓地中至少存在1只满足filter条件的「混沌战士」仪式怪兽，可作为本次仪式召唤的对象。
			and Duel.IsExistingMatchingCard(c45948430.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	-- 设置操作信息，宣告本次效果可能从手卡·墓地特殊召唤1只怪兽，供后续连锁检测或卡片响应使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 定义素材组校验函数：判断所选的2张素材是否属性互不相同、所在位置互不相同（一张手卡一张卡组）、等级合计为8。
function c45948430.check(g)
	-- 返回素材组的综合校验结果：属性不同（通过dabcheck）、位置种类数等于卡数（确保一张手卡一张卡组）、等级合计为8。
	return aux.dabcheck(g) and g:GetClassCount(Card.GetLocation)==#g and g:GetSum(Card.GetLevel)==8
end
-- 素材单卡过滤器：从手卡·卡组中筛选可作为仪式素材的怪兽，条件为等级7以下、光/暗属性、可以送去墓地、可以作为仪式素材。
function c45948430.mfilter(c,rc)
	return c:IsLevelBelow(7) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToGrave() and c:IsCanBeRitualMaterial(rc)
end
-- 效果处理流程：先确认有怪兽区域，再选择要仪式召唤的「混沌战士」仪式怪兽，从手卡·卡组选择2张符合组合条件的素材送去墓地，最后以仪式召唤方式特殊召唤该怪兽。
function c45948430.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查自己场上是否有可用怪兽区域，若没有则本次效果不继续处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	::cancel::
	-- 向玩家显示选择提示“请选择要特殊召唤的卡”，引导选择仪式召唤对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡·墓地中选择1只满足filter且不受王家长眠之谷影响的「混沌战士」仪式怪兽作为本次仪式召唤的对象。
	local rg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c45948430.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local rc=rg:GetFirst()
	if rc then
		-- 从手卡·卡组中获取所有可能作为仪式素材的怪兽，构成素材候选集合供玩家选择。
		local mg=Duel.GetMatchingGroup(c45948430.mfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,rc)
		-- 向玩家显示选择提示“请选择要送去墓地的卡”，引导选择仪式素材。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local mat=mg:SelectSubGroup(tp,c45948430.check,true,2,2)
		if not mat then goto cancel end
		rc:SetMaterial(mat)
		-- 将选定的2张素材怪兽送去墓地，送墓原因包含效果、仪式素材和仪式召唤。
		Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		-- 中断当前效果处理，使送墓和特殊召唤分属不同时点，避免错过仪式召唤成功的时点。
		Duel.BreakEffect()
		-- 将选择的仪式怪兽以表侧表示特殊召唤到自己的主要怪兽区，召唤类型为仪式召唤，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		rc:CompleteProcedure()
	end
end
