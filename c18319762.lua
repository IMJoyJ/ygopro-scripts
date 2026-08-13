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
-- 过滤函数：判断怪兽是否为表侧表示且属于「冰结界」字段。
function c18319762.sumfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
-- ①效果的满足条件：自己场上有其他「冰结界」怪兽存在时，效果适用。
function c18319762.sumcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己怪兽区是否存在1张除自身以外、满足sumfilter（表侧表示「冰结界」）的怪兽。
	return Duel.IsExistingMatchingCard(c18319762.sumfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 限制对方上级召唤：当召唤类型为上级召唤时返回true，禁止该召唤。
function c18319762.sumlimit(e,c,tp,sumtp)
	return bit.band(sumtp,SUMMON_TYPE_ADVANCE)==SUMMON_TYPE_ADVANCE
end
-- 代价过滤：手牌中的卡可被丢弃；墓地中带有③效果的「冰结界」怪兽（这张卡）可被除外作为代替代价。
function c18319762.costfilter(c,e,tp)
	if c:IsLocation(LOCATION_HAND) then
		return c:IsDiscardable()
	else
		return e:GetHandler():IsSetCard(0x2f) and c:IsAbleToRemove() and c:IsHasEffect(18319762,tp)
	end
end
-- ②效果的发动代价：丢弃1张手卡；若选择墓地中的这张卡则将其除外代替丢弃，同时适用③的代替效果。
function c18319762.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost合法性检查：确认手牌或墓地中存在可作为代价的卡（手牌可丢弃，墓地中的这张卡可除外代替）。
	if chk==0 then return Duel.IsExistingMatchingCard(c18319762.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 显示选择提示：请选择要丢弃的手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 从手牌或墓地选择1张满足costfilter的卡作为代价。
	local g=Duel.SelectMatchingCard(tp,c18319762.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local te=tc:IsHasEffect(18319762,tp)
	if te then
		te:UseCountLimit(tp)
		-- 将选择的墓地卡片除外，作为丢弃手卡的代替代价。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
	else
		-- 将选择的手牌送去墓地，作为丢弃手卡的代价。
		Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
	end
end
-- 特殊召唤的过滤条件：是「冰结界」怪兽、调整为调整怪兽且满足特殊召唤条件。
function c18319762.spfilter(c,e,tp)
	return c:IsSetCard(0x2f) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标检查：我方怪兽区有空位，且卡组中存在可特殊召唤的「冰结界」调整怪兽。
function c18319762.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方怪兽区是否存在可利用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在1只满足spfilter的「冰结界」调整怪兽。
		and Duel.IsExistingMatchingCard(c18319762.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次效果的操作信息：从卡组特殊召唤1只怪兽（用于连锁检测）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组特殊召唤1只「冰结界」调整；之后给自己附加直到回合结束不能特殊召唤非水属性怪兽的自肃效果。
function c18319762.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 特殊召唤处理前再次确认我方怪兽区有空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 显示选择提示：请选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1张满足spfilter的「冰结界」调整怪兽。
		local g=Duel.SelectMatchingCard(tp,c18319762.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到我方场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是水属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c18319762.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到场上：我方直到回合结束不能特殊召唤非水属性怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃判断：若怪兽不是水属性，则不允许特殊召唤。
function c18319762.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
