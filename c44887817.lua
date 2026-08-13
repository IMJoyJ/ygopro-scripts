--増草剤
-- 效果：
-- ①：1回合1次，以自己墓地1只植物族怪兽为对象才能发动。那只植物族怪兽特殊召唤。这个效果把怪兽特殊召唤的回合，自己不能通常召唤。这个效果特殊召唤的怪兽从场上离开时这张卡破坏。
function c44887817.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以自己墓地1只植物族怪兽为对象才能发动。那只植物族怪兽特殊召唤。这个效果把怪兽特殊召唤的回合，自己不能通常召唤。
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
-- 发动代价/条件判定：若为发动判定阶段（chk==0），要求本回合还没有进行过通常召唤，已通召过则不能发动。
function c44887817.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动判定时，检查本回合通常召唤次数为0，作为该效果可发动的条件。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0 end
end
-- 候选怪兽过滤：选择自己墓地中植物族且能被效果特殊召唤的怪兽（满足召唤条件与苏生限制）。
function c44887817.filter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动目标的选定：若指定对象则必须是己方墓地的植物族且符合条件；若为发动前判定，则需主怪兽区有空位且墓地存在符合条件的对象。
function c44887817.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c44887817.filter(chkc,e,tp) end
	-- 判定自己场上是否有可用的主怪兽区空格用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在至少1只符合条件的植物族怪兽可作为效果对象。
		and Duel.IsExistingTarget(c44887817.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示信息，内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的植物族怪兽，并将其设为这张卡效果的对象。
	local g=Duel.SelectTarget(tp,c44887817.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将本次连锁的处理信息设为“特殊召唤”指定对象，数量1，便于后续时点触发与效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理流程：确认本回合未通常召唤后，取出对象怪兽，若其仍与效果关联且为植物族，则将其特殊召唤；成功后把该怪兽作为这张卡的永续对象，并给自己附加本回合不能通常召唤（不能召唤/不能覆盖怪兽）的限制；若特殊召唤失败则停止处理。
function c44887817.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查本回合尚未通常召唤，否则效果不处理。
	if Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)~=0 then return end
	local c=e:GetHandler()
	-- 取得发动时选择的对象怪兽（墓地植物族）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_PLANT) then
		-- 将对象怪兽表侧表示特殊召唤到自己场上；若特殊召唤成功数量为0则终止后续处理。
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		c:SetCardTarget(tc)
		-- 这个效果把怪兽特殊召唤的回合，自己不能通常召唤。这个效果特殊召唤的怪兽从场上离开时这张卡破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
		-- 将“不能召唤怪兽”的制约效果注册给发动玩家，持续到结束阶段。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_MSET)
		-- 将“不能覆盖怪兽”的制约效果注册给发动玩家，持续到结束阶段。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 过滤函数：判断离场怪兽是否包含在给定的卡片集合中，用于识别是否为这张卡效果特殊召唤的怪兽。
function c44887817.dfilter(c,sg)
	return sg:IsContains(c)
end
-- 持续效果的发动条件：这张卡存在通过自身效果特殊召唤的永续对象，且该对象怪兽从场上离开时条件成立。
function c44887817.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetCardTargetCount()==0 then return false end
	return c:GetCardTarget():IsExists(c44887817.dfilter,1,nil,eg)
end
-- 持续效果处理：破坏这张卡自身。
function c44887817.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将增草剂这张卡破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
