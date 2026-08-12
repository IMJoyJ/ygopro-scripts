--コアキメイル・スピード
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只机械族怪兽给对方观看。或者都不进行让这张卡破坏。只要这张卡在场上表侧表示存在，自己的抽卡阶段时抽到的卡是「核成兽的钢核」的场合，可以把那张卡给对方观看让自己再抽1张卡。
function c68809475.initial_effect(c)
	-- 注册卡片记有「核成兽的钢核」卡名的信息
	aux.AddCodeList(c,36623431)
	-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只机械族怪兽给对方观看。或者都不进行让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c68809475.mtcon)
	e1:SetOperation(c68809475.mtop)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上表侧表示存在，自己的抽卡阶段时抽到的卡是「核成兽的钢核」的场合，可以把那张卡给对方观看让自己再抽1张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68809475,3))  --"抽卡"
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DRAW)
	e2:SetCondition(c68809475.drcon)
	e2:SetCost(c68809475.drcost)
	e2:SetTarget(c68809475.drtg)
	e2:SetOperation(c68809475.drop)
	c:RegisterEffect(e2)
end
-- 维持效果（结束阶段阶段性处理）的发动条件函数
function c68809475.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 过滤手卡中可以作为Cost送去墓地的「核成兽的钢核」
function c68809475.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 过滤手卡中未公开的机械族怪兽
function c68809475.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_MACHINE) and not c:IsPublic()
end
-- 维持效果（结束阶段阶段性处理）的效果处理函数
function c68809475.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 选中这张卡作为效果处理的对象并显示动画
	Duel.HintSelection(Group.FromCards(c))
	-- 获取手卡中满足送墓条件的「核成兽的钢核」卡片组
	local g1=Duel.GetMatchingGroup(c68809475.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取手卡中满足展示条件的机械族怪兽卡片组
	local g2=Duel.GetMatchingGroup(c68809475.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 玩家手卡同时有「核成兽的钢核」和机械族怪兽时，选择送墓、展示或破坏此卡
		select=Duel.SelectOption(tp,aux.Stringid(68809475,0),aux.Stringid(68809475,1),aux.Stringid(68809475,2))  --"选择一张「核成兽的钢核」送去墓地/选择一张机械族怪兽给对方观看/破坏「核成高速鸟」"
	elseif g1:GetCount()>0 then
		-- 玩家手卡只有「核成兽的钢核」时，选择送墓或破坏此卡
		select=Duel.SelectOption(tp,aux.Stringid(68809475,0),aux.Stringid(68809475,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成高速鸟」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 玩家手卡只有机械族怪兽时，选择展示或破坏此卡
		select=Duel.SelectOption(tp,aux.Stringid(68809475,1),aux.Stringid(68809475,2))+1  --"选择一张机械族怪兽给对方观看/破坏「核成高速鸟」"
	else
		-- 玩家手卡没有上述卡片时，只能选择破坏此卡
		select=Duel.SelectOption(tp,aux.Stringid(68809475,2))  --"破坏「核成高速鸟」"
		select=2
	end
	if select==0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选中的卡作为维持Cost送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 提示玩家选择要给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 给对方玩家确认选中的手卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切手卡
		Duel.ShuffleHand(tp)
	else
		-- 因未支付维持Cost而破坏这张卡
		Duel.Destroy(c,REASON_COST)
	end
end
-- 过滤抽到的未公开的「核成兽的钢核」
function c68809475.filter(c)
	return c:IsCode(36623431) and not c:IsPublic()
end
-- 抽卡时效果的发动条件函数
function c68809475.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为自己在自己的抽卡阶段抽卡
	return ep==tp and Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_DRAW
end
-- 抽卡时效果的发动Cost（展示抽到的「核成兽的钢核」）
function c68809475.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c68809475.filter,1,nil) end
	local g=eg:Filter(c68809475.filter,nil)
	if g:GetCount()==1 then
		-- 给对方玩家确认抽到的「核成兽的钢核」
		Duel.ConfirmCards(1-tp,g)
		-- 洗切手卡
		Duel.ShuffleHand(tp)
	else
		-- 提示玩家选择要给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 给对方玩家确认选中的「核成兽的钢核」
		Duel.ConfirmCards(1-tp,sg)
		-- 洗切手卡
		Duel.ShuffleHand(tp)
	end
end
-- 抽卡时效果的发动准备（Target）函数
function c68809475.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前效果的处理对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前效果的处理参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置当前效果的操作信息为玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡时效果的效果处理（Operation）函数
function c68809475.drop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsFacedown() or not e:GetHandler():IsRelateToEffect(e) then return end
	-- 获取当前效果的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
