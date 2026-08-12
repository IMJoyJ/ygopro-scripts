--投石部隊
-- 效果：
-- 自己的场上的1只战士族怪兽做祭品。持有这张卡的攻击力以下的守备力的表侧表示的1只怪兽破坏。
function c76075810.initial_effect(c)
	-- 自己的场上的1只战士族怪兽做祭品。持有这张卡的攻击力以下的守备力的表侧表示的1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76075810,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c76075810.descost)
	e1:SetTarget(c76075810.destg)
	e1:SetOperation(c76075810.desop)
	c:RegisterEffect(e1)
end
-- 定义发动代价：解放自己场上的1只战士族怪兽
function c76075810.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动阶段（chk==0）检查自己场上是否存在除这张卡以外的、可以解放的战士族怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,c,RACE_WARRIOR) end
	-- 让玩家选择自己场上除这张卡以外的1只战士族怪兽
	local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,c,RACE_WARRIOR)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 过滤条件：场上表侧表示且守备力在指定数值以下的怪兽
function c76075810.filter(c,atk)
	return c:IsFaceup() and c:IsDefenseBelow(atk)
end
-- 定义效果发动阶段：检查是否存在符合条件的破坏对象，并设置破坏的操作信息
function c76075810.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=e:GetHandler():GetAttack()
	-- 在发动阶段（chk==0）检查场上是否存在至少1只守备力在这张卡当前攻击力以下的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c76075810.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,atk) end
	-- 获取场上所有守备力在这张卡当前攻击力以下的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c76075810.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,atk)
	-- 设置连锁的操作信息：预计破坏上述怪兽中的1只
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义效果处理阶段：若这张卡仍在场上表侧表示存在，则选择并破坏1只符合条件的怪兽
function c76075810.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local atk=c:GetAttack()
	-- 给玩家发送提示信息，要求选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择1只守备力在这张卡当前攻击力以下的表侧表示怪兽
	local g=Duel.SelectMatchingCard(tp,c76075810.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,atk)
	if g:GetCount()>0 then
		-- 为选中的怪兽显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 因效果破坏选中的怪兽
		Duel.Destroy(g,REASON_EFFECT)
	end
end
