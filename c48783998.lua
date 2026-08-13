--コーリング・ノヴァ
-- 效果：
-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只攻击力1500以下的天使族·光属性怪兽特殊召唤。场上有「天空的圣域」存在的场合，可以作为代替把1只「天空骑士 珀耳修斯」特殊召唤。
function c48783998.initial_effect(c)
	-- 将卡号56433456（「天空的圣域」）登记到本卡的代码列表中，表示本卡效果文本记载了该卡名，用于关联判定。
	aux.AddCodeList(c,56433456)
	-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只攻击力1500以下的天使族·光属性怪兽特殊召唤。场上有「天空的圣域」存在的场合，可以作为代替把1只「天空骑士 珀耳修斯」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48783998,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c48783998.condition)
	e1:SetTarget(c48783998.target)
	e1:SetOperation(c48783998.operation)
	c:RegisterEffect(e1)
end
-- 发动条件判定：效果持有者必须位于墓地，且是被战斗破坏送入墓地，满足“这张卡被战斗破坏送去墓地时”的触发条件。
function c48783998.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 检索过滤1：选择卡组中攻击力1500以下、光属性、天使族，且能被当前效果特殊召唤的怪兽。
function c48783998.filter1(c,e,tp)
	return c:IsAttackBelow(1500) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检索过滤2：选择卡组中卡号为18036057（「天空骑士 珀耳修斯」）的怪兽，或者攻击力1500以下、光属性、天使族的怪兽，且均能被当前效果特殊召唤。
function c48783998.filter2(c,e,tp)
	return (c:IsCode(18036057) or (c:IsAttackBelow(1500) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY)))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时目标判定：先确认我方主要怪兽区有空位；再根据场上是否存在「天空的圣域」决定可检索范围（无圣域时仅普通天使族，有圣域时额外允许「天空骑士 珀耳修斯」）；最后设置本次效果将为特殊召唤的操作信息。
function c48783998.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查我方主要怪兽区是否有空位，若没有空位则不能发动此效果。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		-- 判断当前场上是否存在场地魔法「天空的圣域」；若不存在则走普通天使族检索分支。
		if not Duel.IsEnvironment(56433456) then
			-- 检查卡组中是否存在至少1只满足filter1条件的怪兽（攻击力1500以下、光属性、天使族且可特殊召唤），存在则满足发动条件。
			return Duel.IsExistingMatchingCard(c48783998.filter1,tp,LOCATION_DECK,0,1,nil,e,tp)
		else
			-- 检查卡组中是否存在至少1只满足filter2条件的怪兽（「天空骑士 珀耳修斯」或符合条件的普通天使族），存在则满足发动条件。
			return Duel.IsExistingMatchingCard(c48783998.filter2,tp,LOCATION_DECK,0,1,nil,e,tp)
		end
	end
	-- 设置操作信息：本次效果处理类别为特殊召唤，从卡组特殊召唤1只怪兽（具体卡牌在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时：再次确认主要怪兽区有空位，提示玩家选择要特殊召唤的卡；根据场上是否存在「天空的圣域」选择对应的检索过滤函数；将选中的怪兽以表侧表示特殊召唤到己方场上。
function c48783998.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查我方主要怪兽区是否有空位，若无空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=nil
	-- 向玩家显示选择提示“请选择要特殊召唤的卡”，并将该提示写入选择消息缓存，供后续选择卡牌时显示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果处理时再次判断场上是否存在「天空的圣域」，以此决定使用filter1还是filter2进行检索。
	if not Duel.IsEnvironment(56433456) then
		-- 场上没有「天空的圣域」时，从卡组选择1只满足filter1条件的怪兽。
		g=Duel.SelectMatchingCard(tp,c48783998.filter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	else
		-- 场上有「天空的圣域」时，从卡组选择1只满足filter2条件的怪兽（可以是「天空骑士 珀耳修斯」）。
		g=Duel.SelectMatchingCard(tp,c48783998.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	end
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到己方怪兽区，完成特殊召唤处理。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
