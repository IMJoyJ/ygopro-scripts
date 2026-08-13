--デプス・シャーク
-- 效果：
-- 自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。对方的准备阶段时1次，这张卡的攻击力直到结束阶段时变成2倍。
function c37798171.initial_effect(c)
	-- 自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37798171,0))  --"不解放怪兽进行召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c37798171.ntcon)
	c:RegisterEffect(e1)
	-- 对方的准备阶段时1次，这张卡的攻击力直到结束阶段时变成2倍。
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
-- 召唤规则效果的条件判定函数：若c为nil表示效果可注册；否则要求进行无解放召唤（minc==0）、这张卡等级不低于5、自己主要怪兽区有空位且自己场上没有怪兽，满足时允许不用解放作召唤。
function c37798171.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判定无解放召唤（minc==0）、这张卡等级不低于5，并且自己场上主要怪兽区存在可用空格。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判定这张卡的控制者（自己）场上主要怪兽区没有怪兽，满足“自己场上没有怪兽存在”的前提。
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
end
-- 攻击力变化效果的发动条件函数：当进入准备阶段时，若当前回合玩家不是这张卡的控制者（即对方的准备阶段），则允许发动。
function c37798171.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是这张卡的控制者，即当前是对方的准备阶段。
	return Duel.GetTurnPlayer()~=tp
end
-- 效果处理：若这张卡仍表侧表示且与效果存在关联，则将其攻击力变成当前攻击力的2倍，该变化持续到结束阶段，并随离场、无效等事件重置。
function c37798171.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到结束阶段时变成2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
