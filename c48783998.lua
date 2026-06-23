--コーリング・ノヴァ
-- 效果：
-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只攻击力1500以下的天使族·光属性怪兽特殊召唤。场上有「天空的圣域」存在的场合，可以作为代替把1只「天空骑士 珀耳修斯」特殊召唤。
function c48783998.initial_effect(c)
	-- 记录此卡具有「天空的圣域」这张卡的卡片密码
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
-- 效果发动条件：此卡在墓地且因战斗破坏而离场
function c48783998.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤函数：选择攻击力不超过1500、光属性、天使族且可特殊召唤的怪兽
function c48783998.filter1(c,e,tp)
	return c:IsAttackBelow(1500) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数：选择「天空骑士 珀耳修斯」或攻击力不超过1500、光属性、天使族且可特殊召唤的怪兽
function c48783998.filter2(c,e,tp)
	return (c:IsCode(18036057) or (c:IsAttackBelow(1500) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY)))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标设定：检查是否满足特殊召唤条件，若满足则设置操作信息为特殊召唤
function c48783998.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 判断场上是否有足够召唤区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		-- 判断场上有无「天空的圣域」
		if not Duel.IsEnvironment(56433456) then
			-- 检查卡组中是否存在满足filter1条件的怪兽
			return Duel.IsExistingMatchingCard(c48783998.filter1,tp,LOCATION_DECK,0,1,nil,e,tp)
		else
			-- 检查卡组中是否存在满足filter2条件的怪兽
			return Duel.IsExistingMatchingCard(c48783998.filter2,tp,LOCATION_DECK,0,1,nil,e,tp)
		end
	end
	-- 设置连锁操作信息为特殊召唤类别
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：执行特殊召唤操作
function c48783998.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 再次判断场上是否有足够召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=nil
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 判断场上有无「天空的圣域」
	if not Duel.IsEnvironment(56433456) then
		-- 从卡组中选择满足filter1条件的怪兽
		g=Duel.SelectMatchingCard(tp,c48783998.filter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	else
		-- 从卡组中选择满足filter2条件的怪兽
		g=Duel.SelectMatchingCard(tp,c48783998.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	end
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
