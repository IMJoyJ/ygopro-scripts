--魔法族の聖域
-- 效果：
-- 这张卡以外的魔法卡只有自己场上才有表侧表示存在的场合，魔法师族以外的怪兽在对方场上召唤·特殊召唤时，那个回合那些怪兽不能攻击，也不能作效果的发动。此外，自己场上没有魔法师族怪兽存在的场合，这张卡破坏。
function c25407643.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文：自己场上没有魔法师族怪兽存在的场合，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c25407643.descon)
	c:RegisterEffect(e2)
	-- 效果原文：这张卡以外的魔法卡只有自己场上才有表侧表示存在的场合，魔法师族以外的怪兽在对方场上召唤·特殊召唤时，那个回合那些怪兽不能攻击，也不能作效果的发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25407643,0))  --"攻击效果限制"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c25407643.condition)
	e2:SetTarget(c25407643.target)
	e2:SetOperation(c25407643.operation)
	c:RegisterEffect(e2)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 过滤函数：检查场上是否存在表侧表示的魔法师族怪兽。
function c25407643.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 条件函数：判断自己场上是否没有魔法师族怪兽存在。
function c25407643.descon(e)
	-- 判断自己场上是否没有魔法师族怪兽存在。
	return not Duel.IsExistingMatchingCard(c25407643.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：检查场上是否存在表侧表示的魔法卡。
function c25407643.cfilter1(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
-- 过滤函数：检查场上是否存在表侧表示的非魔法师族怪兽。
function c25407643.cfilter2(c,tp)
	return c:IsFaceup() and not c:IsRace(RACE_SPELLCASTER) and c:IsControler(tp)
end
-- 条件函数：判断是否满足魔法族的圣域效果触发条件。
function c25407643.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否存在至少一张魔法卡。
	return Duel.IsExistingMatchingCard(c25407643.cfilter1,tp,LOCATION_SZONE,0,1,e:GetHandler())
		-- 判断对方场上是否存在至少一张魔法卡。
		and not Duel.IsExistingMatchingCard(c25407643.cfilter1,tp,0,LOCATION_SZONE,1,nil)
		and eg:IsExists(c25407643.cfilter2,1,nil,1-tp)
end
-- 目标函数：设置连锁对象为被召唤/特殊召唤的怪兽。
function c25407643.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁对象为被召唤/特殊召唤的怪兽。
	Duel.SetTargetCard(eg)
end
-- 效果处理函数：为符合条件的怪兽设置不能攻击和不能发动效果的限制。
function c25407643.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local c=e:GetHandler()
	while tc do
		if tc:IsRelateToEffect(e) then
			-- 效果原文：那个回合那些怪兽不能攻击。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 效果原文：也不能作效果的发动。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_TRIGGER)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2,true)
		end
		tc=eg:GetNext()
	end
end
