--混沌のヴァルキリア
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己墓地把1只光属性或者暗属性的怪兽除外才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡被除外的场合才能发动。从卡组把1只光属性或者暗属性的怪兽送去墓地。这个回合，自己不能把这个效果送去墓地的卡以及那些同名卡的效果发动。
function c53871273.initial_effect(c)
	-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c53871273.splimit)
	c:RegisterEffect(e1)
	-- ①：从自己墓地把1只光属性或者暗属性的怪兽除外才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53871273,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,53871273)
	e2:SetCost(c53871273.spcost)
	e2:SetTarget(c53871273.sptg)
	e2:SetOperation(c53871273.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡被除外的场合才能发动。从卡组把1只光属性或者暗属性的怪兽送去墓地。这个回合，自己不能把这个效果送去墓地的卡以及那些同名卡的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,53871274)
	e3:SetTarget(c53871273.tgtg)
	e3:SetOperation(c53871273.tgop)
	c:RegisterEffect(e3)
end
-- 特殊召唤条件判定函数：仅当特殊召唤行为来自具有行动类效果类型（如起动、诱发等）的卡的效果时才允许，从而实现“用卡的效果才能特殊召唤”的限制。
function c53871273.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 墓地怪兽的过滤条件：可作为代价除外，且属性为光属性或暗属性。
function c53871273.cfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- ①效果的发动代价：从自己墓地选择1只光/暗属性怪兽表侧表示除外，作为特殊召唤的COST。
function c53871273.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认（chk==0）：自己墓地中是否存在满足cfilter条件的光/暗属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c53871273.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示，让玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己墓地选择1张满足cfilter条件的怪兽卡。
	local sg=Duel.SelectMatchingCard(tp,c53871273.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的那张怪兽卡以表侧表示除外，作为发动代价（REASON_COST）。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- ①效果发动条件检查：自己场上存在可用的主要怪兽区空格，且这张混沌女武神自身满足特殊召唤条件。
function c53871273.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向系统登记本次连锁将进行的特殊召唤操作信息，用于后续卡片的发动判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，则将其特殊召唤到自己场上。
function c53871273.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将混沌女武神以表侧表示特殊召唤到己方场上（不检查召唤条件、不检查苏生限制）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 卡组怪兽的过滤条件：属性为光属性或暗属性，且可以被送去墓地。
function c53871273.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToGrave()
end
-- ②效果的发动条件：卡组存在满足tgfilter条件的怪兽，并设置送去墓地的操作信息。
function c53871273.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认（chk==0）：卡组中是否存在符合条件的怪兽可送去墓地。
	if chk==0 then return Duel.IsExistingMatchingCard(c53871273.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向系统登记本次连锁将把卡组的1只怪兽送去墓地的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1只光/暗属性怪兽送去墓地，若成功则给己方附加本回合不能发动该卡及同名卡效果的封锁。
function c53871273.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，让玩家选择要送入墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从自己卡组选择1张满足tgfilter条件的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c53871273.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 确认该卡确实被效果送入墓地且现在位于墓地，然后才继续附加不能发动同名卡效果的封锁。
		if Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
			-- 这个回合，自己不能把这个效果送去墓地的卡以及那些同名卡的效果发动。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(1,0)
			e1:SetValue(c53871273.aclimit)
			e1:SetLabel(g:GetFirst():GetCode())
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 将上述封锁效果注册到玩家自身（EFFECT_CANNOT_ACTIVATE），持续到回合结束。
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 封锁判定：试图发动的效果的所有者卡与之前送去墓地的卡卡号相同，则禁止发动。
function c53871273.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
