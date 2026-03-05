--冥界濁龍 ドラゴキュートス
-- 效果：
-- 暗属性调整＋调整以外的龙族怪兽1只
-- ①：这张卡不会被战斗破坏。
-- ②：这张卡战斗破坏对方怪兽送去墓地时才能发动。这张卡只再1次可以继续向对方怪兽攻击。
-- ③：自己准备阶段以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成一半，给与对方那个数值的伤害。
function c21435914.initial_effect(c)
	-- 添加同调召唤手续，需要1只暗属性调整和1只调整以外的龙族怪兽作为素材
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),aux.NonTuner(Card.IsRace,RACE_DRAGON),1,1)
	c:EnableReviveLimit()
	-- ①：这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽送去墓地时才能发动。这张卡只再1次可以继续向对方怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c21435914.atcon)
	e2:SetOperation(c21435914.atop)
	c:RegisterEffect(e2)
	-- ③：自己准备阶段以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成一半，给与对方那个数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1)
	e3:SetCondition(c21435914.damcon)
	e3:SetTarget(c21435914.damtg)
	e3:SetOperation(c21435914.damop)
	c:RegisterEffect(e3)
end
-- 判断是否满足效果②的发动条件：战斗中破坏的怪兽在墓地且为怪兽，自身可以进行连锁攻击，且处于与对方怪兽战斗的状态
function c21435914.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER) and c:IsChainAttackable(2,true) and c:IsStatus(STATUS_OPPO_BATTLE)
end
-- 执行效果②的操作：使自身可以再进行1次攻击，并设置不能直接攻击的效果
function c21435914.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToBattle() then return end
	-- 使攻击卡可以再进行1次攻击
	Duel.ChainAttack()
	-- 设置自身不能直接攻击的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	c:RegisterEffect(e1)
end
-- 判断是否满足效果③的发动条件：当前回合玩家为发动者
function c21435914.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家为发动者
	return Duel.GetTurnPlayer()==tp
end
-- 设置效果③的发动目标：选择对方场上1只表侧表示的怪兽作为目标
function c21435914.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断目标是否满足效果③的发动条件：目标为对方场上表侧表示的怪兽
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.nzatk(chkc) end
	-- 判断是否满足效果③的发动条件：对方场上存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示发动者选择对方场上表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示的怪兽作为目标
	local g=Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
	local atk=g:GetFirst():GetAttack()
	-- 设置效果③的处理信息：给与对方相当于目标怪兽攻击力一半的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,math.ceil(atk/2))
end
-- 执行效果③的操作：将目标怪兽的攻击力减半，并给与对方相应数值的伤害
function c21435914.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果③的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local atk=tc:GetAttack()
		-- 设置目标怪兽的攻击力为原来的一半
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(math.ceil(atk/2))
		tc:RegisterEffect(e1)
		-- 给与对方相当于目标怪兽攻击力一半的伤害
		Duel.Damage(1-tp,math.ceil(atk/2),REASON_EFFECT)
	end
end
