--デス・ウイルス・ドラゴン
-- 效果：
-- 这张卡在用「克里底亚之牙」的效果把自己的手卡·场上的「死之卡组破坏病毒」送去墓地的场合才能特殊召唤。
-- ①：这张卡特殊召唤成功的场合发动。对方场上的怪兽，对方手卡，用对方回合计算的3回合内对方抽到的卡全部确认，那之内的攻击力1500以上的怪兽全部破坏。
function c22804644.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡在用「克里底亚之牙」的效果把自己的手卡·场上的「死之卡组破坏病毒」送去墓地的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤成功的场合发动。对方场上的怪兽，对方手卡，用对方回合计算的3回合内对方抽到的卡全部确认，那之内的攻击力1500以上的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c22804644.target)
	e2:SetOperation(c22804644.operation)
	c:RegisterEffect(e2)
end
c22804644.material_trap=57728570
-- 过滤函数，返回满足条件的怪兽（攻击力大于等于1500且表侧表示）
function c22804644.tgfilter(c)
	return c:IsFaceup() and c:GetAttack()>=1500
end
-- 设置效果处理时要破坏的怪兽组，用于确认对方场上和手牌中的攻击力1500以上的怪兽
function c22804644.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上和手牌中所有满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c22804644.tgfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置当前处理的连锁的操作信息，包括要破坏的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 过滤函数，返回满足条件的怪兽（怪兽类型且攻击力大于等于1500）
function c22804644.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttackAbove(1500)
end
-- 效果处理函数，确认对方场上和手牌中的卡，并破坏其中攻击力1500以上的怪兽，然后洗切对方手牌，并注册持续效果以处理后续抽卡
function c22804644.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上和手牌中的所有卡
	local conf=Duel.GetFieldGroup(tp,0,LOCATION_MZONE+LOCATION_HAND)
	if conf:GetCount()>0 then
		-- 给玩家确认指定的卡组
		Duel.ConfirmCards(tp,conf)
		local dg=conf:Filter(c22804644.filter,nil)
		-- 以效果原因破坏指定的卡
		Duel.Destroy(dg,REASON_EFFECT)
		-- 手动洗切玩家的手牌
		Duel.ShuffleHand(1-tp)
	end
	-- 注册一个持续效果，用于处理对方抽卡时的破坏效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DRAW)
	e1:SetOperation(c22804644.desop)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,3)
	-- 将效果e1注册到全局环境
	Duel.RegisterEffect(e1,tp)
	-- 注册一个持续效果，用于处理对方回合结束时的计数器操作
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c22804644.turncon)
	e2:SetOperation(c22804644.turnop)
	e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,3)
	-- 将效果e2注册到全局环境
	Duel.RegisterEffect(e2,tp)
	e2:SetLabelObject(e1)
	e:GetHandler():RegisterFlagEffect(1082946,RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,3)
	c22804644[e:GetHandler()]=e2
end
-- 处理对方抽卡时的破坏效果，确认对方抽到的手牌并破坏其中攻击力1500以上的怪兽
function c22804644.desop(e,tp,eg,ep,ev,re,r,rp)
	if ep==e:GetOwnerPlayer() then return end
	local hg=eg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if hg:GetCount()==0 then return end
	-- 给对方确认指定的卡组
	Duel.ConfirmCards(1-ep,hg)
	local dg=hg:Filter(c22804644.filter,nil)
	-- 以效果原因破坏指定的卡
	Duel.Destroy(dg,REASON_EFFECT)
	-- 手动洗切指定玩家的手牌
	Duel.ShuffleHand(ep)
end
-- 判断当前回合玩家是否不是效果拥有者
function c22804644.turncon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否不是效果拥有者
	return Duel.GetTurnPlayer()~=tp
end
-- 处理对方回合结束时的计数器操作，当计数达到3时重置效果并清除标记
function c22804644.turnop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	ct=ct+1
	e:SetLabel(ct)
	e:GetHandler():SetTurnCounter(ct)
	if ct==3 then
		e:GetLabelObject():Reset()
		e:GetOwner():ResetFlagEffect(1082946)
	end
end
