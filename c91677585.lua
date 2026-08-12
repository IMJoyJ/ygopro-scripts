--かっとビング・チャレンジ
-- 效果：
-- ①：自己战斗阶段，以这个回合进行过攻击的1只超量怪兽为对象才能发动。这次战斗阶段中，那只怪兽只再1次可以攻击。这个效果让那只怪兽攻击的场合，直到伤害步骤结束时对方不能把魔法·陷阱·怪兽的效果发动。
function c91677585.initial_effect(c)
	-- ①：自己战斗阶段，以这个回合进行过攻击的1只超量怪兽为对象才能发动。这次战斗阶段中，那只怪兽只再1次可以攻击。这个效果让那只怪兽攻击的场合，直到伤害步骤结束时对方不能把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(TIMING_BATTLE_PHASE)
	e1:SetCondition(c91677585.condition)
	e1:SetTarget(c91677585.target)
	e1:SetOperation(c91677585.activate)
	c:RegisterEffect(e1)
end
-- 判定当前是否满足发动条件（自己的战斗阶段）
function c91677585.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己，且当前阶段处于战斗阶段（从开始到结束）
	return Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 过滤出自己场上表侧表示、本回合进行过1次攻击且未获得追加攻击效果的超量怪兽
function c91677585.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		and c:GetBattledGroupCount()==1 and c:GetEffectCount(EFFECT_EXTRA_ATTACK)==0
end
-- 效果发动时的对象选择与合法性检测
function c91677585.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c91677585.filter(chkc) end
	-- 判定自己场上是否存在满足条件的、可作为对象的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c91677585.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只满足条件的超量怪兽作为效果的对象
	Duel.SelectTarget(tp,c91677585.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理，使目标怪兽获得追加攻击能力，并赋予其攻击时封锁对方卡片效果发动的效果
function c91677585.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 这次战斗阶段中，那只怪兽只再1次可以攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 这个效果让那只怪兽攻击的场合，直到伤害步骤结束时对方不能把魔法·陷阱·怪兽的效果发动。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetTargetRange(0,1)
		e2:SetValue(c91677585.aclimit)
		e2:SetCondition(c91677585.actcon)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e2)
	end
end
-- 判定封锁效果的启用条件，即该怪兽正在进行攻击
function c91677585.actcon(e)
	-- 判定当前攻击的怪兽是否为该效果的宿主怪兽
	return Duel.GetAttacker()==e:GetHandler()
end
-- 限制对方不能发动魔法、陷阱以及怪兽的效果
function c91677585.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER)
end
