--アブソリュート・パワーフォース
-- 效果：
-- ①：以自己场上1只「红莲魔龙」为对象才能发动。这个回合，那只自己怪兽和对方怪兽进行战斗的场合，直到伤害步骤结束时以下效果适用。
-- ●作为对象的怪兽的攻击力上升1000。
-- ●对方不能把魔法·陷阱·怪兽的效果发动。
-- ●作为对象的怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ●那次战斗发生的对对方的战斗伤害变成2倍。
function c51779204.initial_effect(c)
	-- 将卡号70902743（红莲魔龙）登记到本卡的关联卡名列表中，表示本卡效果文本中提及了这张卡。
	aux.AddCodeList(c,70902743)
	-- 创建并注册本卡的发动效果，对应原文：“①：以自己场上1只「红莲魔龙」为对象才能发动。这个回合，那只自己怪兽和对方怪兽进行战斗的场合，直到伤害步骤结束时以下效果适用。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	-- 设置效果的发动条件为只能在战斗阶段（或可以进入战斗阶段的时机）发动，限定本卡的发动时机。
	e1:SetCondition(aux.bpcon)
	e1:SetTarget(c51779204.target)
	e1:SetOperation(c51779204.activate)
	c:RegisterEffect(e1)
end
-- 定义选择对象的过滤器：对象必须是表侧表示且卡名为「红莲魔龙」（70902743），满足“以自己场上1只「红莲魔龙」为对象”的条件。
function c51779204.filter(c)
	return c:IsFaceup() and c:IsCode(70902743)
end
-- 目标处理函数：在效果发动时选择自己场上1只表侧表示的「红莲魔龙」作为效果对象，完成取对象动作。
function c51779204.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c51779204.filter(chkc) end
	-- 在发动合法性检查阶段，确认自己场上是否存在符合条件的「红莲魔龙」；若不存在，则本卡不能发动。
	if chk==0 then return Duel.IsExistingTarget(c51779204.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示选择提示框，提示玩家“请选择表侧表示的卡”，用于引导选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只表侧表示的「红莲魔龙」，并将该卡设置为当前连锁的效果对象。
	Duel.SelectTarget(tp,c51779204.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数：发动成功后，对作为对象的「红莲魔龙」赋予攻击力上升、对方不能发动效果、贯穿伤害和战斗伤害翻倍的效果，并设定这些效果持续到结束阶段或离场等重置条件。
function c51779204.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象卡（即「红莲魔龙」），用于后续为它注册附加效果。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- ●作为对象的怪兽的攻击力上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetCondition(c51779204.atkcon)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		if tc:GetFlagEffect(51779204)==0 then
			tc:RegisterFlagEffect(51779204,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
			-- ●对方不能把魔法·陷阱·怪兽的效果发动。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e2:SetCode(EFFECT_CANNOT_ACTIVATE)
			e2:SetRange(LOCATION_MZONE)
			e2:SetTargetRange(0,1)
			e2:SetCondition(c51779204.actcon)
			e2:SetValue(1)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2,true)
			-- ●作为对象的怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_PIERCE)
			e3:SetCondition(c51779204.effcon)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
			-- ●那次战斗发生的对对方的战斗伤害变成2倍。
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
			e4:SetCondition(c51779204.damcon)
			-- 将战斗伤害变更效果的值设置为“对对方造成的战斗伤害变为2倍”，即通过辅助函数生成翻倍伤害的数值。
			e4:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
			e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e4,true)
		end
	end
end
-- 定义攻击力上升效果的条件：仅在伤害步骤或伤害计算时，「红莲魔龙」实际参与战斗（作为攻击方或被攻击方），且其控制者未变更时才适用攻击力上升。
function c51779204.atkcon(e)
	-- 检查当前阶段是否处于伤害步骤或伤害计算时，以保证效果只在“直到伤害步骤结束时”的期间内适用。
	if bit.band(Duel.GetCurrentPhase(),PHASE_DAMAGE+PHASE_DAMAGE_CAL)==0 then return false end
	local c=e:GetHandler()
	-- 判断战斗双方中是否存在「红莲魔龙」（攻击方或攻击目标是该卡），且该卡拥有战斗对象，即确认该怪兽正在与对方怪兽进行战斗。
	return (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c) and c:GetBattleTarget()~=nil
		and e:GetOwnerPlayer()==e:GetHandlerPlayer()
end
-- 定义禁止对方发动效果的条件：当「红莲魔龙」正与对方怪兽进行战斗，且其控制权未转移给其他玩家时，才对对方适用“不能把魔法·陷阱·怪兽的效果发动”。
function c51779204.actcon(e)
	local c=e:GetHandler()
	-- 判断「红莲魔龙」是否是本次战斗的攻击方或被攻击方，并确认存在战斗对象，用于控制禁止对方发动效果的适用时机。
	return (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c) and c:GetBattleTarget()~=nil
		and e:GetOwnerPlayer()==e:GetHandlerPlayer()
end
-- 定义贯穿伤害效果的条件：效果所有者与当前持有者为同一玩家，即「红莲魔龙」的控制权未发生转移时，贯穿伤害效果才适用。
function c51779204.effcon(e)
	return e:GetOwnerPlayer()==e:GetHandlerPlayer()
end
-- 定义战斗伤害翻倍效果的条件：「红莲魔龙」存在战斗对象（即当前处于战斗关系中）时，将那次战斗对对方造成的战斗伤害变为2倍。
function c51779204.damcon(e)
	return e:GetHandler():GetBattleTarget()~=nil
end
