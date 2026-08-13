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
-- 该过滤函数判定作为COST的怪兽：必须是暗属性且攻击力在2000以上。
function c35027493.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAttackAbove(2000)
end
-- 效果发动代价处理：在合法性检查通过后，选择1只符合条件的怪兽并解放作为COST。
function c35027493.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：确认自己场上是否存在至少1只符合条件的可解放怪兽（暗属性且攻击力2000以上），以决定效果是否可以发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c35027493.costfilter,1,nil) end
	-- 从自己场上选择1只满足条件的怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,c35027493.costfilter,1,1,nil)
	-- 将选择的怪兽解放，作为效果的发动代价。
	Duel.Release(g,REASON_COST)
end
-- 该过滤函数用于判定对方场上表侧表示且攻击力1500以下的怪兽，作为效果处理时可能被破坏的对象。
function c35027493.tgfilter(c)
	return c:IsFaceup() and c:IsAttackBelow(1500)
end
-- 效果发动时的目标阶段：无条件允许发动；同时获取对方场上符合条件的怪兽，并设置操作信息，使破坏效果能被正确记录。
function c35027493.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有表侧表示且攻击力1500以下的怪兽，用于设置破坏对象的范围。
	local g=Duel.GetMatchingGroup(c35027493.tgfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：破坏类别为CATEGORY_DESTROY，对象为上述怪兽，数量为其数量，以便相关效果进行检测联动。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 该过滤函数用于筛选所有需要被破坏的卡：必须是怪兽且攻击力1500以下，适用于对方场上、手牌以及后续抽到的卡。
function c35027493.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttackBelow(1500)
end
-- 效果处理：确认对方场上及手牌的全部卡，破坏其中攻击力1500以下的怪兽；随后在对方回合内设置监视抽卡的持续效果和回合计数效果，使之后3次对方回合抽到的卡也被确认并破坏。
function c35027493.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上与手卡中的全部卡（不分表侧里侧），用于下一步确认。
	local conf=Duel.GetFieldGroup(tp,0,LOCATION_MZONE+LOCATION_HAND)
	if conf:GetCount()>0 then
		-- 将对方场上与手卡的全部卡展示给效果发动者确认。
		Duel.ConfirmCards(tp,conf)
		local dg=conf:Filter(c35027493.filter,nil)
		-- 将符合攻击力1500以下的怪兽卡全部破坏，破坏原因为效果。
		Duel.Destroy(dg,REASON_EFFECT)
		-- 破坏后洗切对方的手牌，去除确认状态并恢复手牌顺序。
		Duel.ShuffleHand(1-tp)
	end
	-- 用对方回合计算的3回合内对方抽到的卡全部确认，那之内的攻击力1500以下的怪兽全部破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DRAW)
	e1:SetOperation(c35027493.desop)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,3)
	-- 将监视对方抽卡的持续效果e1注册到发动者场上，使之后每次抽卡时都会触发desop处理。
	Duel.RegisterEffect(e1,tp)
	-- 用对方回合计算的3回合内
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c35027493.turncon)
	e2:SetOperation(c35027493.turnop)
	e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,3)
	-- 将回合计数持续效果e2注册到发动者场上，用于在对方回合结束时推进3回合的计数。
	Duel.RegisterEffect(e2,tp)
	e2:SetLabelObject(e1)
	e:GetHandler():RegisterFlagEffect(1082946,RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,3)
	c35027493[e:GetHandler()]=e2
end
-- 若是对方（非效果发动者）抽到卡，则确认所抽的卡并破坏其中攻击力1500以下的怪兽，然后洗切对方手牌。
function c35027493.desop(e,tp,eg,ep,ev,re,r,rp)
	if ep==e:GetOwnerPlayer() then return end
	local hg=eg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if hg:GetCount()==0 then return end
	-- 将对方抽到的卡展示给效果发动者确认。
	Duel.ConfirmCards(1-ep,hg)
	local dg=hg:Filter(c35027493.filter,nil)
	-- 将对方抽到的卡中攻击力1500以下的怪兽破坏，破坏原因为效果。
	Duel.Destroy(dg,REASON_EFFECT)
	-- 破坏后洗切对方的手牌，以恢复手牌顺序。
	Duel.ShuffleHand(ep)
end
-- 回合计数效果的发动条件：仅当当前回合玩家不是效果发动者时返回真，即只在对方回合推进计数。
function c35027493.turncon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回真表示当前回合玩家不是效果发动者，该条件用于限定只在对方回合结束时进行计数。
	return Duel.GetTurnPlayer()~=tp
end
-- 每次对方回合结束时将计数加1，并设置卡片的回合计数器；当计数达到3时，重置抽卡监视效果并清除标志，使整个持续效果结束。
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
