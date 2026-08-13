--魔法族の聖域
-- 效果：
-- 这张卡以外的魔法卡只有自己场上才有表侧表示存在的场合，魔法师族以外的怪兽在对方场上召唤·特殊召唤时，那个回合那些怪兽不能攻击，也不能作效果的发动。此外，自己场上没有魔法师族怪兽存在的场合，这张卡破坏。
function c25407643.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 此外，自己场上没有魔法师族怪兽存在的场合，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c25407643.descon)
	c:RegisterEffect(e2)
	-- 这张卡以外的魔法卡只有自己场上才有表侧表示存在的场合，魔法师族以外的怪兽在对方场上召唤·特殊召唤时，那个回合那些怪兽不能攻击，也不能作效果的发动。
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
-- 筛选场上表侧表示且种族为魔法师的怪兽，用于判断自己场上是否存在魔法师族怪兽。
function c25407643.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 自我破坏条件：当自己场上不存在表侧表示魔法师族怪兽时满足。
function c25407643.descon(e)
	-- 检查自己主要怪兽区域是否存在表侧表示魔法师族怪兽；不存在时返回true，使这张卡触发自我破坏。
	return not Duel.IsExistingMatchingCard(c25407643.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 筛选表侧表示的魔法卡，用于检查场上表侧表示的魔法卡的存在位置（自己/对方）。
function c25407643.cfilter1(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
-- 筛选对方场上表侧表示且不是魔法师族的怪兽，用于判定召唤·特殊召唤的怪兽是否属于应受限制的对象。
function c25407643.cfilter2(c,tp)
	return c:IsFaceup() and not c:IsRace(RACE_SPELLCASTER) and c:IsControler(tp)
end
-- 触发条件：自己魔陷区存在这张卡以外的表侧表示魔法卡，对方魔陷区不存在表侧表示魔法卡，且本次召唤·特殊召唤的怪兽组中存在对方控制的非魔法师族怪兽。
function c25407643.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己魔陷区是否存在1张以上除外这张卡自身的表侧表示魔法卡。
	return Duel.IsExistingMatchingCard(c25407643.cfilter1,tp,LOCATION_SZONE,0,1,e:GetHandler())
		-- 检查对方魔陷区不存在表侧表示魔法卡，满足『只有自己场上才有表侧表示魔法卡』这一条件。
		and not Duel.IsExistingMatchingCard(c25407643.cfilter1,tp,0,LOCATION_SZONE,1,nil)
		and eg:IsExists(c25407643.cfilter2,1,nil,1-tp)
end
-- 效果发动时将本次召唤成功的怪兽组整体标记为对象，用于后续处理时确认这些怪兽是否仍与本效果关联。
function c25407643.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将召唤成功的怪兽组登记为当前连锁的对象，使这些怪兽与效果建立关联关系。
	Duel.SetTargetCard(eg)
end
-- 效果处理：遍历召唤成功的怪兽，对仍与本效果关联的怪兽各赋予‘不能攻击’和‘不能发动效果’的持续效果，直到回合结束。
function c25407643.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local c=e:GetHandler()
	while tc do
		if tc:IsRelateToEffect(e) then
			-- 那个回合那些怪兽不能攻击
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 也不能作效果的发动
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_TRIGGER)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2,true)
		end
		tc=eg:GetNext()
	end
end
