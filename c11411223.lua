--No.10 白輝士イルミネーター
-- 效果：
-- 4星怪兽×3
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。选1张手卡送去墓地，自己从卡组抽1张。
function c11411223.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用任意3只4星怪兽叠放来进行XYZ召唤。
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。选1张手卡送去墓地，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetDescription(aux.Stringid(11411223,0))  --"抽卡"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c11411223.cost)
	e1:SetTarget(c11411223.target)
	e1:SetOperation(c11411223.operation)
	c:RegisterEffect(e1)
end
-- 将卡号11411223登记为编号“No.10”的XYZ怪兽，用于关联“No.”字段相关效果。
aux.xyz_number[11411223]=10
-- 代价函数：检查阶段确认自己场上这张卡能否移除1个超量素材作为代价；发动时实际移除1个超量素材。
function c11411223.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 发动目标检查与操作信息设置：确认手牌有卡且可以抽卡，并设置将1张手卡送去墓地、自己抽1张卡的操作信息。
function c11411223.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 非处理阶段（chk==0）时，确认满足发动条件：自己手牌至少有1张卡，且自己可以进行1张抽卡。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果处理信息：预计将1张手牌送去墓地（处理时选择，不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	-- 设置效果处理信息：预计自己抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：从手牌选择1张卡送去墓地，若该卡确实进入墓地，则自己抽1张卡。
function c11411223.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，让玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己手牌中选择1张卡（无额外过滤条件）。
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()==0 then return end
	-- 将选中的手牌送去墓地。
	Duel.SendtoGrave(g,REASON_EFFECT)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 自己抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
