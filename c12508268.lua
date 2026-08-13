--フューチャー・ドライブ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「未来皇 霍普」超量怪兽为对象才能发动。这个回合，那只自己怪兽受以下效果适用。
-- ●那只怪兽可以向对方怪兽全部各作1次攻击。
-- ●那只怪兽和对方怪兽进行战斗的伤害步骤内，那只对方怪兽的效果无效化。
-- ●每次那只怪兽战斗破坏对方怪兽，给与对方那只破坏的怪兽的原本攻击力数值的伤害。
function c12508268.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只「未来皇 霍普」超量怪兽为对象才能发动。这个回合，那只自己怪兽受以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,12508268+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c12508268.target)
	e1:SetOperation(c12508268.activate)
	c:RegisterEffect(e1)
end
-- 筛选条件：表侧表示且为「未来皇 霍普」超量怪兽（字段0x207f）。
function c12508268.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x207f)
end
-- 效果发动时的目标处理：确认存在可选择的表侧「未来皇 霍普」超量怪兽；若为取对象阶段，从自己场上选择1只符合条件的怪兽作为对象。
function c12508268.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c12508268.filter(chkc) end
	-- 发动合法性检查：自己场上是否存在1只符合条件的「未来皇 霍普」超量怪兽可作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c12508268.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择提示消息：请选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只符合条件的表侧「未来皇 霍普」超量怪兽作为效果的对象。
	Duel.SelectTarget(tp,c12508268.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：为对象怪兽注册本回合适用的三个效果——可攻击对方所有怪兽、战斗时无效对方怪兽效果、战斗破坏时给与原本攻击力伤害；并标记该怪兽用于后续条件判断。
function c12508268.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果处理时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) then return end
	tc:RegisterFlagEffect(12508268,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,tc:GetFieldID())
	-- ●那只怪兽可以向对方怪兽全部各作1次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_ALL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetCondition(c12508268.atkcon)
	e1:SetOwnerPlayer(tp)
	tc:RegisterEffect(e1)
	-- ●那只怪兽和对方怪兽进行战斗的伤害步骤内，那只对方怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetLabelObject(tc)
	e2:SetCondition(c12508268.discon)
	e2:SetOperation(c12508268.disop)
	-- 将战斗开始时使对方怪兽效果无效化的持续效果注册到场上。
	Duel.RegisterEffect(e2,tp)
	-- ●每次那只怪兽战斗破坏对方怪兽，给与对方那只破坏的怪兽的原本攻击力数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetLabelObject(tc)
	e3:SetCondition(c12508268.damcon)
	e3:SetOperation(c12508268.damop)
	-- 将战斗破坏对方怪兽时给与伤害的持续效果注册到场上。
	Duel.RegisterEffect(e3,tp)
end
-- 攻击全体怪兽效果的适用条件：对象怪兽的当前控制者仍为效果发动者本人。
function c12508268.atkcon(e)
	return e:GetHandlerPlayer()==e:GetOwnerPlayer()
end
-- 无效效果处理的条件：进行战斗的怪兽仍是本效果选择的那只怪兽（通过标志编号与FieldID一致判断）。
function c12508268.discon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local fid=tc:GetFlagEffectLabel(12508268)
	return fid and fid==tc:GetFieldID()
end
-- 无效效果处理：当被选中的怪兽与对方怪兽进行战斗时，在伤害步骤开始时使对方怪兽的效果无效化（包括效果无效化和效果发动无效化）。
function c12508268.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前战斗的攻击方怪兽。
	local ac=Duel.GetAttacker()
	-- 取得当前战斗的被攻击方怪兽（即对方的战斗对象怪兽）。
	local bc=Duel.GetAttackTarget()
	local tc=e:GetLabelObject()
	if not ac or not bc then return end
	if ac~=tc then ac,bc=bc,ac end
	if ac==tc and bc:IsControler(1-tp) then
		-- ●那只怪兽和对方怪兽进行战斗的伤害步骤内，那只对方怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		bc:RegisterEffect(e1)
		-- ●那只怪兽和对方怪兽进行战斗的伤害步骤内，那只对方怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		bc:RegisterEffect(e2)
	end
end
-- 伤害效果触发条件：被选中的怪兽在战斗破坏对方怪兽时，该怪兽仍与标记对应，且被破坏的怪兽原来是对方控制的怪兽。
function c12508268.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local fid=tc:GetFlagEffectLabel(12508268)
	local bc=tc:GetBattleTarget()
	return fid and fid==tc:GetFieldID() and tc==eg:GetFirst() and tc:IsRelateToBattle() and bc and bc:IsPreviousControler(1-tp)
end
-- 伤害处理：以被战斗破坏的对方怪兽的原本攻击力作为伤害值，若大于0则给与对方玩家效果伤害。
function c12508268.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local bc=tc:GetBattleTarget()
	if not bc then return end
	local dam=math.max(bc:GetBaseAttack(),0)
	if dam>0 then
		-- 向双方展示该卡动画，提示伤害来自本卡效果。
		Duel.Hint(HINT_CARD,0,12508268)
		-- 给与对方玩家等同于原本攻击力数值的效果伤害。
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end
