--超重忍者シノビ－A・C
-- 效果：
-- 机械族调整＋调整以外的机械族怪兽1只以上
-- 这张卡在规则上也当作「超重武者」卡使用。
-- ①：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
-- ②：自己墓地没有魔法·陷阱卡存在的场合才能发动。这张卡的原本守备力直到回合结束时变成一半，这个回合这张卡可以直接攻击。
-- ③：这张卡被效果破坏送去墓地的场合，下次的准备阶段才能发动。这张卡从墓地特殊召唤。
function c50065971.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整且为机械族，以及1只以上调整以外的机械族怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),aux.NonTuner(Card.IsRace,RACE_MACHINE),1)
	c:EnableReviveLimit()
	-- 这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DEFENSE_ATTACK)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 自己墓地没有魔法·陷阱卡存在的场合才能发动。这张卡的原本守备力直到回合结束时变成一半，这个回合这张卡可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50065971,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c50065971.dircon)
	e2:SetOperation(c50065971.dirop)
	c:RegisterEffect(e2)
	-- 这张卡被效果破坏送去墓地的场合，下次的准备阶段才能发动。这张卡从墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(c50065971.spreg)
	c:RegisterEffect(e3)
	-- ③：这张卡被效果破坏送去墓地的场合，下次的准备阶段才能发动。这张卡从墓地特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(50065971,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetCountLimit(1)
	e4:SetCondition(c50065971.spcon)
	e4:SetTarget(c50065971.sptg)
	e4:SetOperation(c50065971.spop)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
-- 判断是否满足效果②的发动条件：自己墓地没有魔法·陷阱卡存在、自身未具有直接攻击效果、且当前处于可进行战斗操作的时点
function c50065971.dircon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在魔法或陷阱卡，若存在则效果②不能发动
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
		-- 检查自身是否已具有直接攻击效果，若已有则效果②不能发动；同时判断是否处于可进行战斗操作的阶段
		and not e:GetHandler():IsHasEffect(EFFECT_DIRECT_ATTACK) and aux.bpcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 执行效果②的操作：将自身原本守备力减半，并获得直接攻击能力
function c50065971.dirop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 设置自身原本守备力为当前值的一半（向下取整）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_DEFENSE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(math.ceil(c:GetBaseDefense()/2))
		c:RegisterEffect(e1)
		-- 赋予自身可以直接攻击的效果
		local e2=Effect.CreateEffect(c)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DIRECT_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
-- 记录该卡被破坏送入墓地时的阶段信息，用于后续判断是否满足特殊召唤条件
function c50065971.spreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if bit.band(r,REASON_EFFECT+REASON_DESTROY)~=REASON_EFFECT+REASON_DESTROY then return end
	-- 若当前处于准备阶段，则将当前回合数记录为标签值
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 设置标签值为当前回合数，用于标记该卡在哪个回合被破坏
		e:SetLabel(Duel.GetTurnCount())
		c:RegisterFlagEffect(50065971,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,2)
	else
		e:SetLabel(0)
		c:RegisterFlagEffect(50065971,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,1)
	end
end
-- 判断是否满足效果③的发动条件：当前回合数与标签值不同且自身具有标记效果
function c50065971.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查标签值是否不等于当前回合数，并确认自身是否拥有标记效果
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(50065971)>0
end
-- 设置效果③的目标：准备阶段时可将该卡特殊召唤
function c50065971.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示即将进行特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	c:ResetFlagEffect(50065971)
end
-- 执行效果③的操作：将该卡从墓地特殊召唤到场上
function c50065971.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡以表侧攻击形式特殊召唤到己方场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
