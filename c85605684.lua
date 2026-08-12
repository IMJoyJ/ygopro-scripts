--バーサーク・デッド・ドラゴン
-- 效果：
-- 这张卡只能以「与恶魔的暗中交易」的效果进行特殊召唤。这张卡可以对对方场上所有怪兽各进行1次攻击。在自己每回合的结束阶段时，这张卡的攻击力下降500点。
function c85605684.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡只能以「与恶魔的暗中交易」的效果进行特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为不能特殊召唤（只能通过其他卡片无视召唤条件的效果特殊召唤）。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 这张卡可以对对方场上所有怪兽各进行1次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 在自己每回合的结束阶段时，这张卡的攻击力下降500点。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85605684,0))  --"攻击下降"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(c85605684.atkcon)
	e3:SetOperation(c85605684.atkop)
	c:RegisterEffect(e3)
end
-- 定义攻击力下降效果的发动条件判定函数。
function c85605684.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己，以满足“在自己每回合”的条件。
	return tp==Duel.GetTurnPlayer()
end
-- 定义攻击力下降效果的具体执行函数，为自身添加攻击力下降的效果。
function c85605684.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡的攻击力下降500点。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
