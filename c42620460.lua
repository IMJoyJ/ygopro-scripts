--クロノダイバー・パワーリザーブ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡发动后变成通常怪兽（念动力族·暗·4星·攻1900/守2500）在怪兽区域特殊召唤（也当作陷阱卡使用）。那之后，可以从自己的手卡·卡组·墓地把1只机械族「时间潜行者」怪兽特殊召唤。
-- ②：有魔法卡和陷阱卡在作为超量素材中的超量怪兽在自己场上存在的场合，把墓地的这张卡除外才能发动。场上1张卡除外。
local s,id,o=GetID()
-- 注册两个效果：①发动后变成通常怪兽特殊召唤并可能再特殊召唤一只时间潜行者怪兽；②墓地发动，除外场上一张卡。
function s.initial_effect(c)
	-- ①：这张卡发动后变成通常怪兽（念动力族·暗·4星·攻1900/守2500）在怪兽区域特殊召唤（也当作陷阱卡使用）。那之后，可以从自己的手卡·卡组·墓地把1只机械族「时间潜行者」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"变成通常怪兽特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：有魔法卡和陷阱卡在作为超量素材中的超量怪兽在自己场上存在的场合，把墓地的这张卡除外才能发动。场上1张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"场上1张卡除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.rmcon)
	-- 效果②的发动需要将此卡除外作为费用。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件检查：确认是否已支付费用，且自己场上存在空位，且可以特殊召唤此卡为通常怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己是否可以特殊召唤此卡为通常怪兽（念动力族·暗·4星·攻1900/守2500）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x126,TYPES_NORMAL_TRAP_MONSTER,1900,2500,4,RACE_PSYCHO,ATTRIBUTE_DARK) end
	-- 设置效果①的处理信息：将此卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义过滤函数：筛选机械族且为时间潜行者系列的怪兽，且可以被特殊召唤。
function s.filter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsSetCard(0x126) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的处理函数：将此卡变为通常怪兽并特殊召唤，然后询问是否再特殊召唤一只时间潜行者怪兽。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否可以特殊召唤此卡为通常怪兽。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x126,TYPES_NORMAL_TRAP_MONSTER,1900,2500,4,RACE_PSYCHO,ATTRIBUTE_DARK) then return end
	local c=e:GetHandler()
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP)
	-- 将此卡特殊召唤到场上。
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)==0 then return end
	-- 获取满足条件的时间潜行者怪兽组（包括手牌、卡组、墓地）。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,nil,e,tp)
	-- 检查是否还有空位、是否有满足条件的怪兽、玩家是否选择再特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否再把怪兽特殊召唤？"
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 中断当前效果处理，使后续处理视为不同时处理。
		Duel.BreakEffect()
		-- 将玩家选择的怪兽特殊召唤。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义过滤函数：筛选场上正面表示的超量怪兽，其超量素材包含魔法和陷阱卡。
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		and c:GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_SPELL)
		and c:GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_TRAP)
end
-- 效果②的发动条件：场上存在满足条件的超量怪兽。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在满足条件的超量怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果②的处理函数：选择场上一张卡除外。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上所有可以除外的卡组。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	-- 设置效果②的处理信息：将一张卡除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果②的处理函数：选择并除外一张卡。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上一张可以除外的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		-- 显示被选为对象的卡的动画效果。
		Duel.HintSelection(g)
		-- 将选中的卡除外。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
