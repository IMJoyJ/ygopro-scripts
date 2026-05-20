--No.56 ゴールドラット
-- 效果：
-- 1星怪兽×3
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。自己从卡组抽1张，那之后选1张手卡回到卡组。
function c55935416.initial_effect(c)
	-- 添加超量召唤手续：1星怪兽×3
	aux.AddXyzProcedure(c,nil,1,3)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。自己从卡组抽1张，那之后选1张手卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55935416,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c55935416.drcost)
	e1:SetTarget(c55935416.drtg)
	e1:SetOperation(c55935416.drop)
	c:RegisterEffect(e1)
end
-- 记录这张卡的「No.」数值为56
aux.xyz_number[55935416]=56
-- 效果发动的代价（Cost）：把这张卡1个超量素材取除
function c55935416.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动的目标（Target）：确认是否能抽卡，并设置抽卡玩家、抽卡数量及操作信息
function c55935416.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查玩家当前是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将效果处理的对象玩家设为当前回合玩家（自己）
	Duel.SetTargetPlayer(tp)
	-- 将效果处理的对象参数（抽卡数量）设为1
	Duel.SetTargetParam(1)
	-- 设置效果处理的操作信息为：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理（Operation）：自己从卡组抽1张，那之后选1张手卡回到卡组
function c55935416.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡处理，让对象玩家因效果抽卡，并返回实际抽卡数量
	local ct=Duel.Draw(p,d,REASON_EFFECT)
	if ct~=0 then
		-- 中断当前效果处理，使前后的抽卡和回卡组处理视为不同时进行
		Duel.BreakEffect()
		-- 在客户端显示提示信息：“请选择要返回卡组的卡”
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 让玩家从自己的手卡中选择任意1张卡
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
		-- 将选择的手卡送回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
