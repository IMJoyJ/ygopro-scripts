--No.10 白輝士イルミネーター
-- 效果：
-- 4星怪兽×3
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。选1张手卡送去墓地，自己从卡组抽1张。
function c11411223.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用4星怪兽3只进行叠放
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
-- 设置该卡的XYZ编号为10
aux.xyz_number[11411223]=10
-- 定义效果的费用处理函数
function c11411223.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义效果的目标选择函数
function c11411223.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌数量是否大于0且玩家可以抽卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁操作信息：将1张手卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	-- 设置连锁操作信息：自己从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义效果的发动处理函数
function c11411223.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择1张手卡作为目标
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()==0 then return end
	-- 将选中的手卡送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 自己从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
