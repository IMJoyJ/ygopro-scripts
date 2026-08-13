--幻影騎士団ロスト・ヴァンブレイズ
-- 效果：
-- ①：以场上1只表侧表示怪兽为对象才能发动。直到回合结束时，那只怪兽的攻击力下降600，等级变成2星，自己的「幻影骑士团」怪兽不会被战斗破坏。那之后，这张卡变成通常怪兽（战士族·暗·2星·攻600/守0）在怪兽区域守备表示特殊召唤（不当作陷阱卡使用）。
function c36247316.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能发动。直到回合结束时，那只怪兽的攻击力下降600，等级变成2星，自己的「幻影骑士团」怪兽不会被战斗破坏。那之后，这张卡变成通常怪兽（战士族·暗·2星·攻600/守0）在怪兽区域守备表示特殊召唤（不当作陷阱卡使用）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果的发动条件：当前阶段必须是伤害步骤且尚未进行伤害计算（只能在伤害计算前发动）。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c36247316.target)
	e1:SetOperation(c36247316.activate)
	c:RegisterEffect(e1)
end
-- 定义对象筛选函数：选择场上表侧表示且等级大于0的怪兽（即可以作为对象的怪兽）。
function c36247316.filter(c)
	return c:GetLevel()>0 and c:IsFaceup()
end
-- 目标函数：进行发动时的合法性检查（自己的怪兽区有空位、能特殊召唤本卡、场上存在合法对象），并让玩家选择1只表侧表示且等级大于0的怪兽作为对象。
function c36247316.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c36247316.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己的主要怪兽区域是否有可用的空位，用于满足后续特殊召唤本卡的条件。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认玩家能将本卡作为通常怪兽（战士族·暗·2星·攻600/守0）特殊召唤，即满足特殊召唤手续的合法性。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,36247316,0x10db,TYPES_NORMAL_TRAP_MONSTER,600,0,2,RACE_WARRIOR,ATTRIBUTE_DARK)
		-- 检查双方怪兽区域是否存在至少1只符合条件的怪兽（表侧表示且等级大于0），以保证效果有可选取的对象。
		and Duel.IsExistingTarget(c36247316.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择效果的对象”的提示消息，用于引导操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从场上选择1只符合条件的表侧表示怪兽，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,c36247316.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：声明本效果将把这张卡特殊召唤，供其他卡进行效果发动判定（如星尘龙、王家长眠之谷等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数：若对象仍与效果相关且表侧表示，则令其攻击力下降600、等级变为2星，并给自己场上的“幻影骑士团”怪兽附加不会被战斗破坏的效果；随后在满足条件时中断连锁，将本卡变成通常怪兽守备表示特殊召唤。
function c36247316.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取回当前连锁中登记的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力下降600
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 等级变成2星
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_LEVEL)
		e2:SetValue(2)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 自己的「幻影骑士团」怪兽不会被战斗破坏。那之后，这张卡变成通常怪兽（战士族·暗·2星·攻600/守0）在怪兽区域守备表示特殊召唤（不当作陷阱卡使用）。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e3:SetTargetRange(LOCATION_MZONE,0)
		e3:SetTarget(c36247316.indtarget)
		e3:SetValue(1)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 将“自己的幻影骑士团怪兽不会被战斗破坏”的效果作为场地效果注册给当前玩家，持续到回合结束。
		Duel.RegisterEffect(e3,tp)
		if c:IsRelateToEffect(e)
			-- 在效果处理时再次确认玩家仍能特殊召唤本卡，避免因期间状态变化导致非法特殊召唤。
			and Duel.IsPlayerCanSpecialSummonMonster(tp,36247316,0x10db,TYPES_NORMAL_TRAP_MONSTER,600,0,2,RACE_WARRIOR,ATTRIBUTE_DARK) then
			-- 调用Duel.BreakEffect中断当前效果处理，使随后的特殊召唤作为另一次处理进行，避免错过时点。
			Duel.BreakEffect()
			c:AddMonsterAttribute(TYPE_NORMAL)
			-- 将这张卡以表侧守备表示特殊召唤到自己场上，作为通常怪兽（不当作陷阱卡使用）。
			Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_DEFENSE)
		end
	end
end
-- 定义战破免疫效果的目标筛选条件：表侧表示且属于“幻影骑士团”字段的怪兽，即只保护自己场上的幻影骑士团怪兽。
function c36247316.indtarget(e,c)
	return c:IsFaceup() and c:IsSetCard(0x10db)
end
