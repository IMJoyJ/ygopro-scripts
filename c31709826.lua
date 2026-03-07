--リバイバルスライム
-- 效果：
-- ①：这张卡被战斗破坏送去墓地时，支付1000基本分才能发动。下次的自己准备阶段这张卡从墓地守备表示特殊召唤。
function c31709826.initial_effect(c)
	-- 效果原文：①：这张卡被战斗破坏送去墓地时，支付1000基本分才能发动。下次的自己准备阶段这张卡从墓地守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31709826,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c31709826.spcon)
	e1:SetCost(c31709826.spcost)
	e1:SetOperation(c31709826.spop)
	c:RegisterEffect(e1)
	-- 效果原文：①：这张卡被战斗破坏送去墓地时，支付1000基本分才能发动。下次的自己准备阶段这张卡从墓地守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetCondition(c31709826.spcon2)
	e2:SetOperation(c31709826.spop2)
	c:RegisterEffect(e2)
end
-- 规则层面：判断此卡是否因战斗破坏而进入墓地
function c31709826.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 规则层面：支付1000基本分作为发动cost
function c31709826.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 规则层面：支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 规则层面：为该卡注册一个标记，用于在下次准备阶段触发特殊召唤
function c31709826.spop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(31709826,RESET_EVENT+RESETS_STANDARD,0,0)
end
-- 规则层面：判断是否为自己的准备阶段且该卡有标记
function c31709826.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断是否为当前回合玩家且该卡有标记
	return tp==Duel.GetTurnPlayer() and e:GetHandler():GetFlagEffect(31709826)>0
end
-- 规则层面：重置标记并特殊召唤该卡到场上
function c31709826.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:ResetFlagEffect(31709826)
	-- 规则层面：将该卡从墓地守备表示特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
