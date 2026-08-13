--闇味鍋パーティー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己战斗阶段开始时，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只自己怪兽的攻击对象由对方选择，那只自己怪兽的攻击力只在和对方怪兽进行战斗的伤害计算时上升自身的原本攻击力数值。
function c24181936.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己战斗阶段开始时，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只自己怪兽的攻击对象由对方选择，那只自己怪兽的攻击力只在和对方怪兽进行战斗的伤害计算时上升自身的原本攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24181936,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,24181936)
	e2:SetCondition(c24181936.atkcon1)
	e2:SetTarget(c24181936.atktg1)
	e2:SetOperation(c24181936.atkop1)
	c:RegisterEffect(e2)
end
-- 发动条件：仅在当前回合玩家为效果的控制者（即自己的战斗阶段）时才能发动。
function c24181936.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果控制者，确保只有在自己回合的战斗阶段开始时满足条件。
	return Duel.GetTurnPlayer()==tp
end
-- 目标选择函数：在发动时选定自己场上1只表侧表示怪兽为对象；若已有选择则校验其合法性，若未选择则检查是否存在合法对象，并提示玩家选择一个对象。
function c24181936.atktg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 效果发动时检查自己场上是否存在至少1只表侧表示怪兽可作为对象；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送“请选择效果的对象”的选择提示，用于目标选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上的表侧表示怪兽中选择1只作为效果对象，并将其设定为该连锁的目标。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：取回对象怪兽，若对象仍与效果相关且尚未附加本效果标记，则给对象注册标记，并赋予两个持续效果（攻击对象由对方选择、伤害计算时攻击力上升）。
function c24181936.atkop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:GetFlagEffect(24181936)==0 then
			tc:RegisterFlagEffect(24181936,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
			-- 这个回合，那只自己怪兽的攻击对象由对方选择。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_PATRICIAN_OF_DARKNESS)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetCondition(c24181936.effcon)
			e1:SetLabelObject(tc)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 将“攻击对象由对方选择”的效果注册到场上，使该效果在该回合内对相应怪兽适用。
			Duel.RegisterEffect(e1,tp)
			-- 那只自己怪兽的攻击力只在和对方怪兽进行战斗的伤害计算时上升自身的原本攻击力数值。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetTargetRange(LOCATION_MZONE,0)
			e2:SetCondition(c24181936.atkcon2)
			e2:SetTarget(c24181936.atktg)
			e2:SetValue(c24181936.atkval)
			e2:SetLabelObject(tc)
			e2:SetReset(RESET_PHASE+PHASE_END)
			-- 将“伤害计算时攻击力上升原本攻击力数值”的效果注册到场上，使该效果在该回合内对相应怪兽适用。
			Duel.RegisterEffect(e2,tp)
		end
	end
end
-- 条件函数：被标记的怪兽正在进行攻击时，“攻击对象由对方选择”的效果才适用。
function c24181936.effcon(e)
	local tc=e:GetLabelObject()
	-- 确认该怪兽仍带有本回合的效果标记，且当前攻击者正是该怪兽；满足时攻击对象改为由对方选择。
	return tc:GetFlagEffect(24181936)~=0 and Duel.GetAttacker()==tc
end
-- 攻击力上升效果的适用条件：当前处于伤害计算阶段，被标记怪兽作为攻击者，且存在战斗对象。
function c24181936.atkcon2(e)
	local tc=e:GetLabelObject()
	-- 判断当前是否为伤害计算阶段（仅在此时才可能上升攻击力）。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL
		-- 并确认该怪兽仍带有标记、当前攻击者正是该怪兽且存在攻击对象，三项同时满足才上升攻击力。
		and tc:GetFlagEffect(24181936)~=0 and Duel.GetAttacker()==tc and Duel.GetAttackTarget()~=nil
end
-- 指定攻击力上升效果只适用于当前攻击者（即被标记的怪兽）。
function c24181936.atktg(e,c)
	-- 仅当卡片c为当前攻击者时才给予攻击力上升，以此限定效果作用对象。
	return c==Duel.GetAttacker()
end
-- 返回被标记怪兽的原本攻击力作为攻击力上升的数值，实现‘上升自身的原本攻击力数值’。
function c24181936.atkval(e,c)
	return c:GetBaseAttack()
end
