--ワーム・ルクイエ
-- 效果：
-- 这张卡若不在这张卡反转的回合则不能攻击宣言。这张卡攻击的场合，战斗阶段结束时变成里侧守备表示。
function c17649753.initial_effect(c)
	-- 这张卡反转时，登记一个标识效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FLIP)
	e1:SetOperation(c17649753.flipop)
	c:RegisterEffect(e1)
	-- 这张卡若不在这张卡反转的回合则不能攻击宣言
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetCondition(c17649753.atkcon)
	c:RegisterEffect(e2)
	-- 这张卡攻击的场合，战斗阶段结束时变成里侧守备表示
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c17649753.poscon)
	e3:SetOperation(c17649753.posop)
	c:RegisterEffect(e3)
end
-- 将标识效果登记到该卡上，用于标记该卡已反转
function c17649753.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(17649753,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 若该卡未登记反转标识，则不能攻击宣言
function c17649753.atkcon(e)
	return e:GetHandler():GetFlagEffect(17649753)==0
end
-- 判断该卡是否在战斗阶段结束前有进行过攻击
function c17649753.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
end
-- 若该卡在战斗阶段结束前有进行过攻击，则将其变为里侧守备表示
function c17649753.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() then
		-- 将目标怪兽变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
