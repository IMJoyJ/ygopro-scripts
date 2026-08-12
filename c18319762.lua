--氷結界の照魔師
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要自己场上有其他的「冰结界」怪兽存在，对方不能上级召唤。
-- ②：丢弃1张手卡才能发动。从卡组把1只「冰结界」调整特殊召唤。这个效果的发动后，直到回合结束时自己不是水属性怪兽不能特殊召唤。
-- ③：自己为让「冰结界」怪兽的效果发动而把手卡送去墓地的场合或者丢弃的场合，可以作为那1张卡的代替而把墓地的这张卡除外。
function c18319762.initial_effect(c)
	-- ①：只要自己场上有其他的「冰结界」怪兽存在，对方不能上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCondition(c18319762.sumcon)
	e1:SetTarget(c18319762.sumlimit)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e2)
	-- ②：丢弃1张手卡才能发动。从卡组把1只「冰结界」调整特殊召唤。这个效果的发动后，直到回合结束时自己不是水属性怪兽不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(18319762,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,18319762)
	e3:SetCost(c18319762.spcost)
	e3:SetTarget(c18319762.sptg)
	e3:SetOperation(c18319762.spop)
	c:RegisterEffect(e3)
	-- ③：自己为让「冰结界」怪兽的效果发动而把手卡送去墓地的场合或者丢弃的场合，可以作为那1张卡的代替而把墓地的这张卡除外。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(18319762)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,18319763)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断场上是否存在其他「冰结界」怪兽
function c18319762.sumfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
-- 条件函数，判断是否满足①效果的发动条件
function c18319762.sumcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查场上是否存在其他「冰结界」怪兽
	return Duel.IsExistingMatchingCard(c18319762.sumfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 限制函数，用于判断是否为上级召唤
function c18319762.sumlimit(e,c,tp,sumtp)
	return bit.band(sumtp,SUMMON_TYPE_ADVANCE)==SUMMON_TYPE_ADVANCE
end
-- 过滤函数，用于判断是否满足②效果的发动代价
function c18319762.costfilter(c,e,tp)
	if c:IsLocation(LOCATION_HAND) then
		return c:IsDiscardable()
	else
		return e:GetHandler():IsSetCard(0x2f) and c:IsAbleToRemove() and c:IsHasEffect(18319762,tp)
	end
end
-- 处理②效果的发动代价，选择并处理丢弃的卡
function c18319762.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足②效果的发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(c18319762.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择满足条件的1张手牌或墓地卡作为丢弃对象
	local g=Duel.SelectMatchingCard(tp,c18319762.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local te=tc:IsHasEffect(18319762,tp)
	if te then
		te:UseCountLimit(tp)
		-- 将选中的卡以代替效果的方式除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
	else
		-- 将选中的卡送去墓地作为发动代价
		Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
	end
end
-- 过滤函数，用于筛选可以特殊召唤的「冰结界」调整
function c18319762.spfilter(c,e,tp)
	return c:IsSetCard(0x2f) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理②效果的发动条件，检查是否有满足条件的卡可以特殊召唤
function c18319762.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的「冰结界」调整
		and Duel.IsExistingMatchingCard(c18319762.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤1只「冰结界」调整
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理②效果的发动效果，选择并特殊召唤1只「冰结界」调整
function c18319762.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位可以特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的1只「冰结界」调整
		local g=Duel.SelectMatchingCard(tp,c18319762.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的卡特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- ②效果发动后，直到回合结束时自己不是水属性怪兽不能特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c18319762.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果，使自己不能特殊召唤非水属性怪兽
	Duel.RegisterEffect(e1,tp)
end
-- 限制函数，用于判断是否为水属性怪兽
function c18319762.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
