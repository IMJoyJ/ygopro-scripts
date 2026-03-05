--ダーク・サンクチュアリ
-- 效果：
-- ①：自己的「通灵盘」的效果要让「死之信息」卡出现的场合，可以让那卡作为通常怪兽（恶魔族·暗·1星·攻/守0）特殊召唤。这个效果特殊召唤的卡不受「通灵盘」以外的卡的效果影响，不会被作为攻击对象（自己场上只有被这个效果适用的怪兽存在的状态中对方的攻击变成对自己的直接攻击）。
-- ②：对方怪兽的攻击宣言时发动。进行1次投掷硬币。表的场合，那次攻击无效，给与对方那只对方怪兽的攻击力一半数值的伤害。
function c16625614.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：自己的「通灵盘」的效果要让「死之信息」卡出现的场合，可以让那卡作为通常怪兽（恶魔族·暗·1星·攻/守0）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(16625614)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
	-- 效果原文内容：对方怪兽的攻击宣言时发动。进行1次投掷硬币。表的场合，那次攻击无效，给与对方那只对方怪兽的攻击力一半数值的伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCategory(CATEGORY_COIN)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(c16625614.condition)
	e4:SetTarget(c16625614.target)
	e4:SetOperation(c16625614.operation)
	c:RegisterEffect(e4)
end
-- 规则层面作用：设置一个永续效果，用于限制「通灵盘」以外的效果无法影响被特殊召唤的「死之信息」卡。
function c16625614.efilter(e,te)
	local tc=te:GetHandler()
	return not tc:IsCode(94212438)
end
-- 规则层面作用：设置一个诱发效果，用于在对方攻击宣言时触发。
function c16625614.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断是否为对方回合，确保效果只在对方攻击时发动。
	return tp~=Duel.GetTurnPlayer()
end
-- 规则层面作用：设置效果处理时的硬币投掷操作信息。
function c16625614.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面作用：设置当前处理的连锁的操作信息为投掷硬币，目标玩家为当前回合玩家，投掷次数为1。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 规则层面作用：设置效果发动后的处理逻辑，包括投掷硬币、无效攻击并造成伤害。
function c16625614.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取此次攻击的怪兽。
	local tc=Duel.GetAttacker()
	-- 规则层面作用：让当前回合玩家投掷1次硬币。
	local coin=Duel.TossCoin(tp,1)
	if coin==1 then
		-- 规则层面作用：如果硬币为正面，则尝试无效此次攻击。
		if Duel.NegateAttack() then
			-- 规则层面作用：给与对方玩家攻击怪兽攻击力一半数值的伤害。
			Duel.Damage(1-tp,math.floor(tc:GetAttack()/2),REASON_EFFECT)
		end
	end
end
