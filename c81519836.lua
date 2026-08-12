--苗と霞の春化精
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把这张卡和1只怪兽或和1张「春化精」卡从手卡丢弃才能发动。从卡组把「苗与霞的春化精」以外的1只天使族·地属性怪兽加入手卡。那之后，可以从自己墓地把1只地属性怪兽特殊召唤。这个回合，自己不能把地属性以外的怪兽的效果发动。
-- ②：只要这张卡在怪兽区域存在，「春化精」怪兽以外的场上的怪兽的攻击力下降600。
function c81519836.initial_effect(c)
	-- ①：把这张卡和1只怪兽或和1张「春化精」卡从手卡丢弃才能发动。从卡组把「苗与霞的春化精」以外的1只天使族·地属性怪兽加入手卡。那之后，可以从自己墓地把1只地属性怪兽特殊召唤。这个回合，自己不能把地属性以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,81519836)
	e1:SetCost(c81519836.thcost)
	e1:SetTarget(c81519836.thtg)
	e1:SetOperation(c81519836.thop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，「春化精」怪兽以外的场上的怪兽的攻击力下降600。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c81519836.atktg)
	e2:SetValue(-600)
	c:RegisterEffect(e2)
end
-- 过滤手牌中可作为发动代价丢弃的怪兽或「春化精」卡
function c81519836.costfilter(c)
	return (c:IsType(TYPE_MONSTER) or c:IsSetCard(0x182)) and c:IsDiscardable()
end
-- ①的效果的发动代价处理
function c81519836.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己是否受到「春化精的花冠」效果的影响
	local fe=Duel.IsPlayerAffectedByEffect(tp,14108995)
	-- 检查手牌中是否存在除这张卡以外的怪兽或「春化精」卡
	local b2=Duel.IsExistingMatchingCard(c81519836.costfilter,tp,LOCATION_HAND,0,1,c)
	if chk==0 then return c:IsDiscardable() and (fe or b2) end
	-- 若适用「春化精的花冠」的效果，则可以仅丢弃这张卡作为发动代价
	if fe and (not b2 or Duel.SelectYesNo(tp,aux.Stringid(14108995,0))) then  --"是否适用「春化精的花冠」的效果？"
		-- 在场上展示「春化精的花冠」以提示其效果适用
		Duel.Hint(HINT_CARD,0,14108995)
		fe:UseCountLimit(tp)
		-- 将这张卡作为发动代价丢弃送去墓地
		Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
	else
		-- 设置选择提示：请选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 选择手牌中除这张卡以外的1只怪兽或1张「春化精」卡
		local g=Duel.SelectMatchingCard(tp,c81519836.costfilter,tp,LOCATION_HAND,0,1,1,c)
		g:AddCard(c)
		-- 将选中的卡作为发动代价丢弃送去墓地
		Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	end
end
-- 过滤卡组中「苗与霞的春化精」以外的天使族·地属性怪兽
function c81519836.thfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToHand() and not c:IsCode(81519836)
end
-- ①的效果的发动检测与效果分类注册
function c81519836.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在满足检索条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c81519836.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，该效果包含从卡组将1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤墓地中可以特殊召唤的地属性怪兽
function c81519836.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①的效果的实际效果处理
function c81519836.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择提示：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c81519836.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 若成功将选中的怪兽加入手牌
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 获取自己墓地中不受「王家长眠之谷」影响且可特殊召唤的地属性怪兽
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c81519836.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 若墓地存在可特殊召唤的怪兽且自己场上有空余的怪兽区域
		if sg:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 询问玩家是否选择从墓地特殊召唤怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(81519836,0)) then  --"是否从墓地特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤处理与加入手牌不视为同时进行
			Duel.BreakEffect()
			-- 设置选择提示：请选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sc=sg:Select(tp,1,1,nil)
			-- 将选中的怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不能把地属性以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c81519836.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册该回合内不能发动地属性以外怪兽效果的限制
	Duel.RegisterEffect(e1,tp)
end
-- 限制发动效果的怪兽必须是地属性（不能发动地属性以外的怪兽的效果）
function c81519836.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsNonAttribute(ATTRIBUTE_EARTH)
end
-- 过滤场上「春化精」怪兽以外的怪兽
function c81519836.atktg(e,c)
	return not c:IsSetCard(0x182)
end
