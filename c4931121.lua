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
-- costfilter：代价解放的过滤条件，要求怪兽为暗属性且守备力2000以上。
function c4931121.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsDefenseAbove(2000)
end
-- 发动代价处理：先检查是否存在可解放的暗属性·守备力2000以上怪兽；实际发动时选择1只并解放作为COST。
function c4931121.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认自己场上存在至少1只暗属性且守备力2000以上的可解放怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c4931121.costfilter,1,nil) end
	-- 从自己场上选择1只满足条件的可解放怪兽（暗属性且守备力2000以上）作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,c4931121.costfilter,1,1,nil)
	-- 将选择的怪兽解放，作为发动效果的代价。
	Duel.Release(g,REASON_COST)
end
-- tgfilter：筛选对方场上表侧表示且守备力1500以下的怪兽。
function c4931121.tgfilter(c)
	return c:IsFaceup() and c:IsDefenseBelow(1500)
end
-- 发动时的目标函数：不取对象；统计对方场上表侧表示且守备力1500以下的怪兽，并设置破坏类别的操作信息。
function c4931121.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 取得对方场上所有表侧表示且守备力1500以下的怪兽。
	local g=Duel.GetMatchingGroup(c4931121.tgfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：登记将破坏上述怪兽，数量为组内数量，类别为破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- filter：实际破坏时的筛选条件，要求是怪兽且守备力1500以下。
function c4931121.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsDefenseBelow(1500)
end
-- 效果处理：确认对方场上怪兽和对方手牌的全部卡，破坏其中守备力1500以下的怪兽并洗切对方手牌；随后创建持续3回合的抽卡确认破坏效果和阶段计数效果。
function c4931121.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上怪兽区域与对方手牌的所有卡。
	local conf=Duel.GetFieldGroup(tp,0,LOCATION_MZONE+LOCATION_HAND)
	if conf:GetCount()>0 then
		-- 向效果发动者展示并确认对方场上怪兽与手牌的全部卡。
		Duel.ConfirmCards(tp,conf)
		local dg=conf:Filter(c4931121.filter,nil)
		-- 将确认的卡中守备力1500以下的怪兽全部破坏，破坏原因为效果。
		Duel.Destroy(dg,REASON_EFFECT)
		-- 洗切对方手牌，因为手牌已被确认需要重排顺序。
		Duel.ShuffleHand(1-tp)
	end
	-- 用对方回合计算的3回合内对方抽到的卡全部确认，那之内的守备力1500以下的怪兽全部破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DRAW)
	e1:SetOperation(c4931121.desop)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,3)
	-- 将抽卡时确认并破坏的持续效果注册到场上，持续3回合。
	Duel.RegisterEffect(e1,tp)
	-- 用对方回合计算的3回合内对方抽到的卡全部确认，那之内的守备力1500以下的怪兽全部破坏。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c4931121.turncon)
	e2:SetOperation(c4931121.turnop)
	e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,3)
	-- 将阶段计数效果注册到场上，用于在每个对方回合结束阶段推进3回合的计数。
	Duel.RegisterEffect(e2,tp)
	e2:SetLabelObject(e1)
	e:GetHandler():RegisterFlagEffect(1082946,RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,3)
	c4931121[e:GetHandler()]=e2
end
-- 抽卡时点处理：若抽卡玩家为对方，则确认抽到的卡，破坏其中守备力1500以下的怪兽，并洗切对方手牌。
function c4931121.desop(e,tp,eg,ep,ev,re,r,rp)
	if ep==e:GetOwnerPlayer() then return end
	local hg=eg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if hg:GetCount()==0 then return end
	-- 向效果发动者展示对方抽到的卡，以确认抽卡内容。
	Duel.ConfirmCards(1-ep,hg)
	local dg=hg:Filter(c4931121.filter,nil)
	-- 将对方抽到的卡中守备力1500以下的怪兽全部破坏，破坏原因为效果。
	Duel.Destroy(dg,REASON_EFFECT)
	-- 洗切抽卡玩家（对方）的手牌，防止手牌顺序信息泄露。
	Duel.ShuffleHand(ep)
end
-- 阶段计数效果的触发条件：当前回合为对方回合（回合玩家不是tp）。
function c4931121.turncon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方（不等于效果发动者），是则条件成立。
	return Duel.GetTurnPlayer()~=tp
end
-- 阶段计数处理：每次对方回合结束阶段计数加1；计数达到3时重置抽卡监视效果并清除效果标志，使持续效果结束。
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
