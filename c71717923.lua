--モーム
-- 效果：
-- 把自己场上表侧表示存在的1只地属性怪兽解放发动。场上表侧表示存在持有解放怪兽的攻击力以下的守备力的怪兽全部破坏。
function c71717923.initial_effect(c)
	-- 把自己场上表侧表示存在的1只地属性怪兽解放发动。场上表侧表示存在持有解放怪兽的攻击力以下的守备力的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71717923,0))  --"怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c71717923.descost)
	e1:SetTarget(c71717923.destg)
	e1:SetOperation(c71717923.desop)
	c:RegisterEffect(e1)
end
-- 过滤作为解放代价的地属性怪兽，该怪兽必须是表侧表示，且场上存在至少1只守备力在其攻击力以下的表侧表示怪兽（排除其自身）
function c71717923.costfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH)
		-- 检查场上是否存在至少1只守备力在被解放怪兽攻击力以下的表侧表示怪兽（排除作为解放代价的怪兽自身）
		and Duel.IsExistingMatchingCard(c71717923.filter,0,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetAttack())
end
-- 过滤场上表侧表示且守备力在指定数值（解放怪兽的攻击力）以下的怪兽
function c71717923.filter(c,atk)
	return c:IsFaceup() and c:IsDefenseBelow(atk)
end
-- 效果发动的代价处理函数，检查并选择自己场上1只表侧表示的地属性怪兽解放，并记录其攻击力
function c71717923.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己场上是否存在至少1只满足解放条件的地属性怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c71717923.costfilter,1,nil) end
	-- 玩家选择自己场上1只满足解放条件的地属性怪兽
	local g=Duel.SelectReleaseGroup(tp,c71717923.costfilter,1,1,nil)
	e:SetLabel(g:GetFirst():GetAttack())
	-- 将选中的怪兽作为代价解放
	Duel.Release(g,REASON_COST)
end
-- 效果发动的目标确认与操作信息设置函数，获取符合破坏条件的怪兽并设置破坏操作信息
function c71717923.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有守备力在解放怪兽攻击力（保存在Label中）以下的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c71717923.filter,0,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetLabel())
	-- 设置连锁处理的操作信息，表明此效果将破坏这些符合条件的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理的执行函数，获取符合破坏条件的怪兽并将其全部破坏
function c71717923.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，重新获取场上所有守备力在解放怪兽攻击力（保存在Label中）以下的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c71717923.filter,0,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetLabel())
	-- 将所有符合条件的怪兽因效果破坏
	Duel.Destroy(g,REASON_EFFECT)
end
