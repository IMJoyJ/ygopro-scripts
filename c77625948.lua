--サイバー・ダーク・エッジ
-- 效果：
-- ①：这张卡召唤成功的场合，以自己墓地1只3星以下的龙族怪兽为对象发动。那只龙族怪兽当作装备卡使用给这张卡装备。
-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值。
-- ③：这张卡可以直接攻击。那个场合，这张卡的攻击力只在那次伤害计算时变成一半。
-- ④：这张卡被战斗破坏的场合，作为代替把这张卡的效果装备的怪兽破坏。
function c77625948.initial_effect(c)
	-- ①：这张卡召唤成功的场合，以自己墓地1只3星以下的龙族怪兽为对象发动。那只龙族怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77625948,0))  --"装备"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c77625948.eqtg)
	e1:SetOperation(c77625948.eqop)
	c:RegisterEffect(e1)
	-- ③：这张卡可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
	-- 那个场合，这张卡的攻击力只在那次伤害计算时变成一半。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SET_ATTACK_FINAL)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c77625948.atkcon)
	e3:SetValue(c77625948.atkval)
	c:RegisterEffect(e3)
end
-- 过滤自己墓地3星以下的龙族怪兽
function c77625948.filter(c)
	return c:IsLevelBelow(3) and c:IsRace(RACE_DRAGON) and not c:IsForbidden()
end
-- 召唤成功时装备效果的发动准备与目标选择
function c77625948.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检测【电子暗黑世界】(64753988)的效果是否生效中。若在生效中，「电子暗黑」怪兽的召唤·特殊召唤成功时发动的自身的效果让自己从自己墓地把怪兽装备的场合，也能作为代替从对方墓地装备。
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and (chkc:IsControler(tp) or Duel.IsPlayerAffectedByEffect(tp,64753988)) and c77625948.filter(chkc) end
	if chk==0 then return true end
	-- 检测【电子暗黑世界】(64753988)的效果是否生效中。若在生效中，「电子暗黑」怪兽的召唤·特殊召唤成功时发动的自身的效果让自己从自己墓地把怪兽装备的场合，也能作为代替从对方墓地装备。
	local loc=Duel.IsPlayerAffectedByEffect(tp,64753988) and LOCATION_GRAVE or 0
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择墓地中1只满足条件的龙族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c77625948.filter,tp,LOCATION_GRAVE,loc,1,1,nil)
	-- 设置效果处理信息为卡片离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 召唤成功时装备效果的具体执行
function c77625948.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的第一个对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) then
		local atk=tc:GetTextAttack()
		if atk<0 then atk=0 end
		-- 将目标怪兽作为装备卡装备给这张卡，若装备失败则结束处理
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 那只龙族怪兽当作装备卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c77625948.eqlimit)
		tc:RegisterEffect(e1)
		-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
		-- ④：这张卡被战斗破坏的场合，作为代替把这张卡的效果装备的怪兽破坏。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(c77625948.repval)
		tc:RegisterEffect(e3)
	end
end
-- 限制装备卡只能装备在当前卡片上
function c77625948.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 确定代替破坏的适用条件为战斗破坏
function c77625948.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 判定直接攻击时攻击力减半效果的适用条件
function c77625948.atkcon(e)
	local tp=e:GetHandlerPlayer()
	-- 必须在伤害计算时
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL
		-- 并且对方场上有怪兽存在且进行直接攻击
		and Duel.GetAttackTarget()==nil and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)~=0
		and e:GetHandler():GetEffectCount(EFFECT_DIRECT_ATTACK)==1
end
-- 计算并返回减半后的攻击力数值（向上取整）
function c77625948.atkval(e,c)
	return math.ceil(c:GetAttack()/2)
end
