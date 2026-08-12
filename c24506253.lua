--先史遺産アカンバロの土偶
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的「先史遗产」怪兽被战斗或者对方的效果破坏的场合，可以作为代替把手卡的这张卡丢弃。
-- ②：这张卡在墓地存在的场合，支付1000基本分才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡在结束阶段回到持有者手卡。这个效果发动的回合，自己不是「先史遗产」怪兽不能特殊召唤。
function c24506253.initial_effect(c)
	-- 自己场上的「先史遗产」怪兽被战斗或者对方的效果破坏的场合，可以作为代替把手卡的这张卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_HAND)
	e1:SetTarget(c24506253.reptg)
	e1:SetValue(c24506253.repval)
	e1:SetOperation(c24506253.repop)
	c:RegisterEffect(e1)
	-- 这张卡在墓地存在的场合，支付1000基本分才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡在结束阶段回到持有者手卡。这个效果发动的回合，自己不是「先史遗产」怪兽不能特殊召唤。
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
	-- 设定限制特殊召唤非「先史遗产」怪兽的自定义活动计数器
	Duel.AddCustomActivityCounter(24506253,ACTIVITY_SPSUMMON,c24506253.counterfilter)
end
-- 自定义活动计数器的过滤函数，检查被特殊召唤的怪兽是否为「先史遗产」怪兽
function c24506253.counterfilter(c)
	return c:IsSetCard(0x70) and c:IsFaceup()
end
-- 代替破坏的过滤函数，检查是否为自己场上因战斗或对方的效果破坏的「先史遗产」怪兽
function c24506253.filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x70)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的靶指向与检查函数，验证是否有符合条件的破坏怪兽且手牌中的此卡可丢弃
function c24506253.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c24506253.filter,1,c,tp)
		and c:IsDiscardable() and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问玩家是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏的值函数，确定哪些怪兽受此代替破坏效果保护
function c24506253.repval(e,c)
	return c24506253.filter(c,e:GetHandlerPlayer())
end
-- 代替破坏的操作函数，执行将此卡丢弃去墓地的操作
function c24506253.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 作为代替将手牌中的此卡送去墓地（丢弃）
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_DISCARD)
end
-- 墓地特殊召唤效果的代价与誓约条件检测函数
function c24506253.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查玩家是否能支付1000基本分，且本回合至今未特殊召唤过非「先史遗产」怪兽
	if chk==0 then return Duel.CheckLPCost(tp,1000) and Duel.GetCustomActivityCount(24506253,tp,ACTIVITY_SPSUMMON)==0 end
	-- 支付1000点基本分作为发动的代价
	Duel.PayLPCost(tp,1000)
	-- 这张卡特殊召唤。这个效果发动的回合，自己不是「先史遗产」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c24506253.splimit)
	-- 注册本回合不能特殊召唤非「先史遗产」怪兽的誓约效果
	Duel.RegisterEffect(e1,tp)
end
-- 特召限制过滤函数，限制不能特殊召唤非「先史遗产」怪兽
function c24506253.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x70)
end
-- 墓地特殊召唤效果的靶指向函数，检查主要怪兽区是否有空位以及此卡是否可以特殊召唤
function c24506253.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示此效果将从墓地特殊召唤1张卡（即自身）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- 墓地特殊召唤效果的操作函数，处理特殊召唤并注册结束阶段回手牌的效果
function c24506253.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果此卡仍与效果相关，则将其以表侧表示特殊召唤并判断是否特殊召唤成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=c:GetFieldID()
		c:RegisterFlagEffect(24506253,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的这张卡在结束阶段回到持有者手卡。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(c)
		e1:SetCondition(c24506253.thcon)
		e1:SetOperation(c24506253.thop)
		-- 注册在回合结束阶段时将该卡送回手牌的延迟型效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 回手牌延迟效果的触发条件，验证此卡自特召以来是否在场且标记未改变，否则重置并失效
function c24506253.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(24506253)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 回手牌延迟效果的操作函数，执行将此卡送回持有者手牌
function c24506253.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将特殊召唤的此卡送回持有者的手牌
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end
