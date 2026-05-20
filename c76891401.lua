--神海竜ギシルノドン
-- 效果：
-- 调整＋调整以外的3星怪兽1只
-- 场上表侧表示存在的3星以下的怪兽被送去墓地时，这张卡的攻击力直到这个回合的结束阶段时变成3000。
function c76891401.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的3星怪兽1只
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsLevel,3),1,1)
	c:EnableReviveLimit()
	-- 场上表侧表示存在的3星以下的怪兽被送去墓地时，这张卡的攻击力直到这个回合的结束阶段时变成3000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76891401,0))  --"攻击力变成3000"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c76891401.atkcon)
	e1:SetOperation(c76891401.atkop)
	c:RegisterEffect(e1)
end
-- 过滤原本在场上表侧表示存在的3星以下的怪兽
function c76891401.filter(c)
	return c:IsLevelBelow(3) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 判断送去墓地的卡中是否存在满足条件的怪兽
function c76891401.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c76891401.filter,1,nil)
end
-- 使这张卡的攻击力直到回合结束阶段时变成3000
function c76891401.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡的攻击力直到这个回合的结束阶段时变成3000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(3000)
	c:RegisterEffect(e1)
end
