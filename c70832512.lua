--レアル・クルセイダー
-- 效果：
-- 5星以上的怪兽特殊召唤成功时，必须把场上表侧表示存在的这张卡解放发动。那些5星以上的怪兽破坏。
function c70832512.initial_effect(c)
	-- 5星以上的怪兽特殊召唤成功时，必须把场上表侧表示存在的这张卡解放发动。那些5星以上的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70832512,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c70832512.condition)
	e1:SetCost(c70832512.cost)
	e1:SetTarget(c70832512.target)
	e1:SetOperation(c70832512.operation)
	c:RegisterEffect(e1)
end
-- 检查并注册一个在连锁结束时重置的标识，以确保该强制诱发效果在同一时点不会重复发动。
function c70832512.condition(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(70832512)~=0 then return false end
	e:GetHandler():RegisterFlagEffect(70832512,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
	return true
end
-- 代价去处处理：检查自身是否在场且可以解放，并在发动时将自身解放。
function c70832512.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and e:GetHandler():IsReleasable() end
	-- 将这张卡解放。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：场上表侧表示且等级在5星以上的怪兽（若传入效果e，则需与该效果有联系）。
function c70832512.dfilter(c,e)
	return c:IsFaceup() and c:IsLevelAbove(5) and (not e or c:IsRelateToEffect(e))
end
-- 检查特殊召唤的怪兽中是否存在满足条件的5星以上怪兽，并将其设为效果处理的对象。
function c70832512.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c70832512.dfilter,1,nil) end
	-- 将特殊召唤的怪兽群设为当前连锁的处理对象。
	Duel.SetTargetCard(eg)
end
-- 效果处理：筛选出特殊召唤的怪兽中仍存在于场上的表侧表示5星以上怪兽并将其破坏。
function c70832512.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c70832512.dfilter,nil,e)
	if g:GetCount()~=0 then
		-- 破坏那些5星以上的怪兽。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
