--魔導皇聖 トリス
-- 效果：
-- 魔法师族5星怪兽×2
-- 这张卡的攻击力上升自己场上的超量素材数量×300的数值。此外，1回合1次，把这张卡1个超量素材取除才能发动。把自己卡组洗切。那之后，从卡组上面把5张卡翻开，选最多有那之中的名字带有「魔导书」的卡数量的场上的怪兽破坏。那之后，翻开的卡用喜欢的顺序回到卡组上面。
function c770365.initial_effect(c)
	-- 设置XYZ召唤手续：魔法师族5星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),5,2)
	c:EnableReviveLimit()
	-- 这张卡的攻击力上升自己场上的超量素材数量×300的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c770365.atkval)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，把这张卡1个超量素材取除才能发动。把自己卡组洗切。那之后，从卡组上面把5张卡翻开，选最多有那之中的名字带有「魔导书」的卡数量的场上的怪兽破坏。那之后，翻开的卡用喜欢的顺序回到卡组上面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(770365,0))  --"确认卡组"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c770365.cost)
	e2:SetTarget(c770365.target)
	e2:SetOperation(c770365.operation)
	c:RegisterEffect(e2)
end
-- 计算攻击力上升值的函数
function c770365.atkval(e,c)
	-- 返回自己场上的超量素材数量×300的数值
	return Duel.GetOverlayCount(c:GetControler(),1,0)*300
end
-- 发动代价：取除这张卡的1个超量素材
function c770365.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 发动效果的目标检查函数
function c770365.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组的卡片数量是否在5张以上
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
end
-- 过滤名字带有「魔导书」的卡的过滤函数
function c770365.filter(c)
	return c:IsSetCard(0x106e)
end
-- 效果处理：洗切卡组，翻开5张卡，根据其中的「魔导书」卡数量破坏场上的怪兽，最后将翻开的卡按喜欢顺序放回卡组最上方
function c770365.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 洗切自己的卡组
	Duel.ShuffleDeck(tp)
	-- 中断当前效果，使之后的效果处理视为不同时处理
	Duel.BreakEffect()
	-- 确认自己卡组最上方的5张卡
	Duel.ConfirmDecktop(tp,5)
	-- 获取自己卡组最上方的5张卡
	local g=Duel.GetDecktopGroup(tp,5)
	local ct=g:FilterCount(c770365.filter,nil)
	-- 获取场上所有的怪兽
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if ct>0 and sg:GetCount()>0 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local dg=sg:Select(tp,1,ct,nil)
		-- 为选中的卡片显示被选为对象的动画效果
		Duel.HintSelection(dg)
		-- 因效果破坏选中的怪兽
		Duel.Destroy(dg,REASON_EFFECT)
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
	end
	-- 让玩家将这5张卡以喜欢的顺序放回卡组最上方
	Duel.SortDecktop(tp,tp,5)
end
