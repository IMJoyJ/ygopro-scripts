--カース・オブ・ヴァンパイア
-- 效果：
-- 这张卡被战斗破坏送去墓地时，支付500基本分才能发动。下个回合的准备阶段时，这张卡从墓地特殊召唤。此外，这个效果特殊召唤成功时发动。这张卡的攻击力上升500。
function c34294855.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，支付500基本分才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34294855,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c34294855.regcon)
	e1:SetCost(c34294855.spcost)
	e1:SetOperation(c34294855.regop)
	c:RegisterEffect(e1)
	-- 下个回合的准备阶段时，这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetCondition(c34294855.spcon)
	e2:SetOperation(c34294855.spop)
	c:RegisterEffect(e2)
	-- 此外，这个效果特殊召唤成功时发动。这张卡的攻击力上升500。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34294855,1))  --"攻击上升"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c34294855.upcon)
	e3:SetOperation(c34294855.upop)
	c:RegisterEffect(e3)
end
-- 战破诱发条件：检查这张卡当前确实位于墓地
function c34294855.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 战破诱发处理：为墓地中的这张卡注册持续到下回合结束阶段的苏生标记
function c34294855.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:RegisterFlagEffect(34294855,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
	end
end
-- 准备阶段苏生条件：检查墓地中的这张卡是否带有战破预约苏生标记
function c34294855.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(34294855)>0
end
-- 发动代价处理：检查并支付500点基本分
function c34294855.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否足够支付500点基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 让玩家支付500点基本分作为发动代价
	Duel.PayLPCost(tp,500)
end
-- 准备阶段苏生处理：清除苏生标记并以自身效果方式将这张卡从墓地特殊召唤
function c34294855.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:ResetFlagEffect(34294855)
	-- 以自身特殊召唤标记将这张卡表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
end
-- 加攻效果触发条件：检查这张卡是否通过自身的特殊召唤效果登场
function c34294855.upcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 加攻效果处理：若这张卡仍在场上表侧表示且与效果有联系，则使其攻击力永久上升500
function c34294855.upop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
