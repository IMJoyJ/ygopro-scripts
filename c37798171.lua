--デプス・シャーク
-- 效果：
-- 自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。对方的准备阶段时1次，这张卡的攻击力直到结束阶段时变成2倍。
function c37798171.initial_effect(c)
	-- 效果原文：自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37798171,0))  --"不解放怪兽进行召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c37798171.ntcon)
	c:RegisterEffect(e1)
	-- 效果原文：对方的准备阶段时1次，这张卡的攻击力直到结束阶段时变成2倍
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37798171,1))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c37798171.atkcon)
	e2:SetOperation(c37798171.atkop)
	c:RegisterEffect(e2)
end
-- 满足条件时才能不解放作召唤：等级不低于5、场上怪兽数量为0且有召唤空间
function c37798171.ntcon(e,c,minc)
	if c==nil then return true end
	-- 满足条件时才能不解放作召唤：等级不低于5且场上怪兽数量为0且有召唤空间
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 满足条件时才能不解放作召唤：场上怪兽数量为0
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
end
-- 满足条件时才能发动：当前回合不是自己回合
function c37798171.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 满足条件时才能发动：当前回合不是自己回合
	return Duel.GetTurnPlayer()~=tp
end
-- 将自身攻击力变为2倍
function c37798171.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将自身攻击力变为2倍
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
