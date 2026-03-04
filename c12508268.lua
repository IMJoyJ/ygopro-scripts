--フューチャー・ドライブ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「未来皇 霍普」超量怪兽为对象才能发动。这个回合，那只自己怪兽受以下效果适用。
-- ●那只怪兽可以向对方怪兽全部各作1次攻击。
-- ●那只怪兽和对方怪兽进行战斗的伤害步骤内，那只对方怪兽的效果无效化。
-- ●每次那只怪兽战斗破坏对方怪兽，给与对方那只破坏的怪兽的原本攻击力数值的伤害。
function c12508268.initial_effect(c)
	-- ①：以自己场上1只「未来皇 霍普」超量怪兽为对象才能发动。这个回合，那只自己怪兽受以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,12508268+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c12508268.target)
	e1:SetOperation(c12508268.activate)
	c:RegisterEffect(e1)
end
-- 过滤满足条件的「未来皇 霍普」超量怪兽
function c12508268.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x207f)
end
-- 选择目标：自己场上1只「未来皇 霍普」超量怪兽
function c12508268.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c12508268.filter(chkc) end
	-- 检查是否有满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c12508268.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c12508268.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 发动效果时执行的操作
function c12508268.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
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
	-- 注册战斗开始时的效果
	Duel.RegisterEffect(e2,tp)
	-- ●每次那只怪兽战斗破坏对方怪兽，给与对方那只破坏的怪兽的原本攻击力数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetLabelObject(tc)
	e3:SetCondition(c12508268.damcon)
	e3:SetOperation(c12508268.damop)
	-- 注册战斗破坏时的效果
	Duel.RegisterEffect(e3,tp)
end
-- 攻击全部怪兽的条件判断
function c12508268.atkcon(e)
	return e:GetHandlerPlayer()==e:GetOwnerPlayer()
end
-- 无效化对方怪兽效果的条件判断
function c12508268.discon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local fid=tc:GetFlagEffectLabel(12508268)
	return fid and fid==tc:GetFieldID()
end
-- 无效化对方怪兽效果的操作
function c12508268.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前攻击怪兽
	local ac=Duel.GetAttacker()
	-- 获取当前攻击目标
	local bc=Duel.GetAttackTarget()
	local tc=e:GetLabelObject()
	if not ac or not bc then return end
	if ac~=tc then ac,bc=bc,ac end
	if ac==tc and bc:IsControler(1-tp) then
		-- 使对方怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		bc:RegisterEffect(e1)
		-- 使对方怪兽效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		bc:RegisterEffect(e2)
	end
end
-- 造成伤害的条件判断
function c12508268.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local fid=tc:GetFlagEffectLabel(12508268)
	local bc=tc:GetBattleTarget()
	return fid and fid==tc:GetFieldID() and tc==eg:GetFirst() and tc:IsRelateToBattle() and bc and bc:IsPreviousControler(1-tp)
end
-- 造成伤害的操作
function c12508268.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local bc=tc:GetBattleTarget()
	if not bc then return end
	local dam=math.max(bc:GetBaseAttack(),0)
	if dam>0 then
		-- 显示发动动画提示
		Duel.Hint(HINT_CARD,0,12508268)
		-- 对对方造成伤害
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end
