--王家の神殿
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己可以把1张陷阱卡在盖放的回合发动。
-- ②：把自己场上的表侧表示的1只「圣兽 塞勒凯特」和这张卡送去墓地才能发动。手卡·卡组1只怪兽或者额外卡组1只融合怪兽特殊召唤。
function c29762407.initial_effect(c)
	-- 登记本卡效果文本中提到的卡名「圣兽 塞勒凯特」，使本卡被视为记载有该卡名。
	aux.AddCodeList(c,89194033)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己可以把1张陷阱卡在盖放的回合发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29762407,1))  --"适用「王家的神殿」的效果来发动"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetCountLimit(1,29762407)
	c:RegisterEffect(e2)
	-- ②：把自己场上的表侧表示的1只「圣兽 塞勒凯特」和这张卡送去墓地才能发动。手卡·卡组1只怪兽或者额外卡组1只融合怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetDescription(aux.Stringid(29762407,0))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,29762408)
	e3:SetCost(c29762407.cost)
	e3:SetTarget(c29762407.target)
	e3:SetOperation(c29762407.operation)
	c:RegisterEffect(e3)
end
-- 定义选择「圣兽 塞勒凯特」作为代价的过滤条件：必须是表侧表示、卡号为89194033、可作为代价送墓，并且还要保证存在至少1只符合条件的可特殊召唤怪兽，以便代价有效。
function c29762407.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsCode(89194033) and c:IsAbleToGraveAsCost()
		-- 检查手卡·卡组·额外是否存在满足特殊召唤条件的怪兽，同时把被选中的塞勒凯特和本卡组成的Group作为tg传入，用于后续计算特殊召唤可用区域。
		and Duel.IsExistingMatchingCard(c29762407.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,Group.FromCards(c,e:GetHandler()))
end
-- cost函数：在代价检查阶段确认能否支付——本卡自身可作为代价送去墓地，且场上存在至少1只满足条件的「圣兽 塞勒凯特」。
function c29762407.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost()
		-- 检查自己怪兽区是否存在至少1只满足cfilter条件的「圣兽 塞勒凯特」作为追加代价。
		and Duel.IsExistingMatchingCard(c29762407.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向操作玩家显示提示信息，要求选择要送去墓地的卡片（作为代价）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让操作者从自己场上选择1张满足cfilter条件的「圣兽 塞勒凯特」作为代价（本卡神殿后续会自动加入）。
	local g=Duel.SelectMatchingCard(tp,c29762407.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	g:AddCard(e:GetHandler())
	-- 将选择的「圣兽 塞勒凯特」和这张「王家的神殿」作为代价一起送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义特殊召唤目标的过滤条件：目标可以是手卡·卡组的怪兽或额外卡组的融合怪兽；该怪兽能够被特殊召唤；且根据来源位置确认有足够的可用怪兽区/额外召唤区域。
function c29762407.filter(c,e,tp,tg)
	return (c:IsLocation(LOCATION_HAND+LOCATION_DECK) or c:IsType(TYPE_FUSION))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 对于手卡·卡组的怪兽，检查在考虑代价送墓后自己场上是否有可用的主怪兽区空格。
		and (c:IsLocation(LOCATION_HAND+LOCATION_DECK) and Duel.GetMZoneCount(tp,tg)>0
			-- 对于额外卡组的融合怪兽，检查在考虑代价送墓后自己场上是否有可用的额外怪兽特殊召唤区域。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,tg,c)>0)
end
-- target函数：该效果不取对象，允许发动，并登记本次操作将进行特殊召唤。
function c29762407.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：效果处理时从手卡·卡组·额外卡组中特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)
end
-- operation函数：效果处理时从手卡·卡组·额外选择1只符合条件的怪兽特殊召唤，成功则表侧表示特殊召唤。
function c29762407.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示提示信息，要求选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让操作者从手卡·卡组·额外卡组中选择1张满足filter条件的怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c29762407.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到操作者自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
