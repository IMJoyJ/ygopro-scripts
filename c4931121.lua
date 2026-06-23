--影のデッキ破壊ウイルス
-- 效果：
-- ①：把自己场上1只守备力2000以上的暗属性怪兽解放才能发动。对方场上的怪兽，对方手卡，用对方回合计算的3回合内对方抽到的卡全部确认，那之内的守备力1500以下的怪兽全部破坏。
function c4931121.initial_effect(c)
	-- ①：把自己场上1只守备力2000以上的暗属性怪兽解放才能发动。对方场上的怪兽，对方手卡，用对方回合计算的3回合内对方抽到的卡全部确认，那之内的守备力1500以下的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_TOHAND+TIMINGS_CHECK_MONSTER)
	e1:SetCost(c4931121.cost)
	e1:SetTarget(c4931121.target)
	e1:SetOperation(c4931121.activate)
	c:RegisterEffect(e1)
end
-- 费用过滤器：暗属性且守备力不低于2000的怪兽
function c4931121.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsDefenseAbove(2000)
end
-- 发动时的费用处理：检查并选择1只满足条件的怪兽进行解放
function c4931121.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足解放条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,c4931121.costfilter,1,nil) end
	-- 选择1只满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c4931121.costfilter,1,1,nil)
	-- 将选中的怪兽以费用形式解放
	Duel.Release(g,REASON_COST)
end
-- 目标过滤器：场上正面表示且守备力不超过1500的怪兽
function c4931121.tgfilter(c)
	return c:IsFaceup() and c:IsDefenseBelow(1500)
end
-- 发动时的处理：确认对方场上的怪兽和手卡中守备力不超过1500的怪兽
function c4931121.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上的所有怪兽
	local g=Duel.GetMatchingGroup(c4931121.tgfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，确定要破坏的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏过滤器：怪兽类型且守备力不超过1500
function c4931121.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsDefenseBelow(1500)
end
-- 发动效果处理：确认对方场上和手牌中的卡，并在对方抽卡时确认其手牌并破坏其中守备力不超过1500的怪兽
function c4931121.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有怪兽和手牌
	local conf=Duel.GetFieldGroup(tp,0,LOCATION_MZONE+LOCATION_HAND)
	if conf:GetCount()>0 then
		-- 确认对方场上和手牌中的卡
		Duel.ConfirmCards(tp,conf)
		local dg=conf:Filter(c4931121.filter,nil)
		-- 将符合条件的怪兽破坏
		Duel.Destroy(dg,REASON_EFFECT)
		-- 洗切对方的手牌
		Duel.ShuffleHand(1-tp)
	end
	-- 注册一个在对方抽卡时触发的效果，用于确认对方抽到的卡并破坏其中守备力不超过1500的怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DRAW)
	e1:SetOperation(c4931121.desop)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,3)
	-- 注册该效果给对方玩家
	Duel.RegisterEffect(e1,tp)
	-- 注册一个在对方回合结束时触发的效果，用于控制持续时间
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c4931121.turncon)
	e2:SetOperation(c4931121.turnop)
	e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,3)
	-- 注册该效果给对方玩家
	Duel.RegisterEffect(e2,tp)
	e2:SetLabelObject(e1)
	e:GetHandler():RegisterFlagEffect(1082946,RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,3)
	c4931121[e:GetHandler()]=e2
end
-- 抽卡时的处理：确认对方抽到的手牌并破坏其中守备力不超过1500的怪兽
function c4931121.desop(e,tp,eg,ep,ev,re,r,rp)
	if ep==e:GetOwnerPlayer() then return end
	local hg=eg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if hg:GetCount()==0 then return end
	-- 确认对方抽到的手牌
	Duel.ConfirmCards(1-ep,hg)
	local dg=hg:Filter(c4931121.filter,nil)
	-- 将符合条件的怪兽破坏
	Duel.Destroy(dg,REASON_EFFECT)
	-- 洗切对方的手牌
	Duel.ShuffleHand(ep)
end
-- 回合结束时的触发条件：当前回合不是发动者回合
function c4931121.turncon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合是否为发动者回合
	return Duel.GetTurnPlayer()~=tp
end
-- 回合结束时的处理：记录回合数，当达到3回合后重置效果
function c4931121.turnop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	ct=ct+1
	e:SetLabel(ct)
	e:GetHandler():SetTurnCounter(ct)
	if ct==3 then
		e:GetLabelObject():Reset()
		e:GetOwner():ResetFlagEffect(1082946)
	end
end
