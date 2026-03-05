--アーカナイト・マジシャン／バスター
-- 效果：
-- 这张卡不能通常召唤。「爆裂模式」的效果才能特殊召唤。这张卡特殊召唤成功时，给这张卡放置2个魔力指示物。这张卡放置的魔力指示物每有1个，这张卡的攻击力上升1000。可以把这张卡放置的2个魔力指示物取除，对方场上存在的卡全部破坏。此外，场上存在的这张卡被破坏时，可以把自己墓地存在的1只「奥金魔导师」特殊召唤。
function c14553285.initial_effect(c)
	-- 为卡片注册与「爆裂模式」相关的卡片代码，用于限制该卡只能通过特定方式特殊召唤。
	aux.AddCodeList(c,80280737)
	c:EnableReviveLimit()
	c:EnableCounterPermit(0x1)
	-- 这张卡不能通常召唤。「爆裂模式」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡的特殊召唤条件为必须通过「爆裂模式」效果发动而来。
	e1:SetValue(aux.AssaultModeLimit)
	c:RegisterEffect(e1)
	-- 这张卡特殊召唤成功时，给这张卡放置2个魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14553285,0))  --"放置魔力指示物"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c14553285.addct)
	e2:SetOperation(c14553285.addc)
	c:RegisterEffect(e2)
	-- 这张卡放置的魔力指示物每有1个，这张卡的攻击力上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c14553285.attackup)
	c:RegisterEffect(e3)
	-- 可以把这张卡放置的2个魔力指示物取除，对方场上存在的卡全部破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(14553285,1))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(c14553285.descost)
	e4:SetTarget(c14553285.destg)
	e4:SetOperation(c14553285.desop)
	c:RegisterEffect(e4)
	-- 此外，场上存在的这张卡被破坏时，可以把自己墓地存在的1只「奥金魔导师」特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(14553285,2))  --"特殊召唤"
	e5:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCondition(c14553285.spcon)
	e5:SetTarget(c14553285.sptg)
	e5:SetOperation(c14553285.spop)
	c:RegisterEffect(e5)
end
c14553285.assault_name=31924889
-- 该函数用于处理特殊召唤成功后放置魔力指示物的效果触发条件。
function c14553285.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将为该卡放置2个魔力指示物。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,2,0,0x1)
end
-- 该函数用于执行放置魔力指示物的操作。
function c14553285.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1,2)
	end
end
-- 该函数用于计算因魔力指示物而增加的攻击力。
function c14553285.attackup(e,c)
	return c:GetCounter(0x1)*1000
end
-- 该函数用于处理破坏效果的费用支付，即移除2个魔力指示物。
function c14553285.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,2,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,2,REASON_COST)
end
-- 该函数用于处理破坏效果的目标选择。
function c14553285.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否场上存在至少一张对方的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有对方的卡作为破坏目标。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息，表示将破坏场上所有对方的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 该函数用于执行破坏效果的操作。
function c14553285.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有对方的卡作为破坏目标。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 以效果原因破坏场上所有对方的卡。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 该函数用于判断该卡是否因在场上被破坏而触发特殊召唤效果。
function c14553285.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 该函数用于过滤墓地中的「奥金魔导师」卡片。
function c14553285.spfilter(c,e,tp)
	return c:IsCode(31924889) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 该函数用于处理特殊召唤效果的目标选择。
function c14553285.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c14553285.spfilter(chkc,e,tp) end
	-- 检查召唤者是否有足够的怪兽区域进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在符合条件的「奥金魔导师」卡片。
		and Duel.IsExistingTarget(c14553285.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送提示信息，提示其选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择墓地中符合条件的「奥金魔导师」卡片作为特殊召唤目标。
	local g=Duel.SelectTarget(tp,c14553285.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将特殊召唤一张「奥金魔导师」卡片。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 该函数用于执行特殊召唤效果的操作。
function c14553285.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片以特殊召唤方式召唤到场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
