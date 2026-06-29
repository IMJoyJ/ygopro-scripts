--命王の螺旋
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。对方把手卡·墓地的怪兽的效果发动的回合，这张卡的发动从手卡也能用。
-- ①：以对方场上1只怪兽为对象才能发动。那只怪兽回到手卡·额外卡组。自己墓地没有陷阱卡存在的场合，再让对方可以从自身墓地把1只怪兽特殊召唤。这张卡从手卡发动的场合，发动后，这次决斗中自己不能把光·暗属性怪兽的效果发动。
local s,id,o=GetID()
-- 注册卡片发动效果中对方场上怪兽返回手卡/额外且自己墓地无陷阱时对方可从墓地特召怪兽的效果，以及从手卡发动和手卡发动后的玩家光暗属性怪兽效果发动限制的注册
function s.initial_effect(c)
	-- ①：以对方场上1只怪兽为对象才能发动。那只怪兽回到手卡·额外卡组。自己墓地没有陷阱卡存在的场合，再让对方可以从自身墓地把1只怪兽特殊召唤。
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
	-- 注册此卡在符合条件时可以从手卡直接发动的单体规则效果
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"适用「命王的螺旋」的效果从手卡发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
	-- 注册用于记录玩家是否在手卡或墓地发动过怪兽效果的自定义活动计数器
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 对象弹回手卡/额外效果的发动准备与对象选择
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and (chkc:IsAbleToHand() or chkc:IsAbleToExtra()) end
	e:SetLabel(0)
	-- 检查对方场上是否存在可以返回手牌或额外卡组的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.OR(Card.IsAbleToHand,Card.IsAbleToExtra),tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示，请选择弹回的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从对方场上选择1只怪兽作为弹回的对象
	local g=Duel.SelectTarget(tp,aux.OR(Card.IsAbleToHand,Card.IsAbleToExtra),tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为将选中的怪兽返回手牌或额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	if e:GetHandler():IsStatus(STATUS_ACT_FROM_HAND) then
		e:SetLabel(100)
	end
end
-- 对方墓地中可特殊召唤的怪兽的过滤条件
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 对象怪兽弹回手牌/额外、以及满足条件时对方特殊召唤墓地怪兽和手卡发动时后续决斗封锁效果的执行
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中关联的作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 将该怪兽送回对方的手卡或额外卡组
	if tc and tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND+LOCATION_EXTRA)
		-- 检查自己墓地中是否没有任何陷阱卡存在，若无则继续处理后续的对方特召
		and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_TRAP) then
		-- 获取对方墓地中所有符合特殊召唤条件的怪兽
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),1-tp,LOCATION_GRAVE,0,nil,e,1-tp)
		-- 对方若有可用怪兽与怪兽格，询问对方玩家是否选择特召墓地怪兽
		if g:GetCount()>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
			-- 向对方玩家发送提示，请选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(1-tp,1,1,nil)
			-- 对方玩家选择并将其墓地的1只怪兽表侧表示特殊召唤
			Duel.SpecialSummon(sg,0,1-tp,1-tp,false,false,POS_FACEUP)
		end
	end
	if e:GetLabel()==100 then
		-- 注册限制玩家本次决斗中无法发动任何光属性或暗属性怪兽效果的玩家全局持续效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,3))  --"「命王的螺旋」效果适用中"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		-- 将上述决斗中光暗属性怪兽发动限制注册给手卡发动的玩家自身
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判定被限制发动的效果是否属于光属性或暗属性怪兽的效果
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 自定义计数器过滤：筛选出在手卡或墓地发动的怪兽效果
function s.chainfilter(re,tp,cid)
	-- 获取触发效果的卡片所处的当前位置
	local loc=Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)
	return not (re:IsActiveType(TYPE_MONSTER) and loc&(LOCATION_HAND|LOCATION_GRAVE)>0)
end
-- 判断对方在本回合内是否在手卡或墓地发动过怪兽效果
function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	-- 若是则符合允许此卡从手卡发动的条件
	return Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0
end
