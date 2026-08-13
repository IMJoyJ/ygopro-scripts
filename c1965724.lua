--怒れるもけもけ
-- 效果：
-- 「悠悠」在自己场上表侧表示存在时，自己场上天使族怪兽被破坏的场合，这个回合的结束阶段前自己场上「悠悠」的攻击力变为3000。
function c1965724.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 「悠悠」在自己场上表侧表示存在时，自己场上天使族怪兽被破坏的场合，这个回合的结束阶段前（登记触发标记，供攻击力变化效果使用）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c1965724.regcon)
	e2:SetOperation(c1965724.regop)
	c:RegisterEffect(e2)
	-- 自己场上「悠悠」的攻击力变为3000。
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
-- 过滤被破坏的怪兽：必须是之前在我方主要怪兽区以表侧表示存在、由我方控制、且在场上的种族为天使族的怪兽。
function c1965724.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(tp) and c:GetPreviousRaceOnField()&RACE_FAIRY~=0
end
-- 过滤对象怪兽：必须是表侧表示且卡号与「悠悠」（27288416）一致的怪兽。
function c1965724.cfilter2(c)
	return c:IsFaceup() and c:IsCode(27288416)
end
-- 触发条件判定：本卡尚未登记过标记，且本次被破坏的怪兽中满足「我方场上表侧表示的天使族怪兽」条件，同时我方场上存在表侧表示的「悠悠」。
function c1965724.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(1965724)==0 and eg:IsExists(c1965724.cfilter,1,nil,tp)
		-- 检查我方怪兽区是否存在至少1只表侧表示的「悠悠」。
		and Duel.IsExistingMatchingCard(c1965724.cfilter2,tp,LOCATION_MZONE,0,1,nil)
end
-- 满足条件时给自身登记标记，标记持续到结束阶段或卡片离场、回手牌等标准重置时，用于限定攻击力变化效果的有效期限。
function c1965724.regop(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():RegisterFlagEffect(1965724,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 攻击力变化效果的适用条件：本卡已登记过上述触发标记（即本回合确有符合条件的我方天使族怪兽被破坏）。
function c1965724.atkcon(e)
	return e:GetHandler():GetFlagEffect(1965724)~=0
end
-- 指定攻击力变化的对象：仅限我方场上表侧表示且卡号为27288416的「悠悠」怪兽。
function c1965724.atktg(e,c)
	return c:IsFaceup() and c:IsCode(27288416)
end
