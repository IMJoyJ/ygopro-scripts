--幻影騎士団ロスト・ヴァンブレイズ
-- 效果：
-- ①：以场上1只表侧表示怪兽为对象才能发动。直到回合结束时，那只怪兽的攻击力下降600，等级变成2星，自己的「幻影骑士团」怪兽不会被战斗破坏。那之后，这张卡变成通常怪兽（战士族·暗·2星·攻600/守0）在怪兽区域守备表示特殊召唤（不当作陷阱卡使用）。
function c36247316.initial_effect(c)
	-- 效果原文内容：①：以场上1只表侧表示怪兽为对象才能发动。直到回合结束时，那只怪兽的攻击力下降600，等级变成2星，自己的「幻影骑士团」怪兽不会被战斗破坏。那之后，这张卡变成通常怪兽（战士族·暗·2星·攻600/守0）在怪兽区域守备表示特殊召唤（不当作陷阱卡使用）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 效果作用：限制效果只能在伤害计算前的时机发动或适用。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c36247316.target)
	e1:SetOperation(c36247316.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：定义可用于选择目标的怪兽过滤条件，即等级大于0且表侧表示。
function c36247316.filter(c)
	return c:GetLevel()>0 and c:IsFaceup()
end
-- 效果作用：判断是否满足发动条件，包括是否已支付费用、场上是否有空位、是否可以特殊召唤此卡以及场上是否存在符合条件的目标怪兽。
function c36247316.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c36247316.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 效果作用：检查玩家场上是否有足够的怪兽区域用于特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：检查玩家是否可以以指定参数特殊召唤此卡。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,36247316,0x10db,TYPES_NORMAL_TRAP_MONSTER,600,0,2,RACE_WARRIOR,ATTRIBUTE_DARK)
		-- 效果作用：检查场上是否存在符合条件的目标怪兽。
		and Duel.IsExistingTarget(c36247316.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 效果作用：提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 效果作用：选择一个符合条件的场上怪兽作为效果对象。
	Duel.SelectTarget(tp,c36247316.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 效果作用：设置连锁操作信息，表明将要特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果作用：处理效果的主要逻辑，包括对目标怪兽进行攻击力下降、等级变更、战斗不破坏效果，并在满足条件下将此卡特殊召唤为通常怪兽。
function c36247316.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果作用：获取当前连锁中选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 效果原文内容：直到回合结束时，那只怪兽的攻击力下降600。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 效果原文内容：直到回合结束时，那只怪兽的等级变成2星。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_LEVEL)
		e2:SetValue(2)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 效果原文内容：自己的「幻影骑士团」怪兽不会被战斗破坏。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e3:SetTargetRange(LOCATION_MZONE,0)
		e3:SetTarget(c36247316.indtarget)
		e3:SetValue(1)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 效果作用：将效果注册到场上。
		Duel.RegisterEffect(e3,tp)
		if c:IsRelateToEffect(e)
			-- 效果作用：检查玩家是否可以特殊召唤此卡。
			and Duel.IsPlayerCanSpecialSummonMonster(tp,36247316,0x10db,TYPES_NORMAL_TRAP_MONSTER,600,0,2,RACE_WARRIOR,ATTRIBUTE_DARK) then
			-- 效果作用：中断当前效果处理，使后续处理视为不同时进行。
			Duel.BreakEffect()
			c:AddMonsterAttribute(TYPE_NORMAL)
			-- 效果作用：将此卡以守备表示形式特殊召唤到场上。
			Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_DEFENSE)
		end
	end
end
-- 效果作用：定义战斗不破坏效果的目标条件，即自己场上的「幻影骑士团」怪兽。
function c36247316.indtarget(e,c)
	return c:IsFaceup() and c:IsSetCard(0x10db)
end
