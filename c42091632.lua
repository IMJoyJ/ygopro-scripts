--命王の螺旋
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。对方把手卡·墓地的怪兽的效果发动的回合，这张卡的发动从手卡也能用。
-- ①：以对方场上1只怪兽为对象才能发动。那只怪兽回到手卡·额外卡组。自己墓地没有陷阱卡存在的场合，再让对方可以从自身墓地把1只怪兽特殊召唤。这张卡从手卡发动的场合，发动后，这次决斗中自己不能把光·暗属性怪兽的效果发动。
local s,id,o=GetID()
-- 初始化卡片效果，注册卡片发动效果、手卡发动效果以及用于检测手卡发动的活动计数器
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以对方场上1只怪兽为对象才能发动。那只怪兽回到手卡·额外卡组。自己墓地没有陷阱卡存在的场合，再让对方可以从自身墓地把1只怪兽特殊召唤。
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
	-- 添加自定义活动计数器，用于记录对方在手卡或墓地发动怪兽效果的次数
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 效果发动的目标检查与选择函数，当从手卡发动时，设置Label为100以用于后续注册限制效果
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and (chkc:IsAbleToHand() or chkc:IsAbleToExtra()) end
	e:SetLabel(0)
	-- 检查对方场上是否存在可以回到手牌或额外卡组的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.OR(Card.IsAbleToHand,Card.IsAbleToExtra),tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手牌或额外卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择对方场上的1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,aux.OR(Card.IsAbleToHand,Card.IsAbleToExtra),tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置将选中的怪兽送回手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	if e:GetHandler():IsStatus(STATUS_ACT_FROM_HAND) then
		e:SetLabel(100)
	end
end
-- 过滤墓地中可以被特殊召唤的怪兽的过滤条件
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理的激活函数，将对象怪兽返回手牌/额外卡组，满足条件时让对方特殊召唤墓地怪兽，并处理手卡发动的限制效果
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽是否仍与此连锁相关，且如果是怪兽，执行送回手牌/额外卡组的操作
	if tc and tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and Duel.SendtoHand(tc,nil,REASON_EFFECT)
		and tc:IsLocation(LOCATION_HAND+LOCATION_EXTRA)
		-- 检查自己墓地是否不存在陷阱卡，以决定是否进行后续的特殊召唤处理
		and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_TRAP) then
		-- 获取对方墓地中不受王家之谷影响且可以被特殊召唤的怪兽
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),1-tp,LOCATION_GRAVE,0,nil,e,1-tp)
		-- 若对方墓地有符合条件的怪兽且有怪兽区域空位，询问对方是否特殊召唤
		if g:GetCount()>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
			-- 提示对方玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(1-tp,1,1,nil)
			-- 执行将选中的怪兽特殊召唤到对方场上的处理
			Duel.SpecialSummon(sg,0,1-tp,1-tp,false,false,POS_FACEUP)
		end
	end
	if e:GetLabel()==100 then
		-- 这张卡从手卡发动的场合，发动后，这次决斗中自己不能把光·暗属性怪兽的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,3))  --"「命王的螺旋」效果适用中"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		-- 将无法发动光·暗属性怪兽效果的限制注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制自己不能发动光·暗属性怪兽效果的限制条件过滤函数
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 自定义活动计数器的过滤函数，检测发动的效果是否为手牌或墓地的怪兽效果
function s.chainfilter(re,tp,cid)
	-- 获取触发该效果的卡片所在的位置
	local loc=Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)
	return not (re:IsActiveType(TYPE_MONSTER) and loc&(LOCATION_HAND|LOCATION_GRAVE)>0)
end
-- 手卡发动的条件函数，检查对方本回合是否在手牌或墓地发动过怪兽效果
function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	-- 判断对方本回合在手牌或墓地发动过怪兽效果的次数是否大于0
	return Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0
end
