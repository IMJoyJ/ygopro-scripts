--メタモル・クレイ・フォートレス
-- 效果：
-- ①：以自己场上1只4星以上的怪兽为对象才能发动。这张卡发动后变成效果怪兽（岩石族·地·4星·攻/守1000）在怪兽区域特殊召唤。那之后，作为对象的表侧表示怪兽当作装备卡使用给这张卡装备。这张卡也当作陷阱卡使用。
-- ②：这张卡的效果特殊召唤的这张卡的攻击力·守备力上升这张卡的效果装备的怪兽的攻击力数值，这张卡在攻击的伤害步骤结束时变成守备表示。
function c43959432.initial_effect(c)
	-- ①：以自己场上1只4星以上的怪兽为对象才能发动。这张卡发动后变成效果怪兽（岩石族·地·4星·攻/守1000）在怪兽区域特殊召唤。那之后，作为对象的表侧表示怪兽当作装备卡使用给这张卡装备。这张卡也当作陷阱卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c43959432.target)
	e1:SetOperation(c43959432.activate)
	c:RegisterEffect(e1)
	-- ②中：这张卡在攻击的伤害步骤结束时变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetCondition(c43959432.poscon)
	e2:SetOperation(c43959432.posop)
	c:RegisterEffect(e2)
	-- ②中攻击力上升部分：这张卡的效果特殊召唤的这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c43959432.atkcon)
	e3:SetValue(c43959432.atkval)
	e3:SetLabelObject(e1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
end
-- 对象筛选条件：选择自己场上表侧表示且等级为4星以上的怪兽。
function c43959432.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(4)
end
-- 发动条件与取对象：确认有可特殊召唤的空位、存在满足条件的对象且自己能特殊召唤此卡；选择1只符合条件的对象。
function c43959432.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c43959432.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己主要怪兽区域是否有可用的空格。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在1张以上表侧表示且4星以上的对象候选。
		and Duel.IsExistingTarget(c43959432.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 确认自己能否将这张卡以岩石族·地·4星·攻/守1000的效果怪兽形式特殊召唤到场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,43959432,0,TYPES_EFFECT_TRAP_MONSTER,1000,1000,4,RACE_ROCK,ATTRIBUTE_EARTH) end
	-- 向玩家显示选择提示：请选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示且4星以上的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c43959432.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 登记特殊召唤处理信息，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡特殊召唤为效果怪兽，成功后将对象怪兽作为装备卡装备给这张卡。
function c43959432.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次确认能否特殊召唤此卡，若不能则终止处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,43959432,0,TYPES_EFFECT_TRAP_MONSTER,1000,1000,4,RACE_ROCK,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将这张卡以自身效果特殊召唤为效果怪兽；若特殊召唤失败则效果不继续处理。
	if Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)==0 then return end
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 中断当前效果处理，使后续装备行为成为独立处理，避免错过时点。
		Duel.BreakEffect()
		-- 将对象怪兽作为装备卡装备给这张卡；若装备失败则终止后续处理。
		if not Duel.Equip(tp,tc,c,false) then return end
		-- ①中‘作为对象的表侧表示怪兽当作装备卡使用给这张卡装备’；②：这张卡的效果特殊召唤的这张卡的攻击力·守备力上升这张卡的效果装备的怪兽的攻击力数值，这张卡在攻击的伤害步骤结束时变成守备表示。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e4:SetCode(EFFECT_EQUIP_LIMIT)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		e4:SetValue(c43959432.eqlimit)
		tc:RegisterEffect(e4,true)
		e:SetLabelObject(tc)
	end
end
-- 变守备表示效果的发动条件：攻击伤害步骤结束时，且该卡是由自身效果特殊召唤、作为攻击怪兽参与该次战斗。
function c43959432.poscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定三项条件：召唤类型为自身效果特殊召唤、是当前攻击怪兽、且仍与战斗相关。
	return c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF and c==Duel.GetAttacker() and c:IsRelateToBattle()
end
-- 效果处理：将自身从攻击表示变为守备表示。
function c43959432.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将这张卡的表示形式改为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 攻击力上升效果的发动条件：这张卡是由自身效果特殊召唤。
function c43959432.atkcon(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 计算攻击力上升的数值：取装备卡怪兽的当前攻击力，若小于0则视为0。
function c43959432.atkval(e,c)
	local tc=e:GetLabelObject():GetLabelObject()
	if not tc or tc:GetEquipTarget()~=c then return 0 end
	local atk=tc:GetAttack()
	if atk<0 then atk=0 end
	return atk
end
-- 装备限制条件：这张装备卡只能装备给原持有者（即这张卡自身）。
function c43959432.eqlimit(e,c)
	return e:GetOwner()==c
end
