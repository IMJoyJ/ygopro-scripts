--魔のデッキ破壊ウイルス
-- 效果：
-- ①：把自己场上1只攻击力2000以上的暗属性怪兽解放才能发动。对方场上的怪兽，对方手卡，用对方回合计算的3回合内对方抽到的卡全部确认，那之内的攻击力1500以下的怪兽全部破坏。
function c35027493.initial_effect(c)
	-- ①：把自己场上1只攻击力2000以上的暗属性怪兽解放才能发动。对方场上的怪兽，对方手卡，用对方回合计算的3回合内对方抽到的卡全部确认，那之内的攻击力1500以下的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_TOHAND+TIMINGS_CHECK_MONSTER)
	e1:SetCost(c35027493.cost)
	e1:SetTarget(c35027493.target)
	e1:SetOperation(c35027493.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断是否为暗属性且攻击力2000以上的怪兽
function c35027493.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAttackAbove(2000)
end
-- 检查并选择满足条件的怪兽进行解放作为发动代价
function c35027493.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张满足条件的可解放的卡
	if chk==0 then return Duel.CheckReleaseGroup(tp,c35027493.costfilter,1,nil) end
	-- 从场上选择1张满足条件的可解放的卡
	local g=Duel.SelectReleaseGroup(tp,c35027493.costfilter,1,1,nil)
	-- 以代价原因解放所选的卡
	Duel.Release(g,REASON_COST)
end
-- 过滤函数，用于判断是否为表侧表示且攻击力1500以下的怪兽
function c35027493.tgfilter(c)
	return c:IsFaceup() and c:IsAttackBelow(1500)
end
-- 设置效果处理时要破坏的怪兽目标
function c35027493.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有满足条件的怪兽
	local g=Duel.GetMatchingGroup(c35027493.tgfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，确定要破坏的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 过滤函数，用于判断是否为怪兽卡且攻击力1500以下
function c35027493.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttackBelow(1500)
end
-- 发动效果，确认对方场上和手牌的卡，并在对方抽卡时确认并破坏符合条件的怪兽
function c35027493.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上和手牌的所有卡
	local conf=Duel.GetFieldGroup(tp,0,LOCATION_MZONE+LOCATION_HAND)
	if conf:GetCount()>0 then
		-- 确认玩家查看指定卡
		Duel.ConfirmCards(tp,conf)
		local dg=conf:Filter(c35027493.filter,nil)
		-- 以效果原因破坏符合条件的卡
		Duel.Destroy(dg,REASON_EFFECT)
		-- 将对方手牌洗切
		Duel.ShuffleHand(1-tp)
	end
	-- 在对方抽卡时触发的效果，用于确认对方抽到的卡并破坏符合条件的怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DRAW)
	e1:SetOperation(c35027493.desop)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,3)
	-- 将效果注册到全局环境
	Duel.RegisterEffect(e1,tp)
	-- 在对方回合结束时触发的效果，用于记录回合数并重置相关效果
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c35027493.turncon)
	e2:SetOperation(c35027493.turnop)
	e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,3)
	-- 将效果注册到全局环境
	Duel.RegisterEffect(e2,tp)
	e2:SetLabelObject(e1)
	e:GetHandler():RegisterFlagEffect(1082946,RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,3)
	c35027493[e:GetHandler()]=e2
end
-- 确认对方抽到的卡并破坏符合条件的怪兽
function c35027493.desop(e,tp,eg,ep,ev,re,r,rp)
	if ep==e:GetOwnerPlayer() then return end
	local hg=eg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if hg:GetCount()==0 then return end
	-- 确认对方查看指定卡
	Duel.ConfirmCards(1-ep,hg)
	local dg=hg:Filter(c35027493.filter,nil)
	-- 以效果原因破坏符合条件的卡
	Duel.Destroy(dg,REASON_EFFECT)
	-- 将对方手牌洗切
	Duel.ShuffleHand(ep)
end
-- 判断当前回合玩家是否为效果持有者
function c35027493.turncon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否不为效果持有者
	return Duel.GetTurnPlayer()~=tp
end
-- 处理回合计数，当达到3回合时重置相关效果
function c35027493.turnop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	ct=ct+1
	e:SetLabel(ct)
	e:GetHandler():SetTurnCounter(ct)
	if ct==3 then
		e:GetLabelObject():Reset()
		e:GetOwner():ResetFlagEffect(1082946)
	end
end
