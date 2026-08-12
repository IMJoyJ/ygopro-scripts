--命王の螺旋
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。对方把手卡·墓地的怪兽的效果发动的回合，这张卡的发动从手卡也能用。
-- ①：以对方场上1只怪兽为对象才能发动。那只怪兽回到手卡·额外卡组。自己墓地没有陷阱卡存在的场合，再让对方可以从自身墓地把1只怪兽特殊召唤。这张卡从手卡发动的场合，发动后，这次决斗中自己不能把光·暗属性怪兽的效果发动。
local s,id,o=GetID()
-- 初始化效果：注册①效果（取对方场上怪兽为对象、返回手卡·额外卡组的发动型效果，含发动次数限制），注册从手卡发动的永续效果，并设置对方发动手卡·墓地怪兽效果的计数器
function s.initial_effect(c)
	-- ①：以对方场上1只怪兽为对象才能发动。那只怪兽回到手卡·额外卡组。自己墓地没有陷阱卡存在的场合，再让对方可以从自身墓地把1只怪兽特殊召唤。这个卡名的卡在1回合只能发动1张。
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
	-- 设置计数器：对方发动手卡·墓地的怪兽效果时计数，用于判断本回合这张卡能否从手卡发动
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- ①效果的对象处理：确认对方场上存在可返回手卡·额外卡组的怪兽，选择1只作为对象，若从手卡发动则记录标记以便后续适用发动限制
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and (chkc:IsAbleToHand() or chkc:IsAbleToExtra()) end
	e:SetLabel(0)
	-- 发动条件检查：确认对方场上存在至少1只可以返回手卡或额外卡组的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.OR(Card.IsAbleToHand,Card.IsAbleToExtra),tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示请选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1只可以返回手卡或额外卡组的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.OR(Card.IsAbleToHand,Card.IsAbleToExtra),tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：声明本连锁将把1张卡返回手卡，供王家长眠之谷等效果检测
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	if e:GetHandler():IsStatus(STATUS_ACT_FROM_HAND) then
		e:SetLabel(100)
	end
end
-- 过滤函数：判断对方墓地的怪兽是否可以被特殊召唤
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的处理：把对象怪兽返回手卡·额外卡组，若自己墓地没有陷阱卡且对方墓地有可特殊召唤的怪兽，则让对方选择是否将其中1只特殊召唤
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	-- 对象仍与连锁相关且是怪兽的场合，把那只怪兽以效果原因返回持有者的手卡（或额外卡组）
	if tc and tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND+LOCATION_EXTRA)
		-- 并且自己墓地没有陷阱卡存在的场合，才继续处理对方从墓地特殊召唤的部分
		and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_TRAP) then
		-- 检索对方墓地中可以被特殊召唤且不受王家长眠之谷影响的怪兽
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),1-tp,LOCATION_GRAVE,0,nil,e,1-tp)
		-- 若存在可特殊召唤的怪兽、对方怪兽区域有空位，且对方选择「是」，则进行特殊召唤
		if g:GetCount()>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
			-- 向对方玩家提示请选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(1-tp,1,1,nil)
			-- 让对方把选择的1只怪兽表侧表示特殊召唤到对方场上
			Duel.SpecialSummon(sg,0,1-tp,1-tp,false,false,POS_FACEUP)
		end
	end
	if e:GetLabel()==100 then
		-- 这张卡从手卡发动的场合，发动后，这次决斗中自己不能把光·暗属性怪兽的效果发动。对方把手卡·墓地的怪兽的效果发动的回合，这张卡的发动从手卡也能用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,3))  --"「命王的螺旋」效果适用中"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		-- 把禁止发动光·暗属性怪兽效果的永续效果注册给发动方玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制判断：光·暗属性的怪兽发动效果时返回真，即禁止其发动
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 计数器过滤：发动的效果是手卡或墓地发动的怪兽效果时返回假（计入计数），其余不计
function s.chainfilter(re,tp,cid)
	-- 取得该连锁中效果发动时所在的位置
	local loc=Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)
	return not (re:IsActiveType(TYPE_MONSTER) and loc&(LOCATION_HAND|LOCATION_GRAVE)>0)
end
-- 从手卡发动的条件：本回合对方曾发动过手卡·墓地的怪兽的效果
function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查对方本回合发动手卡·墓地怪兽效果的计数是否大于0
	return Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0
end
