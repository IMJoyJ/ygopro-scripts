--命王の螺旋
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。对方把手卡·墓地的怪兽的效果发动的回合，这张卡的发动从手卡也能用。
-- ①：以对方场上1只怪兽为对象才能发动。那只怪兽回到手卡·额外卡组。自己墓地没有陷阱卡存在的场合，再让对方可以从自身墓地把1只怪兽特殊召唤。这张卡从手卡发动的场合，发动后，这次决斗中自己不能把光·暗属性怪兽的效果发动。
local s,id,o=GetID()
-- 创建效果1，用于处理卡牌效果的发动和处理
function s.initial_effect(c)
	-- ①：以对方场上1只怪兽为对象才能发动。那只怪兽回到手卡·额外卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回到手卡·额外卡组"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 对方把手卡·墓地的怪兽的效果发动的回合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"适用「命王的螺旋」的效果从手卡发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
	-- 设置计数器，用于记录发动次数
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 设置效果目标选择函数，用于选择对方场上的怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	e:SetLabel(0)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and (chkc:IsAbleToHand() or chkc:IsAbleToExtra()) end
	-- 检查是否满足发动条件，即对方场上是否存在可返回手卡或额外卡组的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.OR(Card.IsAbleToHand,Card.IsAbleToExtra),tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,aux.OR(Card.IsAbleToHand,Card.IsAbleToExtra),tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，记录将要返回手卡的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	if e:GetHandler():IsStatus(STATUS_ACT_FROM_HAND) then
		e:SetLabel(100)
	end
end
-- 定义特殊召唤过滤函数
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 执行效果处理，将目标怪兽送回手卡或额外卡组，并根据条件决定是否让对方特殊召唤怪兽
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且为怪兽类型，并将其送回手卡
	if tc and tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and Duel.SendtoHand(tc,nil,REASON_EFFECT)
		and tc:IsLocation(LOCATION_HAND+LOCATION_EXTRA)
		-- 检查自己墓地是否存在陷阱卡，若不存在则可触发后续特殊召唤效果
		and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_TRAP) then
		-- 获取对方墓地可特殊召唤的怪兽
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),1-tp,LOCATION_GRAVE,0,nil,e,1-tp)
		-- 判断是否满足特殊召唤条件，包括对方墓地有怪兽、对方场上存在空位、对方选择是否特殊召唤
		if g:GetCount()>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
			-- 提示对方选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(1-tp,1,1,nil)
			-- 执行特殊召唤操作
			Duel.SpecialSummon(sg,0,1-tp,1-tp,false,false,POS_FACEUP)
		end
	end
	if e:GetLabel()==100 then
		-- 创建并注册一个禁止对方发动光·暗属性怪兽效果的场地方块效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,3))  --"「命王的螺旋」的效果适用中"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		-- 将效果注册到场上
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义禁止发动的条件，即对方发动的怪兽必须是光或暗属性
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 定义连锁过滤函数，用于判断是否为从手卡或墓地发动的怪兽效果
function s.chainfilter(re,tp,cid)
	-- 获取当前连锁的发动位置
	local loc=Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)
	return not (re:IsActiveType(TYPE_MONSTER) and loc&(LOCATION_HAND|LOCATION_GRAVE)>0)
end
-- 定义手卡发动条件函数，用于判断是否满足从手卡发动的条件
function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查对方是否发动过怪兽效果
	return Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0
end
