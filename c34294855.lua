--カース・オブ・ヴァンパイア
-- 效果：
-- 这张卡被战斗破坏送去墓地时，支付500基本分才能发动。下个回合的准备阶段时，这张卡从墓地特殊召唤。此外，这个效果特殊召唤成功时发动。这张卡的攻击力上升500。
function c34294855.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，支付500基本分才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCondition(c34294855.regcon)
	e1:SetOperation(c34294855.regop)
	c:RegisterEffect(e1)
	-- 下个回合的准备阶段时，这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34294855,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetCondition(c34294855.spcon)
	e2:SetCost(c34294855.spcost)
	e2:SetTarget(c34294855.sptg)
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
-- 效果触发条件：卡片位于墓地
function c34294855.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 注册标记：为卡片设置一个标记，用于记录该效果是否已触发
function c34294855.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(34294855,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
end
-- 特殊召唤条件：检查是否有标记
function c34294855.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(34294855)>0
end
-- 支付LP：检查并支付500基本分
function c34294855.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 支付LP检查：检查是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 支付LP操作：支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 设置特殊召唤目标：设定特殊召唤的卡和类别
function c34294855.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：设置特殊召唤的类别和目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤执行：将卡片特殊召唤到场上
function c34294855.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤：将卡片以正面表示形式特殊召唤
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
end
-- 攻击力上升条件：判断是否为特殊召唤且为自身召唤
function c34294855.upcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 攻击力上升效果：使卡片攻击力上升500
function c34294855.upop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 攻击力增加效果：设置攻击力增加500的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
