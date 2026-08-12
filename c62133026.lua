--花と野原の春化精
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把这张卡和1只怪兽或者和1张「春化精」卡从手卡丢弃才能发动。从自己墓地选「花与原野的春化精」以外的1只地属性怪兽加入手卡。那之后，可以从自己墓地选1只地属性怪兽特殊召唤。这个回合，自己不能把地属性以外的怪兽的效果发动。
-- ②：只要这张卡在怪兽区域存在，自己场上的「春化精」怪兽不会成为对方的效果的对象。
function c62133026.initial_effect(c)
	-- ①：把这张卡和1只怪兽或者和1张「春化精」卡从手卡丢弃才能发动。从自己墓地选「花与原野的春化精」以外的1只地属性怪兽加入手卡。那之后，可以从自己墓地选1只地属性怪兽特殊召唤。这个回合，自己不能把地属性以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,62133026)
	e1:SetCost(c62133026.thcost)
	e1:SetTarget(c62133026.thtg)
	e1:SetOperation(c62133026.thop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己场上的「春化精」怪兽不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c62133026.tgtg)
	-- 设置对象抗性过滤函数，使其不会成为对方的效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end
-- 过滤手卡中满足丢弃条件的怪兽卡或「春化精」卡
function c62133026.costfilter(c)
	return (c:IsType(TYPE_MONSTER) or c:IsSetCard(0x182)) and c:IsDiscardable()
end
-- 效果①的发动代价（丢弃自身和另一张手牌）
function c62133026.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家是否受到「春化精的花冠」效果的影响
	local fe=Duel.IsPlayerAffectedByEffect(tp,14108995)
	-- 检查手卡中是否存在除这张卡以外可作为代价丢弃的卡
	local b2=Duel.IsExistingMatchingCard(c62133026.costfilter,tp,LOCATION_HAND,0,1,c)
	if chk==0 then return c:IsDiscardable() and (fe or b2) end
	-- 若受到「春化精的花冠」影响，且没有其他可丢弃手牌或玩家选择适用其效果
	if fe and (not b2 or Duel.SelectYesNo(tp,aux.Stringid(14108995,0))) then  --"是否适用「春化精的花冠」的效果？"
		-- 展示「春化精的花冠」卡片以提示适用其效果
		Duel.Hint(HINT_CARD,0,14108995)
		fe:UseCountLimit(tp)
		-- 将这张卡作为发动代价丢弃送去墓地
		Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
	else
		-- 提示玩家选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 让玩家选择1张手卡中的怪兽或「春化精」卡
		local g=Duel.SelectMatchingCard(tp,c62133026.costfilter,tp,LOCATION_HAND,0,1,1,c)
		g:AddCard(c)
		-- 将选中的卡作为发动代价丢弃送去墓地
		Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	end
end
-- 过滤墓地中「花与原野的春化精」以外的地属性怪兽
function c62133026.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and not c:IsCode(62133026) and c:IsAbleToHand()
end
-- 效果①的发动准备与效果分类注册
function c62133026.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地中是否存在可以加入手牌的、除「花与原野的春化精」以外的地属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c62133026.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置在效果处理时将墓地的1张卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 过滤墓地中可以特殊召唤的地属性怪兽
function c62133026.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的效果处理（回收地属性怪兽，后续可特召地属性怪兽，并施加属性发动限制）
function c62133026.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从墓地选择1只满足条件的地属性怪兽（受王家之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c62133026.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	-- 若成功将选中的怪兽加入手牌
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 获取墓地中所有可以特殊召唤的地属性怪兽（受王家之谷影响）
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c62133026.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 若墓地存在可特召的怪兽且自身场上有空余的怪兽区域
		if sg:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 询问玩家是否选择从墓地特殊召唤怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(62133026,0)) then  --"是否从墓地特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤处理不与加入手牌同时进行（错时点）
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sc=sg:Select(tp,1,1,nil)
			-- 将选中的怪兽在自身场上表侧表示特殊召唤
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不能把地属性以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c62133026.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该回合内不能发动地属性以外怪兽效果的玩家限制
	Duel.RegisterEffect(e1,tp)
end
-- 限制玩家不能发动地属性以外的怪兽的效果
function c62133026.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsNonAttribute(ATTRIBUTE_EARTH)
end
-- 过滤自身场上表侧表示的「春化精」怪兽
function c62133026.tgtg(e,c)
	return c:IsSetCard(0x182) and c:IsFaceup()
end
