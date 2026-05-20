--光波干渉
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：场上有同名怪兽存在的自己的「光波」怪兽进行战斗的伤害计算时才能发动。那只进行战斗的自己的「光波」怪兽的攻击力直到战斗阶段结束时变成2倍。
function c55496220.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：场上有同名怪兽存在的自己的「光波」怪兽进行战斗的伤害计算时才能发动。那只进行战斗的自己的「光波」怪兽的攻击力直到战斗阶段结束时变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55496220,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,55496220)
	e2:SetCondition(c55496220.atkcon)
	e2:SetOperation(c55496220.atkop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查场上是否存在与指定卡片同名的表侧表示怪兽
function c55496220.cfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 发动条件判定：伤害计算时，自己有表侧表示的「光波」怪兽进行战斗，且场上存在与该怪兽同名的其他表侧表示怪兽
function c55496220.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合玩家操控的处于战斗中的怪兽
	local tc=Duel.GetBattleMonster(tp)
	if not tc then return false end
	e:SetLabelObject(tc)
	return tc:IsFaceup() and tc:IsSetCard(0xe5)
		-- 检查双方场上是否存在至少1张与该战斗怪兽同名且非其自身的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c55496220.cfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,tc,tc:GetCode())
end
-- 效果处理：使进行战斗的自己的「光波」怪兽的攻击力直到战斗阶段结束时变成2倍
function c55496220.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() and tc:IsControler(tp) and tc:IsFaceup() and tc:IsSetCard(0xe5) then
		-- 那只进行战斗的自己的「光波」怪兽的攻击力直到战斗阶段结束时变成2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e1)
	end
end
