--マジェスペクター・ソニック
-- 效果：
-- ①：以自己场上1只「威风妖怪」怪兽为对象才能发动。那只怪兽直到回合结束时攻击力·守备力变成2倍，给与对方的战斗伤害变成一半。
function c13611090.initial_effect(c)
	-- 以自己场上1只「威风妖怪」怪兽为对象才能发动。那只怪兽直到回合结束时攻击力·守备力变成2倍，给与对方的战斗伤害变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c13611090.target)
	e1:SetOperation(c13611090.activate)
	c:RegisterEffect(e1)
end
-- 筛选场上表侧表示的「威风妖怪」怪兽。
function c13611090.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xd0)
end
-- 选择对象怪兽的处理函数。
function c13611090.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c13611090.filter(chkc) end
	-- 判断是否满足选择对象的条件。
	if chk==0 then return Duel.IsExistingTarget(c13611090.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择符合条件的1只怪兽作为对象。
	Duel.SelectTarget(tp,c13611090.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果发动时的处理函数。
function c13611090.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将对象怪兽的攻击力变成2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc:GetAttack()*2)
		tc:RegisterEffect(e1)
		-- 将对象怪兽的守备力变成2倍。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(tc:GetDefense()*2)
		tc:RegisterEffect(e2)
		-- 给与对方的战斗伤害变成一半。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		-- 设置战斗伤害为原伤害的一半。
		e3:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
		tc:RegisterEffect(e3)
	end
end
