--神蝕む光 ティスティナ
-- 效果：
-- 10星怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。对方场上的里侧表示卡全部送去墓地。
-- ②：这张卡有「结晶神 提斯蒂娜」在作为超量素材的场合，1回合1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力直到对方回合结束时上升2000。
-- ③：持有超量素材的这张卡被对方破坏的场合才能发动。从自己墓地把1只「提斯蒂娜」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果注册函数，设置XYZ召唤手续、苏生限制及4个效果。
function s.initial_effect(c)
	-- 设置XYZ召唤手续：10星怪兽×2。
	aux.AddXyzProcedure(c,nil,10,2)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。对方场上的里侧表示卡全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"里侧卡送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡有「结晶神 提斯蒂娜」在作为超量素材的场合，1回合1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力直到对方回合结束时上升2000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.atkcon)
	e2:SetCost(s.atkcost)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	-- ③：持有超量素材的这张卡被对方破坏的场合才能发动。从自己墓地把1只「提斯蒂娜」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ③：持有超量素材的
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetLabelObject(e3)
	e4:SetOperation(s.chk)
	c:RegisterEffect(e4)
end
-- 过滤对方场上里侧表示且可以送去墓地的卡的过滤函数。
function s.tgfilter(c)
	return c:IsFacedown() and c:IsAbleToGrave()
end
-- ①效果的发动检测与效果处理信息设置函数。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张满足条件的里侧表示卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有满足条件的里侧表示卡。
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置效果处理信息：将对方场上的里侧表示卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- ①效果的实际处理函数，将对方场上的里侧表示卡全部送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有满足条件的里侧表示卡。
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 因效果将这些卡全部送去墓地。
	Duel.SendtoGrave(g,REASON_EFFECT)
end
-- ②效果的发动条件：检查这张卡是否有「结晶神 提斯蒂娜」作为超量素材。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,86999951)
end
-- ②效果的代价值：取除这张卡的1个超量素材。
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ②效果的实际处理函数，使这张卡的攻击力直到对方回合结束时上升2000。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到对方回合结束时上升2000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		e1:SetValue(2000)
		c:RegisterEffect(e1)
	end
end
-- ③效果的发动条件：在自己场上被对方破坏，且离场前持有超量素材。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetReasonPlayer()==1-tp and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and e:GetLabel()>0
end
-- 过滤自己墓地中可以特殊召唤的「提斯蒂娜」怪兽的过滤函数。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1a4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动检测与效果处理信息设置函数。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只可以特殊召唤的「提斯蒂娜」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理信息：从墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ③效果的实际处理函数，从自己墓地选择1只「提斯蒂娜」怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 让玩家从自己墓地选择1只满足条件的「提斯蒂娜」怪兽（受王家长眠之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 离场前置效果的处理函数，将当前超量素材数量记录到③效果中，用于判定是否持有素材。
function s.chk(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(e:GetHandler():GetOverlayCount())
end
