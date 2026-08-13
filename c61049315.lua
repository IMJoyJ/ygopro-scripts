--ナチュル・ローズウィップ
-- 效果：
-- 只要这张卡在场上表侧表示存在，对方玩家1回合魔法·陷阱卡只能发动1次。
function c61049315.initial_effect(c)
	-- 对方玩家1回合魔法·陷阱卡只能发动1次
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c61049315.aclimit1)
	c:RegisterEffect(e1)
	-- 魔法·陷阱卡只能发动1次
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAIN_NEGATED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c61049315.aclimit2)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上表侧表示存在，对方玩家1回合魔法·陷阱卡只能发动1次
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(c61049315.econ)
	e3:SetValue(c61049315.elimit)
	c:RegisterEffect(e3)
end
-- 对方玩家发动魔法·陷阱卡时，给此卡登记一个直到结束阶段有效的“已发动过”标记；若发动者不是对方或不是魔陷发动则忽略。
function c61049315.aclimit1(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	e:GetHandler():RegisterFlagEffect(61049315,RESET_EVENT+0x3ff0000+RESET_PHASE+PHASE_END,0,1)
end
-- 对方发动的魔法·陷阱卡的发动被无效时，清除此卡上的“已发动过”标记，使该次无效发动不计入次数；若发动者不是对方或不是魔陷发动则忽略。
function c61049315.aclimit2(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	e:GetHandler():ResetFlagEffect(61049315)
end
-- 返回是否已存在该卡上登记的“对方本回合已发动过魔法·陷阱卡”标记，作为禁止发动效果生效的条件。
function c61049315.econ(e)
	return e:GetHandler():GetFlagEffect(61049315)~=0
end
-- 用于指定禁止发动的对象为魔法·陷阱卡（EFFECT_TYPE_ACTIVATE）的发动。
function c61049315.elimit(e,te,tp)
	return te:IsHasType(EFFECT_TYPE_ACTIVATE)
end
