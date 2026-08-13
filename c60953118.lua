--アルカナフォースⅩⅣ－TEMPERANCE
-- 效果：
-- 可以从手卡把这张卡丢弃，自己受到的战斗伤害只有1次变成0。这张卡召唤·反转召唤·特殊召唤成功时，进行1次投掷硬币得到以下效果。
-- ●表：自己受到的战斗伤害变成一半数值。
-- ●里：对方受到的战斗伤害变成一半数值。
function c60953118.initial_effect(c)
	-- 可以从手卡把这张卡丢弃，自己受到的战斗伤害只有1次变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60953118,1))  --"战斗伤害变成0"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c60953118.damcon)
	e1:SetCost(c60953118.damcost)
	e1:SetOperation(c60953118.damop)
	c:RegisterEffect(e1)
	-- 为这张卡注册秘仪之力通用抛硬币触发：在通常召唤、反转召唤、特殊召唤成功时各进行一次硬币判定，并设置正/逆位标记。
	aux.EnableArcanaCoin(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS)
	-- ●表：自己受到的战斗伤害变成一半数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetCondition(c60953118.rdcon1)
	e2:SetValue(HALF_DAMAGE)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetTargetRange(0,1)
	e3:SetCondition(c60953118.rdcon2)
	c:RegisterEffect(e3)
end
-- 伤害计算时，若己方玩家将要受到的战斗伤害大于0，则满足该效果的发动条件。
function c60953118.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回己方将要受到的战斗伤害是否大于0，作为能否发动效果的条件判断。
	return Duel.GetBattleDamage(tp)>0
end
-- 发动代价：检查手牌中的这张卡是否可以被丢弃；若可以，则通过丢弃此卡来支付代价。
function c60953118.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡以“代价+丢弃”的理由从手牌送去墓地，完成丢弃手牌的发动代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 效果处理：为己方玩家注册一个仅在本次伤害计算阶段有效的“不会受到战斗伤害”效果，使这次的战斗伤害变成0。
function c60953118.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 可以从手卡把这张卡丢弃，自己受到的战斗伤害只有1次变成0。这张卡召唤·反转召唤·特殊召唤成功时，进行1次投掷硬币得到以下效果。●表：自己受到的战斗伤害变成一半数值。●里：对方受到的战斗伤害变成一半数值。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
	-- 将生成的战斗伤害规避效果注册给己方玩家，使该效果从当前时刻开始适用。
	Duel.RegisterEffect(e1,tp)
end
-- 判断该怪兽的秘仪硬币标记是否为1（正面），作为表效果（己方战斗伤害减半）的适用条件。
function c60953118.rdcon1(e)
	return e:GetHandler():GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==1
end
-- 判断该怪兽的秘仪硬币标记是否为0（反面），作为里效果（对方战斗伤害减半）的适用条件。
function c60953118.rdcon2(e)
	return e:GetHandler():GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==0
end
