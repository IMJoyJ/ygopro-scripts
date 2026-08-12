--ピケルの魔法陣
-- 效果：
-- 直到这个回合的结束阶段前，这张卡的控制者受到的卡的效果的伤害为0。
function c74270067.initial_effect(c)
	-- 直到这个回合的结束阶段前，这张卡的控制者受到的卡的效果的伤害为0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c74270067.operation)
	c:RegisterEffect(e1)
end
-- 在魔法卡发动成功时，为发动玩家注册在回合结束前使其受到的效果伤害变为0的玩家效果。
function c74270067.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 直到这个回合的结束阶段前，这张卡的控制者受到的卡的效果的伤害为0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c74270067.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将使效果伤害变为0的效果注册给发动这张卡的玩家。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将防止效果伤害的标记效果注册给发动这张卡的玩家，用于系统检测。
	Duel.RegisterEffect(e2,tp)
end
-- 伤害值计算函数，若伤害原因为卡片效果则将伤害值修改为0，否则保持原伤害值。
function c74270067.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return 0
	else return val end
end
