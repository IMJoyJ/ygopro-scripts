--増草剤
-- 效果：
-- ①：1回合1次，以自己墓地1只植物族怪兽为对象才能发动。那只植物族怪兽特殊召唤。这个效果把怪兽特殊召唤的回合，自己不能通常召唤。这个效果特殊召唤的怪兽从场上离开时这张卡破坏。
function c44887817.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以自己墓地1只植物族怪兽为对象才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44887817,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(c44887817.cost)
	e2:SetTarget(c44887817.target)
	e2:SetOperation(c44887817.operation)
	c:RegisterEffect(e2)
	-- 这个效果特殊召唤的怪兽从场上离开时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c44887817.descon)
	e3:SetOperation(c44887817.desop)
	c:RegisterEffect(e3)
end
-- 检查玩家在本回合是否进行过通常召唤，若已进行则不能发动此效果。
function c44887817.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若未进行通常召唤，则允许发动此效果。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0 end
end
-- 过滤满足条件的植物族怪兽（可特殊召唤）。
function c44887817.filter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标为己方墓地的植物族怪兽。
function c44887817.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c44887817.filter(chkc,e,tp) end
	-- 检查己方场上是否有足够的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认己方墓地是否存在满足条件的植物族怪兽。
		and Duel.IsExistingTarget(c44887817.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的植物族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c44887817.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表明将特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行效果处理，将目标怪兽特殊召唤到场上。
function c44887817.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若本回合已进行通常召唤，则不执行效果。
	if Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)~=0 then return end
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_PLANT) then
		-- 将目标怪兽特殊召唤到场上。
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		c:SetCardTarget(tc)
		-- 创建并注册不能通常召唤和不能设置的永续效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
		-- 将不能通常召唤的效果注册给玩家。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_MSET)
		-- 将不能设置的效果注册给玩家。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 判断目标怪兽是否存在于效果对象中。
function c44887817.dfilter(c,sg)
	return sg:IsContains(c)
end
-- 判断效果特殊召唤的怪兽是否离开场上的条件。
function c44887817.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetCardTargetCount()==0 then return false end
	return c:GetCardTarget():IsExists(c44887817.dfilter,1,nil,eg)
end
-- 执行破坏效果，将自身破坏。
function c44887817.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将自身破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
