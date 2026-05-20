--アイス・ドール・ミラー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·场上（表侧表示）把1只水属性怪兽送去墓地才能发动。选自己场上1只水属性怪兽，那1只同名怪兽从手卡·卡组特殊召唤。这张卡的发动后，直到回合结束时自己不是水属性怪兽不能特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从自己的卡组·墓地把1只「冰偶」加入手卡。
local s,id,o=GetID()
-- 初始化效果注册，包含①效果（发动时送墓水属性怪兽，特召场上同名怪兽）和②效果（墓地除外检索/回收「冰偶」）。
function s.initial_effect(c)
	-- 注册卡片记有「冰偶」（卡号97476032）的卡名信息。
	aux.AddCodeList(c,97476032)
	-- ①：从自己的手卡·场上（表侧表示）把1只水属性怪兽送去墓地才能发动。选自己场上1只水属性怪兽，那1只同名怪兽从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从自己的卡组·墓地把1只「冰偶」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置发动代价为把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤作为发动代价送去墓地的水属性怪兽（需满足：在手卡或场上表侧表示、能送去墓地、送墓后能腾出怪兽区域、且场上存在可选择的另一只水属性怪兽）。
function s.tgfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToGraveAsCost()
		-- 检查该卡送去墓地后，自己场上是否有可用于特殊召唤的怪兽区域。
		and Duel.GetMZoneCount(tp,c)>0
		-- 检查自己场上是否存在除该送墓卡以外的、可作为特召同名卡参照的水属性怪兽。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,c,e,tp,c)
end
-- ①效果的发动代价处理（从手卡·场上表侧表示将1只水属性怪兽送去墓地）。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付将1只水属性怪兽送去墓地的代价。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1只满足条件的水属性怪兽。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选中的怪兽作为代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤自己场上表侧表示的水属性怪兽，且手卡·卡组中存在其同名怪兽。
function s.cfilter(c,e,tp,cc)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
		-- 检查手卡·卡组中是否存在与该怪兽同名的、可特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,cc,e,tp,c:GetCode())
end
-- 过滤手卡·卡组中与指定卡名相同且能特殊召唤的怪兽。
function s.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备与特殊召唤操作信息注册。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可作为特召参照的水属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,nil) end
	-- 设置特殊召唤的操作信息（从手卡·卡组特殊召唤1只怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ①效果的处理（选择场上1只水属性怪兽，将其同名怪兽从手卡·卡组特殊召唤，并施加水属性特召限制）。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择作为参照的目标怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 玩家选择自己场上1只表侧表示的水属性怪兽。
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,nil)
		local tc=g:GetFirst()
		if tc then
			-- 选中该怪兽并显示选择动画。
			Duel.HintSelection(g)
			-- 提示玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 玩家从手卡·卡组选择1只与参照怪兽同名的怪兽。
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,tc:GetCode())
			-- 将选中的同名怪兽以表侧表示特殊召唤。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不是水属性怪兽不能特殊召唤。/ ②：把墓地的这张卡除外才能发动。从自己的卡组·墓地把1只「冰偶」加入手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册非水属性怪兽特殊召唤限制的玩家效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制只能特殊召唤水属性怪兽。
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
-- 过滤卡组·墓地中的「冰偶」（卡号97476032）并检查是否能加入手卡。
function s.thfilter(c)
	return c:IsCode(97476032) and c:IsAbleToHand()
end
-- ②效果的发动准备与检索/回收操作信息注册。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组·墓地中是否存在「冰偶」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置加入手卡的操作信息（从卡组·墓地将1张卡加入手卡）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果的处理（从卡组·墓地将1只「冰偶」加入手卡）。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组·墓地选择1只「冰偶」（受王家之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
