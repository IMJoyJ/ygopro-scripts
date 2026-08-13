--冥界濁龍 ドラゴキュートス
-- 效果：
-- 暗属性调整＋调整以外的龙族怪兽1只
-- ①：这张卡不会被战斗破坏。
-- ②：这张卡战斗破坏对方怪兽送去墓地时才能发动。这张卡只再1次可以继续向对方怪兽攻击。
-- ③：自己准备阶段以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成一半，给与对方那个数值的伤害。
function c21435914.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只暗属性调整＋1只调整以外的龙族怪兽作为素材。
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
-- 判定条件：这张卡在战斗破坏对方怪兽并将其送去墓地时，且战斗对象为对方怪兽、满足再攻击条件。
function c21435914.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER) and c:IsChainAttackable(2,true) and c:IsStatus(STATUS_OPPO_BATTLE)
end
-- 处理：如果这张卡仍与战斗相关，则让这张卡可以再攻击一次，并给它附加“不能直接攻击”的效果，直到战斗阶段结束。
function c21435914.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToBattle() then return end
	-- 使这张卡可以再1次进行攻击。
	Duel.ChainAttack()
	-- ②：这张卡只再1次可以继续向对方怪兽攻击。（通过禁止直接攻击来限制只能攻击怪兽）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	c:RegisterEffect(e1)
end
-- 条件：当前回合玩家是自己，即自己的准备阶段。
function c21435914.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家为这张卡的控制者（自己准备阶段）。
	return Duel.GetTurnPlayer()==tp
end
-- 取对象效果：选择对方场上的1只表侧表示且攻击力不为0的怪兽为对象；需要存在满足条件的对象，选定后记录其攻击力并设置将造成的伤害信息。
function c21435914.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查选定的对象是否位于怪兽区、由对方控制、表侧表示且攻击力不为0。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.nzatk(chkc) end
	-- 发动时确认对方场上有满足条件的表侧表示且攻击力不为0的怪兽存在。
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，要求玩家选择1只表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上的1只表侧表示且攻击力不为0的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
	local atk=g:GetFirst():GetAttack()
	-- 设置操作信息：将给对方造成伤害，伤害数值为选择怪兽当前攻击力的一半（向上取整）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,math.ceil(atk/2))
end
-- 处理：取对象怪兽，若其仍表侧表示且与效果相关且不免疫此效果，则把其攻击力改为原攻击力的一半（最终攻击力），并给对方造成相同数值的伤害。
function c21435914.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local atk=tc:GetAttack()
		-- ③：那只怪兽的攻击力变成一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(math.ceil(atk/2))
		tc:RegisterEffect(e1)
		-- 给对方造成与对象怪兽攻击力一半数值相等的伤害。
		Duel.Damage(1-tp,math.ceil(atk/2),REASON_EFFECT)
	end
end
