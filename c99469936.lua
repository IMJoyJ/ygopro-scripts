--FA－クリスタル・ゼロ・ランサー
-- 效果：
-- 水属性6星怪兽×3
-- 这张卡也能在自己场上的5阶水属性超量怪兽上面重叠来超量召唤。
-- ①：这张卡的攻击力上升这张卡的超量素材数量×500。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。对方场上的全部表侧表示怪兽的效果直到回合结束时无效。
-- ③：场上的这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
function c99469936.initial_effect(c)
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),6,3,c99469936.ovfilter,aux.Stringid(99469936,0))  --"是否在水属性·5阶超量怪兽上面重叠超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡的超量素材数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c99469936.atkval)
	c:RegisterEffect(e1)
	-- ③：场上的这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c99469936.reptg)
	c:RegisterEffect(e2)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。对方场上的全部表侧表示怪兽的效果直到回合结束时无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(99469936,2))  --"效果无效"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c99469936.cost)
	e3:SetTarget(c99469936.target)
	e3:SetOperation(c99469936.operation)
	c:RegisterEffect(e3)
end
-- 过滤可作为额外超量召唤叠放对象的怪兽：需为表侧表示、阶级5、水属性，用于在自己场上的5阶水属性超量怪兽上面重叠超量召唤。
function c99469936.ovfilter(c)
	return c:IsFaceup() and c:IsRank(5) and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 计算攻击力上升值：返回这张卡的超量素材数量×500，用于①效果的攻击力变化。
function c99469936.atkval(e,c)
	return c:GetOverlayCount()*500
end
-- 检查代替破坏是否可行：这张卡将要被战斗或效果破坏且不是因代替效果而破坏，并且可以取除1个超量素材。
function c99469936.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_REPLACE)
		and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 弹出选择对话框，询问玩家是否用取除1个超量素材来代替这张卡的破坏。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		return true
	else return false end
end
-- 效果②的发动代价：取除这张卡1个超量素材（先检查可否取除，后实际取除）。
function c99469936.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②的发动条件检查：确认对方场上有至少1只表侧表示且效果可被无效的怪兽。
function c99469936.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方怪兽区域是否存在至少1只表侧表示且效果可被无效的怪兽，作为发动前提。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
end
-- 效果②处理：将对方场上全部表侧表示且效果可被无效的怪兽的效果无效化，持续到回合结束。
function c99469936.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有表侧表示且效果可被无效的效果怪兽的集合。
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 对方场上的全部表侧表示怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 对方场上的全部表侧表示怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
