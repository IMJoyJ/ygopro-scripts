--猛虎モンフー
-- 效果：
-- ①：只要这张卡在怪兽区域存在，这张卡以外的场上的怪兽的攻击力下降500。
-- ②：1回合1次，自己主要阶段才能发动。持有比这张卡低的攻击力的场上的怪兽全部破坏。
local s,id,o=GetID()
-- 在initial_effect中为猛虎注册两个效果：e1为永续效果，使这张卡以外的场上表侧表示怪兽攻击力下降500；e2为起动效果，1回合1次，在自己主要阶段破坏场上所有攻击力低于猛虎的怪兽。
function s.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，这张卡以外的场上的怪兽的攻击力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.atktg)
	e1:SetValue(-500)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。持有比这张卡低的攻击力的场上的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- atktg是e1的取对象过滤器：只影响表侧表示且不是猛虎自身的怪兽。
function s.atktg(e,c)
	return c:IsFaceup() and c~=e:GetHandler()
end
-- filter是通用过滤函数：选取表侧表示且当前攻击力低于参数atk（猛虎攻击力）的怪兽。
function s.filter(c,atk)
	return c:IsFaceup() and c:GetAttack()<atk
end
-- destg是e2的发动条件与目标处理：获取猛虎当前攻击力，在发动时检查是否存在符合条件的怪兽；若存在，则取得这些怪兽并设置将破坏它们的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=e:GetHandler():GetAttack()
	-- chk==0（发动条件确认）时，检查场上是否存在至少1只表侧表示且攻击力低于猛虎攻击力的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,atk) end
	-- 用当前猛虎攻击力获取场上所有满足条件的怪兽组，用于后续设置操作信息。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,atk)
	-- 设置本次效果处理时将破坏的怪兽组及其数量，使其他卡能正确响应破坏效果。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- desop是e2的效果处理函数：效果处理时若猛虎仍与效果相关且表侧表示，则重新获取当时攻击力低于猛虎的怪兽并全部破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 在处理时重新获取当前场上所有攻击力低于猛虎当前攻击力的怪兽。
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,c:GetAttack())
		-- 以效果原因破坏这组怪兽。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
