--メサイアの蟻地獄
-- 效果：
-- 3星以下的怪兽召唤·反转召唤的回合的结束阶段破坏。
function c54109233.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 3星以下的怪兽召唤·反转召唤的回合的结束阶段破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54109233,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetTarget(c54109233.target)
	e2:SetOperation(c54109233.activate)
	c:RegisterEffect(e2)
	if not c54109233.global_check then
		c54109233.global_check=true
		-- 召唤...的回合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(c54109233.checkop)
		-- 在全局环境中注册用于监听怪兽通常召唤成功事件的永续效果
		Duel.RegisterEffect(ge1,0)
		-- 3星以下的怪兽...反转召唤的回合的结束阶段破坏。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		ge2:SetOperation(c54109233.checkop)
		-- 在全局环境中注册用于监听怪兽反转召唤成功事件的永续效果
		Duel.RegisterEffect(ge2,0)
	end
end
-- 在怪兽通常召唤或反转召唤成功时，为其注册一个持续到回合结束的标记
function c54109233.checkop(e,tp,eg,ep,ev,re,r,rp)
	eg:GetFirst():RegisterFlagEffect(54109233,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 过滤场上等级3以下且在本回合被通常召唤或反转召唤的怪兽
function c54109233.filter(c)
	return c:IsLevelBelow(3) and c:GetFlagEffect(54109233)~=0
end
-- 结束阶段效果发动的靶向函数，确认并设置要破坏的怪兽的操作信息
function c54109233.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上所有满足过滤条件的怪兽
	local g=Duel.GetMatchingGroup(c54109233.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置当前连锁的操作信息为破坏这些怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 结束阶段效果发动的执行函数，破坏所有满足过滤条件的怪兽
function c54109233.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有满足过滤条件的怪兽
	local g=Duel.GetMatchingGroup(c54109233.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 因效果破坏这些怪兽并送入墓地
	Duel.Destroy(g,REASON_EFFECT)
end
