--怒れるもけもけ
-- 效果：
-- 「悠悠」在自己场上表侧表示存在时，自己场上天使族怪兽被破坏的场合，这个回合的结束阶段前自己场上「悠悠」的攻击力变为3000。
function c1965724.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上天使族怪兽被破坏的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c1965724.regcon)
	e2:SetOperation(c1965724.regop)
	c:RegisterEffect(e2)
	-- 自己场上「悠悠」的攻击力变为3000
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SET_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c1965724.atktg)
	e3:SetCondition(c1965724.atkcon)
	e3:SetValue(3000)
	c:RegisterEffect(e3)
end
-- 检查被破坏的怪兽是否为天使族
function c1965724.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(tp) and c:GetPreviousRaceOnField()&RACE_FAIRY~=0
end
-- 检查场上是否存在表侧表示的悠悠
function c1965724.cfilter2(c)
	return c:IsFaceup() and c:IsCode(27288416)
end
-- 判断是否满足触发条件：未触发过且有天使族怪兽被破坏且场上有悠悠
function c1965724.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(1965724)==0 and eg:IsExists(c1965724.cfilter,1,nil,tp)
		-- 检查场上有无表侧表示的悠悠
		and Duel.IsExistingMatchingCard(c1965724.cfilter2,tp,LOCATION_MZONE,0,1,nil)
end
-- 记录已触发标记，使效果在结束阶段前生效
function c1965724.regop(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():RegisterFlagEffect(1965724,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 判断是否已触发标记，决定是否应用攻击力变化
function c1965724.atkcon(e)
	return e:GetHandler():GetFlagEffect(1965724)~=0
end
-- 设定效果目标为场上的悠悠
function c1965724.atktg(e,c)
	return c:IsFaceup() and c:IsCode(27288416)
end
