--超重忍者シノビ－A・C
-- 效果：
-- 机械族调整＋调整以外的机械族怪兽1只以上
-- 这张卡在规则上也当作「超重武者」卡使用。
-- ①：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
-- ②：自己墓地没有魔法·陷阱卡存在的场合才能发动。这张卡的原本守备力直到回合结束时变成一半，这个回合这张卡可以直接攻击。
-- ③：这张卡被效果破坏送去墓地的场合，下次的准备阶段才能发动。这张卡从墓地特殊召唤。
function c50065971.initial_effect(c)
	-- 为这张卡添加同调召唤手续，要求素材为机械族调整＋调整以外的机械族怪兽1只以上（调整以外的机械族怪兽数量可增加）。
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
	-- 这张卡被效果破坏送去墓地的场合
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(c50065971.spreg)
	c:RegisterEffect(e3)
	-- 下次的准备阶段才能发动。这张卡从墓地特殊召唤。
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
-- ②效果的发动条件：自己墓地没有魔法·陷阱卡、自身不持有直接攻击效果，并且当前处于战斗阶段或可以进入战斗阶段。
function c50065971.dircon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在魔法·陷阱卡；不存在时条件成立。
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
		-- 检查自身不持有直接攻击效果，且当前处于战斗阶段或可进入战斗阶段（aux.bpcon）。
		and not e:GetHandler():IsHasEffect(EFFECT_DIRECT_ATTACK) and aux.bpcon(e,tp,eg,ep,ev,re,r,rp)
end
-- ②效果处理：若此卡表侧表示且仍与效果关联，则将其原本守备力减半（向上取整）直到回合结束，并赋予直接攻击效果直到回合结束。
function c50065971.dirop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的原本守备力直到回合结束时变成一半
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_DEFENSE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(math.ceil(c:GetBaseDefense()/2))
		c:RegisterEffect(e1)
		-- 这个回合这张卡可以直接攻击
		local e2=Effect.CreateEffect(c)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DIRECT_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
-- 此卡送去墓地时触发：仅当因效果且被破坏才继续，并根据当前是否为准备阶段记录回合数和标记，用于③的“下次准备阶段”判断。
function c50065971.spreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if bit.band(r,REASON_EFFECT+REASON_DESTROY)~=REASON_EFFECT+REASON_DESTROY then return end
	-- 判断当前是否为准备阶段，以区分“被效果破坏送去墓地时正处于准备阶段”的情形。
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 若在准备阶段被效果破坏送去墓地，将当前回合数记录到效果标签中，使③不能在当次准备阶段立即发动，而是等到后续准备阶段。
		e:SetLabel(Duel.GetTurnCount())
		c:RegisterFlagEffect(50065971,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,2)
	else
		e:SetLabel(0)
		c:RegisterFlagEffect(50065971,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,1)
	end
end
-- ③（从墓地特殊召唤）的发动条件判定：存在标记且当前回合不是被破坏送去墓地的那一回合，即满足“下次的准备阶段才能发动”。
function c50065971.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件表达式：存储的回合数不等于当前回合数（排除当次准备阶段）且此卡带有已登记标记。
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(50065971)>0
end
-- ③发动时的目标检查：确认此卡可以被特殊召唤；若可以，则宣告特殊召唤操作并清除自身标记。
function c50065971.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次效果操作信息设置为“特殊召唤此卡”，数量为1，供其他卡牌效果联动判断。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	c:ResetFlagEffect(50065971)
end
-- ③的效果处理：若此卡仍与效果关联，则将其从墓地特殊召唤到场上。
function c50065971.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤，将此卡以表侧表示特殊召唤到其持有者（tp）的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
