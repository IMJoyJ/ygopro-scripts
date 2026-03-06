--先史遺産アカンバロの土偶
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的「先史遗产」怪兽被战斗或者对方的效果破坏的场合，可以作为代替把手卡的这张卡丢弃。
-- ②：这张卡在墓地存在的场合，支付1000基本分才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡在结束阶段回到持有者手卡。这个效果发动的回合，自己不是「先史遗产」怪兽不能特殊召唤。
function c24506253.initial_effect(c)
	-- ①：自己场上的「先史遗产」怪兽被战斗或者对方的效果破坏的场合，可以作为代替把手卡的这张卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_HAND)
	e1:SetTarget(c24506253.reptg)
	e1:SetValue(c24506253.repval)
	e1:SetOperation(c24506253.repop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，支付1000基本分才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡在结束阶段回到持有者手卡。这个效果发动的回合，自己不是「先史遗产」怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24506253,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,24506253)
	e2:SetCost(c24506253.spcost)
	e2:SetTarget(c24506253.sptg)
	e2:SetOperation(c24506253.spop)
	c:RegisterEffect(e2)
	-- 设置一个计数器，用于记录玩家在回合中特殊召唤「先史遗产」怪兽的次数。
	Duel.AddCustomActivityCounter(24506253,ACTIVITY_SPSUMMON,c24506253.counterfilter)
end
-- 计数器的过滤函数，判断卡片是否为「先史遗产」卡。
function c24506253.counterfilter(c)
	return c:IsSetCard(0x70)
end
-- 判断目标怪兽是否为「先史遗产」怪兽，并且被战斗或对方效果破坏。
function c24506253.filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x70)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否满足代替破坏的条件，即场上有「先史遗产」怪兽被破坏且手牌可以丢弃。
function c24506253.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c24506253.filter,1,c,tp)
		and c:IsDiscardable() and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问玩家是否发动效果。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 返回代替破坏的目标是否为「先史遗产」怪兽。
function c24506253.repval(e,c)
	return c24506253.filter(c,e:GetHandlerPlayer())
end
-- 将手牌送去墓地作为代替破坏的效果处理。
function c24506253.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将手牌送去墓地作为代替破坏的效果处理。
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_DISCARD)
end
-- 支付1000基本分并设置不能特殊召唤非「先史遗产」怪兽的效果。
function c24506253.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分且本回合未发动过此效果。
	if chk==0 then return Duel.CheckLPCost(tp,1000) and Duel.GetCustomActivityCount(24506253,tp,ACTIVITY_SPSUMMON)==0 end
	-- 支付1000基本分。
	Duel.PayLPCost(tp,1000)
	-- 设置不能特殊召唤非「先史遗产」怪兽的效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c24506253.splimit)
	-- 将不能特殊召唤的效果注册给全局环境。
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤非「先史遗产」怪兽。
function c24506253.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x70)
end
-- 判断是否满足特殊召唤的条件。
function c24506253.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的位置进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- 执行特殊召唤操作，并注册结束阶段返回手牌的效果。
function c24506253.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断特殊召唤是否成功并注册结束阶段返回手牌的效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=c:GetFieldID()
		c:RegisterFlagEffect(24506253,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 注册结束阶段返回手牌的效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(c)
		e1:SetCondition(c24506253.thcon)
		e1:SetOperation(c24506253.thop)
		-- 将返回手牌的效果注册给全局环境。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断是否满足返回手牌的条件。
function c24506253.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(24506253)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 将卡片送回手牌。
function c24506253.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将卡片送回手牌。
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end
