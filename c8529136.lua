--スクラップ・フィスト
-- 效果：
-- ①：以自己场上1只「废品战士」为对象才能发动。这个回合，那只自己怪兽和对方怪兽进行战斗的场合，以下效果适用。
-- ●对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
-- ●作为对象的怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ●对方受到的战斗伤害变成2倍。
-- ●作为对象的怪兽不会被战斗破坏。
-- ●进行战斗的对方怪兽在伤害步骤结束时破坏。
function c8529136.initial_effect(c)
	-- 注册卡片脚本中提及了「废品战士」（卡号60800381）的卡片密码
	aux.AddCodeList(c,60800381)
	-- ①：以自己场上1只「废品战士」为对象才能发动。这个回合，那只自己怪兽和对方怪兽进行战斗的场合，以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c8529136.condition)
	e1:SetTarget(c8529136.target)
	e1:SetOperation(c8529136.activate)
	c:RegisterEffect(e1)
end
-- 判定发动条件：当前阶段必须在主要阶段2之前
function c8529136.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是否在主要阶段2之前
	return Duel.GetCurrentPhase()<PHASE_MAIN2
end
-- 过滤条件：自己场上表侧表示、卡名为「废品战士」且本回合未适用过此卡效果的怪兽
function c8529136.filter(c)
	return c:IsFaceup() and c:IsCode(60800381) and c:GetFlagEffect(8529136)==0
end
-- 效果发动时的目标选择：选择自己场上1只表侧表示的「废品战士」为对象
function c8529136.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c8529136.filter(chkc) end
	-- 判定自己场上是否存在符合条件的「废品战士」作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c8529136.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的「废品战士」作为效果对象
	Duel.SelectTarget(tp,c8529136.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：为作为对象的「废品战士」注册并适用5个战斗相关的适用效果
function c8529136.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:GetFlagEffect(8529136)==0 then
			tc:RegisterFlagEffect(8529136,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
			-- ●对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetTargetRange(0,1)
			e1:SetCondition(c8529136.actcon)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1,true)
			-- ●作为对象的怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_PIERCE)
			e2:SetCondition(c8529136.effcon)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			-- ●对方受到的战斗伤害变成2倍。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
			e3:SetCondition(c8529136.damcon)
			-- 设置战斗伤害变化：使对方受到的战斗伤害变成2倍
			e3:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3,true)
			-- ●作为对象的怪兽不会被战斗破坏。
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e4:SetCondition(c8529136.effcon)
			e4:SetValue(1)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e4)
		end
		-- ●进行战斗的对方怪兽在伤害步骤结束时破坏。
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_DAMAGE_STEP_END)
		e5:SetCondition(c8529136.descon)
		e5:SetOperation(c8529136.desop)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e5,true)
	end
end
-- 判定封锁效果的发动条件：作为对象的怪兽进行战斗，且当前玩家为效果发动者
function c8529136.actcon(e)
	local c=e:GetHandler()
	-- 判定作为对象的怪兽是否正在与对方怪兽进行战斗
	return (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c) and c:GetBattleTarget()~=nil
		and e:GetOwnerPlayer()==e:GetHandlerPlayer()
end
-- 判定贯穿和战破抗性效果的适用条件：当前玩家为效果发动者
function c8529136.effcon(e)
	return e:GetOwnerPlayer()==e:GetHandlerPlayer()
end
-- 判定伤害翻倍效果的适用条件：作为对象的怪兽正在进行战斗
function c8529136.damcon(e)
	return e:GetHandler():GetBattleTarget()~=nil
end
-- 判定破坏效果的发动条件：伤害步骤结束时，与该怪兽进行战斗的对方怪兽仍存在于场上
function c8529136.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	return tc and tc:IsRelateToBattle() and e:GetOwnerPlayer()==tp
end
-- 破坏效果的处理：将进行战斗的对方怪兽破坏
function c8529136.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	-- 提示发动「废铁拳」的效果
	Duel.Hint(HINT_CARD,0,8529136)
	-- 因效果将进行战斗的对方怪兽破坏
	Duel.Destroy(tc,REASON_EFFECT)
end
