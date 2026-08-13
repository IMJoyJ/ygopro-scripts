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
-- 过滤条件：表侧表示且攻击力1500以上的怪兽（用于检索对方场上可能被破坏的怪兽）。
function c22804644.tgfilter(c)
	return c:IsFaceup() and c:GetAttack()>=1500
end
-- 效果发动时无对象；进入处理前，收集对方场上符合条件的怪兽登记为将被破坏的卡，并设置破坏类操作信息。
function c22804644.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上的表侧表示且攻击力1500以上的全部怪兽，作为后续破坏信息的对象集合。
	local g=Duel.GetMatchingGroup(c22804644.tgfilter,tp,0,LOCATION_MZONE,nil)
	-- 登记本次效果为破坏效果，将对方场上符合条件的怪兽作为可能被破坏的卡，数量为g的数量，供其他卡（如星尘龙）进行连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 筛选条件：怪兽且当前攻击力在1500以上（用于破坏手卡/抽到的卡中的怪兽）。
function c22804644.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttackAbove(1500)
end
-- 效果处理：确认对方场上及手卡的所有卡，将其中攻击力1500以上的怪兽全部破坏，并洗切对方手卡；然后设置持续效果，在对方回合计的3回合内，对方每次抽卡时确认并破坏其中符合条件的怪兽，满3次后自行清除这些效果。
function c22804644.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的怪兽区域和手卡的所有卡（即对方场上的怪兽与手卡），用于确认和筛选。
	local conf=Duel.GetFieldGroup(tp,0,LOCATION_MZONE+LOCATION_HAND)
	if conf:GetCount()>0 then
		-- 向发动者展示这些卡片，对应效果中的‘全部确认’。
		Duel.ConfirmCards(tp,conf)
		local dg=conf:Filter(c22804644.filter,nil)
		-- 将筛选出的攻击力1500以上的怪兽全部破坏（包括场上和手卡中的怪兽），破坏原因为效果。
		Duel.Destroy(dg,REASON_EFFECT)
		-- 洗切对方的手卡，避免因确认和破坏导致手卡顺序信息泄露。
		Duel.ShuffleHand(1-tp)
	end
	-- 对方抽到的卡全部确认，那之内的攻击力1500以上的怪兽全部破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DRAW)
	e1:SetOperation(c22804644.desop)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,3)
	-- 将抽卡监视效果e1注册到游戏中，使其在3回合内持续生效（由tp方控制）。
	Duel.RegisterEffect(e1,tp)
	-- 用对方回合计算的3回合内
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c22804644.turncon)
	e2:SetOperation(c22804644.turnop)
	e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,3)
	-- 将对方回合结束阶段计数效果e2注册到游戏中，用于计算经过的对方回合数。
	Duel.RegisterEffect(e2,tp)
	e2:SetLabelObject(e1)
	e:GetHandler():RegisterFlagEffect(1082946,RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,3)
	c22804644[e:GetHandler()]=e2
end
-- 抽卡破坏处理：若抽卡玩家不是效果发动者，则确认对方抽到的手卡，并将其中攻击力1500以上的怪兽破坏，然后洗牌。
function c22804644.desop(e,tp,eg,ep,ev,re,r,rp)
	if ep==e:GetOwnerPlayer() then return end
	local hg=eg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if hg:GetCount()==0 then return end
	-- 向效果发动者（抽卡者的对手）展示对方抽到的卡。
	Duel.ConfirmCards(1-ep,hg)
	local dg=hg:Filter(c22804644.filter,nil)
	-- 破坏抽到的卡中攻击力1500以上的怪兽。
	Duel.Destroy(dg,REASON_EFFECT)
	-- 洗切抽卡玩家（对方）的手卡。
	Duel.ShuffleHand(ep)
end
-- 条件函数：仅在对方回合时成立，用于在对方回合结束阶段累计回合数。
function c22804644.turncon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是tp（即对方回合），确保只在对方回合结束时推进计数。
	return Duel.GetTurnPlayer()~=tp
end
-- 计数操作：每经过一次对方回合结束阶段计数器+1并更新回合计数；达到3次后，重置e1并清除标志，整体效果结束。
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
