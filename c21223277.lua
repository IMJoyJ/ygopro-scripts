--聖騎士王アルトリウス
-- 效果：
-- 4星「圣骑士」怪兽×2
-- ①：这张卡超量召唤成功时，以自己墓地最多3张「圣剑」装备魔法卡为对象才能发动（同名卡最多1张）。那些卡给这张卡装备。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。选最多有自己场上的「圣剑」装备魔法卡数量的场上的魔法·陷阱卡破坏。
function c21223277.initial_effect(c)
	-- 为阿托利斯添加超量召唤手续：素材为等级4且持有「圣骑士」字段（0x107a）的怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x107a),4,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤成功时，以自己墓地最多3张「圣剑」装备魔法卡为对象才能发动（同名卡最多1张）。那些卡给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21223277,0))  --"装备"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c21223277.condition)
	e1:SetTarget(c21223277.target)
	e1:SetOperation(c21223277.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。选最多有自己场上的「圣剑」装备魔法卡数量的场上的魔法·陷阱卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21223277,1))  --"魔陷破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c21223277.descost)
	e2:SetTarget(c21223277.destg)
	e2:SetOperation(c21223277.desop)
	c:RegisterEffect(e2)
end
-- 效果②的发动条件：这张卡为超量召唤成功时才能发动（通过判断召唤类型为超量召唤）。
function c21223277.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 墓地中可作为对象的「圣剑」装备魔法卡的筛选条件：卡名含「圣剑」字段、能够成为效果对象、场上没有同名卡、且能够装备给阿托利斯。
function c21223277.filter(c,e,tp,ec)
	return c:IsSetCard(0x207a) and c:IsCanBeEffectTarget(e) and c:CheckUniqueOnField(tp) and c:CheckEquipTarget(ec)
end
-- 效果①的发动时点与对象选择：超量召唤成功时，从墓地选择1～最多3张符合条件的「圣剑」装备魔法卡（同名卡最多1张）作为对象，并设置操作信息。
function c21223277.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c21223277.filter(chkc,e,tp,e:GetHandler()) end
	if chk==0 then
		-- 检查我方魔陷区是否有空位，若无空位则不能发动。
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return false end
		-- 检查墓地是否存在至少1张满足条件的「圣剑」装备魔法卡，作为发动的前提。
		return Duel.IsExistingMatchingCard(c21223277.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,e:GetHandler())
	end
	-- 获取我方魔陷区当前可用空格数，用于限制最多可选的数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 获取墓地中所有满足条件的「圣剑」装备魔法卡，作为候选组。
	local g=Duel.GetMatchingGroup(c21223277.filter,tp,LOCATION_GRAVE,0,nil,e,tp,e:GetHandler())
	-- 向玩家弹出选择提示：请选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从候选组中通过同名卡最多1张的过滤（aux.dncheck），选择1到min(空位,3)张卡作为装备对象。
	local g1=g:SelectSubGroup(tp,aux.dncheck,false,1,math.min(ft,3))
	-- 将选中的卡设置为当前连锁的对象（取对象效果）。
	Duel.SetTargetCard(g1)
	-- 设置操作信息：这些卡将从墓地离开，用于关联涉及墓地的效果（如王家长眠之谷）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g1,g1:GetCount(),0,0)
end
-- 效果①的结算处理：将选择的「圣剑」装备魔法卡实际装备给阿托利斯；若魔陷区空格不足或本卡不在场上/与效果无关则处理失败。
function c21223277.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次计算我方魔陷区可用空格数，用于判断能否全部装备。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 取出连锁对象中的卡，并过滤出仍然与本次效果相关的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if ft<g:GetCount() then return end
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local tc=g:GetFirst()
	while tc do
		-- 将一张「圣剑」装备魔法卡装备给阿托利斯，使用分解步骤（is_step=true）。
		Duel.Equip(tp,tc,c,true,true)
		tc=g:GetNext()
	end
	-- 完成所有装备操作，触发装备成功相关时点。
	Duel.EquipComplete()
end
-- 效果②的发动代价：从阿托利斯身上取除1个超量素材（作为COST）。
function c21223277.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 统计己方场上表侧表示存在的「圣剑」装备魔法卡数量的过滤条件。
function c21223277.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x207a) and c:IsType(TYPE_EQUIP) and c:IsType(TYPE_SPELL)
end
-- 可被破坏的对象的过滤条件：场上的魔法·陷阱卡。
function c21223277.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果②的发动条件：己方场上有「圣剑」装备魔法卡，且双方场上存在至少1张可破坏的魔法陷阱卡。
function c21223277.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方魔陷区是否至少有1张表侧表示的「圣剑」装备魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c21223277.cfilter,tp,LOCATION_SZONE,0,1,nil)
		-- 同时检查场上是否存在至少1张可被破坏的魔法陷阱卡。
		and Duel.IsExistingMatchingCard(c21223277.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有魔法陷阱卡，用于设置破坏的操作信息。
	local g=Duel.GetMatchingGroup(c21223277.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息：本次效果会破坏场上的魔法陷阱卡（数量为至少1，实际数量处理时再决定）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的结算处理：计算己方场上「圣剑」装备魔法卡数量作为最大可破坏数量，选择场上1～该数量的魔法陷阱卡破坏。
function c21223277.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算己方场上表侧「圣剑」装备魔法卡的数量，作为最多可破坏的卡数。
	local ct=Duel.GetMatchingGroupCount(c21223277.cfilter,tp,LOCATION_SZONE,0,nil)
	if ct==0 then return end
	-- 向玩家弹出选择提示：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1到ct张魔法陷阱卡（不取对象，由发动者效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c21223277.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
