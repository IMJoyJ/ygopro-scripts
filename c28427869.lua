--スモーク・モスキート
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方怪兽的攻击要让自己受到战斗伤害的伤害计算时才能发动。这张卡从手卡特殊召唤，那次战斗发生的对自己的战斗伤害变成一半，那次伤害步骤结束后战斗阶段结束。
-- ②：以自己场上1只表侧表示怪兽为对象才能发动。这张卡的等级直到回合结束时变成和那只怪兽相同。
function c28427869.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：对方怪兽的攻击要让自己受到战斗伤害的伤害计算时才能发动。这张卡从手卡特殊召唤，那次战斗发生的对自己的战斗伤害变成一半，那次伤害步骤结束后战斗阶段结束。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,28427869)
	e1:SetCondition(c28427869.condition)
	e1:SetTarget(c28427869.sptg)
	e1:SetOperation(c28427869.spop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只表侧表示怪兽为对象才能发动。这张卡的等级直到回合结束时变成和那只怪兽相同。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,28427870)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c28427869.lvtg)
	e2:SetOperation(c28427869.lvop)
	c:RegisterEffect(e2)
end
-- 定义①效果的发动条件：检查本次伤害计算时攻击怪兽是否为对方怪兽，只有对方怪兽攻击时条件成立。
function c28427869.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击怪兽的控制者是否为对方玩家（1-tp），若是则条件成立。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- ①效果的发动合法性检查与目标设置：确认己方未受到‘不会受到战斗伤害’效果影响、本次战斗伤害大于0、己方主怪兽区有空位且手牌此卡可以特殊召唤；满足则允许发动并登记特殊召唤操作。
function c28427869.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认己方没有被‘不受战斗伤害’效果影响，且本次战斗对己方造成的伤害数值大于0。
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,EFFECT_AVOID_BATTLE_DAMAGE) and Duel.GetBattleDamage(tp)>0
		-- 确认己方主要怪兽区存在空位，且手牌的这张卡能够被特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的操作信息：类别为特殊召唤，对象为这张卡，数量为1，用于连锁处理中的效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的解决：若这张卡仍与效果关联，则将其从手牌特殊召唤；成功后，给己方附加‘本次战斗伤害减半’的效果，并注册‘伤害步骤结束时战斗阶段结束’的触发效果。
function c28427869.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤：将这张卡以表侧表示特殊召唤到自己场上；若特殊召唤成功（返回值不为0），才继续后续处理。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 那次战斗发生的对自己的战斗伤害变成一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetValue(HALF_DAMAGE)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		-- 将‘对自己玩家的战斗伤害变为一半’的效果注册给己方玩家，该效果持续到本次伤害步骤结束时，从而使本次战斗伤害减半。
		Duel.RegisterEffect(e1,tp)
		-- 那次伤害步骤结束后战斗阶段结束。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_DAMAGE_STEP_END)
		e2:SetOperation(c28427869.skipop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		-- 将‘伤害步骤结束时跳过战斗阶段’的触发效果注册到当前决斗中，并设定在本次伤害步骤结束后自动触发并重置。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 定义伤害步骤结束时要执行的操作：直接跳过当前回合玩家的战斗阶段，从而实现‘战斗阶段结束’。
function c28427869.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 跳过当前回合玩家的战斗阶段，使战斗阶段结束；该跳过效果在战斗步骤结束时重置。
	Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
end
-- 定义②效果可选对象的筛选条件：怪兽需表侧表示、等级大于0，且等级不等于这张卡当前的等级。
function c28427869.lvfilter(c,lv)
	return c:GetLevel()>0 and c:IsFaceup() and not c:IsLevel(lv)
end
-- ②效果的发动条件与取对象处理：确认自己场上有满足条件的表侧表示怪兽，若发动则提示玩家选择1只表侧表示、等级大于0且等级不同的怪兽作为对象。
function c28427869.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lv=e:GetHandler():GetLevel()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c28427869.lvfilter(chkc,lv) end
	-- 发动合法性检查：确认自己场上存在至少1只满足条件（表侧表示、等级大于0且等级不同）的怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c28427869.lvfilter,tp,LOCATION_MZONE,0,1,nil,lv) end
	-- 给发动玩家显示‘请选择效果的对象’的提示信息，用于选择对象时的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让发动玩家选择1只符合条件的自己场上表侧表示怪兽，并将其登记为这个效果的对象。
	Duel.SelectTarget(tp,c28427869.lvfilter,tp,LOCATION_MZONE,0,1,1,nil,lv)
end
-- ②效果处理：在对象怪兽和这张卡都仍然表侧表示且与效果关联时，给这张卡赋予等级变为对象怪兽等级的效果，该效果持续到回合结束。
function c28427869.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果发动时选择的对象怪兽（当前连锁的第一个对象）。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的等级直到回合结束时变成和那只怪兽相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
