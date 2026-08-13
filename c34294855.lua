--カース・オブ・ヴァンパイア
-- 效果：
-- 这张卡被战斗破坏送去墓地时，支付500基本分才能发动。下个回合的准备阶段时，这张卡从墓地特殊召唤。此外，这个效果特殊召唤成功时发动。这张卡的攻击力上升500。
function c34294855.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCondition(c34294855.regcon)
	e1:SetOperation(c34294855.regop)
	c:RegisterEffect(e1)
	-- 支付500基本分才能发动。下个回合的准备阶段时，这张卡从墓地特殊召唤。
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
-- 检查效果持有者是否在墓地，确认它在被战斗破坏后确实位于墓地。
function c34294855.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 为该卡注册一个标识，记录其被战斗破坏送去墓地的事实，该标识在标准重置事件或两次结束阶段后重置，确保下个准备阶段仍存在。
function c34294855.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(34294855,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
end
-- 检查该卡是否带有被战斗破坏后设置的标识，以确认满足下个准备阶段从墓地特殊召唤的条件。
function c34294855.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(34294855)>0
end
-- 定义特殊召唤效果的发动代价：发动前检查能否支付500基本分，发动时实际支付500基本分。
function c34294855.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在费用检查阶段（chk为0）判断玩家能否支付500基本分作为代价。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 实际支付500基本分作为发动代价。
	Duel.PayLPCost(tp,500)
end
-- 特殊召唤效果的目标处理：确认效果持有者能够被特殊召唤，并登记操作信息，准备将其从墓地特殊召唤。
function c34294855.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向系统登记本次效果处理将执行特殊召唤操作，对象为效果持有者自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的实际处理：若效果持有者仍与效果关联，则将其特殊召唤到场上。
function c34294855.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤：以自身效果方式，不忽略召唤条件和苏生限制，将卡表侧表示特殊召唤到其持有者场上。
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断此卡是否是通过自身效果被特殊召唤，通过匹配召唤类型，确保只在‘诅咒之吸血鬼’自身效果特殊召唤成功时触发攻击力上升。
function c34294855.upcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 攻击力上升效果处理：若此卡仍表侧表示且与效果关联，则赋予其攻击力上升500的持续效果，并在标准重置或效果被无效时失效。
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
