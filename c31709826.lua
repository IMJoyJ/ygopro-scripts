--リバイバルスライム
-- 效果：
-- ①：这张卡被战斗破坏送去墓地时，支付1000基本分才能发动。下次的自己准备阶段这张卡从墓地守备表示特殊召唤。
function c31709826.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地时，支付1000基本分才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31709826,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c31709826.spcon)
	e1:SetCost(c31709826.spcost)
	e1:SetOperation(c31709826.spop)
	c:RegisterEffect(e1)
	-- 下次的自己准备阶段这张卡从墓地守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetCondition(c31709826.spcon2)
	e2:SetOperation(c31709826.spop2)
	c:RegisterEffect(e2)
end
-- 检查诱发效果的发动条件：这张卡当前位于墓地，并且被战斗破坏送去墓地。
function c31709826.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 设置并处理发动代价：需要支付1000基本分才能发动。
function c31709826.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价合法性检查阶段，确认玩家是否能够支付1000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际支付1000基本分作为发动代价。
	Duel.PayLPCost(tp,1000)
end
-- 效果处理时，给这张卡登记一个标识，用于记录“已支付代价发动，准备阶段将要特殊召唤”。
function c31709826.spop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(31709826,RESET_EVENT+RESETS_STANDARD,0,0)
end
-- 第二个效果的发动条件：当前是这张卡持有者的准备阶段，并且这张卡拥有已发动效果的特殊召唤标识。
function c31709826.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足“自己的准备阶段”且这张卡已被登记为需要特殊召唤。
	return tp==Duel.GetTurnPlayer() and e:GetHandler():GetFlagEffect(31709826)>0
end
-- 特殊召唤处理：清除特殊召唤标识，将这张卡从墓地以表侧守备表示特殊召唤。
function c31709826.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:ResetFlagEffect(31709826)
	-- 将这张卡以表侧守备表示特殊召唤到其持有者场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
