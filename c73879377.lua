--アームド・ドラゴン LV7
-- 效果：
-- 这张卡不能通常召唤，用「武装龙 LV5」的效果才能特殊召唤。
-- ①：从手卡把1只怪兽送去墓地才能发动。持有送去墓地的怪兽的攻击力以下的攻击力的对方场上的怪兽全部破坏。
function c73879377.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用「武装龙 LV5」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制，使这张卡不能被常规方式特殊召唤（必须通过特定效果特殊召唤）
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：从手卡把1只怪兽送去墓地才能发动。持有送去墓地的怪兽的攻击力以下的攻击力的对方场上的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73879377,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c73879377.descost)
	e2:SetTarget(c73879377.destg)
	e2:SetOperation(c73879377.desop)
	c:RegisterEffect(e2)
end
c73879377.lvup={46384672}
c73879377.lvdn={46384672,980973}
-- 过滤手卡中可以作为发动代价送去墓地的怪兽，且对方场上存在攻击力在其攻击力以下的怪兽
function c73879377.cfilter(c,tp)
	local atk=c:GetAttack()
	if atk<0 then atk=0 end
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
		-- 检查对方场上是否存在至少1只攻击力在送去墓地怪兽的攻击力以下的怪兽
		and Duel.IsExistingMatchingCard(c73879377.dfilter,tp,0,LOCATION_MZONE,1,nil,atk)
end
-- 过滤对方场上表侧表示且攻击力在指定数值以下的怪兽
function c73879377.dfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()<=atk
end
-- 效果发动的代价处理：检查并从手卡选择1只怪兽送去墓地，并将其攻击力数值记录在效果标签中
function c73879377.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤0：检查手卡中是否存在可以作为代价送去墓地且能使效果成功发动的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c73879377.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 给发动效果的玩家发送提示信息，提示其选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c73879377.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	local atk=g:GetFirst():GetAttack()
	if atk<0 then atk=0 end
	e:SetLabel(atk)
	-- 将选中的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果的目标处理：在发动时获取将被破坏的对方怪兽组，并设置破坏操作的连锁信息
function c73879377.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有攻击力在送去墓地怪兽的攻击力以下的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c73879377.dfilter,tp,0,LOCATION_MZONE,nil,e:GetLabel())
	-- 设置破坏操作的连锁信息，指定要破坏的卡片组及数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果的处理：获取当前符合条件的对方场上怪兽，并将其全部破坏
function c73879377.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，重新获取对方场上所有攻击力在送去墓地怪兽的攻击力以下的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c73879377.dfilter,tp,0,LOCATION_MZONE,nil,e:GetLabel())
	-- 因效果将符合条件的对方怪兽全部破坏
	Duel.Destroy(g,REASON_EFFECT)
end
