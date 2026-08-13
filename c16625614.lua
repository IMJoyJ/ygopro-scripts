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
	-- ①：自己的「通灵盘」的效果要让「死之信息」卡出现的场合，可以让那卡作为通常怪兽（恶魔族·暗·1星·攻/守0）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(16625614)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
	-- ②：对方怪兽的攻击宣言时发动。进行1次投掷硬币。表的场合，那次攻击无效，给与对方那只对方怪兽的攻击力一半数值的伤害。
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
-- 该函数检查一个效果的发动者是否为「通灵盘」（卡号94212438）：若发动者是通灵盘则返回false，否则返回true。通常用于免疫判定，使“不受「通灵盘」以外的卡的效果影响”表现为只拦阻非通灵盘的效果，而放行通灵盘的效果。
function c16625614.efilter(e,te)
	local tc=te:GetHandler()
	return not tc:IsCode(94212438)
end
-- ②效果的发动条件：只有效果控制者tp不是当前回合玩家时才满足，即只在对方回合（对方怪兽攻击宣言）时才能发动。
function c16625614.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断tp是否为非回合玩家；若是则返回true，确保只在对方回合触发。
	return tp~=Duel.GetTurnPlayer()
end
-- 目标处理：在检查阶段返回true表示效果可以发动；随后登记本次操作包含投掷硬币（1次），供连锁与判定使用。
function c16625614.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向系统登记本次操作包含CATEGORY_COIN（硬币）分类，投掷次数为1，由tp进行投掷，用于公开操作信息并让相关卡片正确响应。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- ②效果处理：取得攻击怪兽；由我方投掷1次硬币；若为正面则尝试无效该攻击；若无效成功，给与对方该攻击怪兽当前攻击力一半数值的效果伤害。
function c16625614.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行攻击宣言的那只怪兽，作为后续判定与伤害计算的依据。
	local tc=Duel.GetAttacker()
	-- 由效果控制者tp投掷1次硬币，结果为1表示正面，0表示反面。
	local coin=Duel.TossCoin(tp,1)
	if coin==1 then
		-- 硬币为正面时，调用Duel.NegateAttack()无效当前攻击；只有无效成功（返回true）才继续处理伤害。
		if Duel.NegateAttack() then
			-- 给与对方玩家（1-tp）该攻击怪兽当前攻击力一半数值（向下取整）的效果伤害，伤害原因为效果。
			Duel.Damage(1-tp,math.floor(tc:GetAttack()/2),REASON_EFFECT)
		end
	end
end
