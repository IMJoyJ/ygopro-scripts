--コアキメイル・ルークロード
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只战士族怪兽给对方观看。或者都不进行让这张卡破坏。这张卡可以把1只名字带有「核成」的怪兽解放作上级召唤。这张卡召唤成功时，可以把自己墓地存在的1张名字带有「核成」的卡从游戏中除外，对方场上存在的最多2张卡破坏。
function c10060427.initial_effect(c)
	-- 将卡片36623431的代码添加到该卡的CodeList中，用于记录这张卡上记载着另一张卡名。
	aux.AddCodeList(c,36623431)
	-- 创建并注册一个效果，该效果在结束阶段触发，允许玩家选择送一张「核成兽的钢核」去墓地、展示战士族怪兽给对方或破坏这张卡。这对应了“这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只战士族怪兽给对方观看。或者都不进行让这张卡破坏。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c10060427.mtcon)
	e1:SetOperation(c10060427.mtop)
	c:RegisterEffect(e1)
	-- 创建并注册一个效果，允许该卡以一只“核成”怪兽为祭品进行上级召唤。这对应了“这张卡可以把1只名字带有「核成」的怪兽解放作上级召唤。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10060427,3))  --"把1只「核成」怪兽解放作上级召唤"
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c10060427.otcon)
	e2:SetOperation(c10060427.otop)
	e2:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e3)
	-- 创建并注册一个触发效果，在成功召唤时触发，允许玩家从墓地除外一张“核成”卡片并破坏对方场上的最多两张卡。这对应了“这张卡召唤成功时，可以把自己墓地存在的1张名字带有「核成」的卡从游戏中除外，对方场上存在的最多2张卡破坏。”
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10060427,4))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCost(c10060427.descost)
	e3:SetTarget(c10060427.destg)
	e3:SetOperation(c10060427.desop)
	c:RegisterEffect(e3)
end
-- 条件判断：如果当前回合玩家是效果触发者。
function c10060427.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为效果触发者。
	return Duel.GetTurnPlayer()==tp
end
-- 定义一个过滤器函数，用于筛选手牌中可以作为送去墓地的「核成兽的钢核」。
function c10060427.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 定义一个过滤器函数，用于筛选手牌中战士族且未公开的怪兽。
function c10060427.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_WARRIOR) and not c:IsPublic()
end
-- 创建并注册一个效果，该效果在结束阶段触发，允许玩家选择送一张「核成兽的钢核」去墓地、展示战士族怪兽给对方或破坏这张卡。这对应了“这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只战士族怪兽给对方观看。或者都不进行让这张卡破坏。”
function c10060427.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 高亮显示当前卡片，提示玩家。
	Duel.HintSelection(Group.FromCards(c))
	-- 从玩家的手牌中检索符合条件「核成兽的钢核」的卡组。
	local g1=Duel.GetMatchingGroup(c10060427.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 从玩家的手牌中检索符合条件的战士族怪兽卡组。
	local g2=Duel.GetMatchingGroup(c10060427.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 如果同时存在「核成兽的钢核」和战士族怪兽，则向玩家提供选择：送去墓地、展示给对方或破坏这张卡。
		select=Duel.SelectOption(tp,aux.Stringid(10060427,0),aux.Stringid(10060427,1),aux.Stringid(10060427,2))  --"选择一张「核成兽的钢核」送去墓地/选择一张战士族怪兽给对方观看/破坏「核成城主」"
	elseif g1:GetCount()>0 then
		-- 如果只有「核成兽的钢核」，则向玩家提供选择：送去墓地或破坏这张卡。
		select=Duel.SelectOption(tp,aux.Stringid(10060427,0),aux.Stringid(10060427,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成城主」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 如果只有战士族怪兽，则向玩家提供选择：展示给对方或破坏这张卡（+1是为了调整选项序号）。
		select=Duel.SelectOption(tp,aux.Stringid(10060427,1),aux.Stringid(10060427,2))+1  --"选择一张战士族怪兽给对方观看/破坏「核成城主」"
	else
		-- 如果没有符合条件的卡牌，则只提供破坏这张卡的选项。
		select=Duel.SelectOption(tp,aux.Stringid(10060427,2))  --"破坏「核成城主」"
		select=2
	end
	if select==0 then
		-- 提示玩家选择要送去墓地的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选中的卡片送去墓地作为效果的COST。
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 提示玩家选择要展示给对方的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 确认选中的卡片给对方玩家。
		Duel.ConfirmCards(1-tp,g)
		-- 洗切玩家的手牌。
		Duel.ShuffleHand(tp)
	else
		-- 以REASON_COST的原因破坏这张卡。
		Duel.Destroy(c,REASON_COST)
	end
end
-- 定义一个过滤器函数，用于筛选场上或墓地中带有“核成”的卡片。
function c10060427.otfilter(c,tp)
	return c:IsSetCard(0x1d) and (c:IsControler(tp) or c:IsFaceup())
end
-- 条件判断：如果该卡存在且等级高于7，并且可以进行祭品召唤。
function c10060427.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 从玩家场上的怪兽区域检索符合条件的“核成”怪兽卡组。
	local mg=Duel.GetMatchingGroup(c10060427.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 检查是否满足祭品召唤的条件（等级、数量）。
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 创建并注册一个效果，允许该卡以一只“核成”怪兽为祭品进行上级召唤。这对应了“这张卡可以把1只名字带有「核成」的怪兽解放作上级召唤。”
function c10060427.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 从玩家场上的怪兽区域检索符合条件的“核成”怪兽卡组。
	local mg=Duel.GetMatchingGroup(c10060427.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家选择用于祭品的怪兽。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 释放选中的祭品怪兽。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 定义一个过滤器函数，用于筛选墓地中可以作为除外COST的带有“核成”的卡片。
function c10060427.dfilter(c)
	return c:IsSetCard(0x1d) and c:IsAbleToRemoveAsCost()
end
-- 创建并注册一个触发效果，在成功召唤时触发，允许玩家从墓地除外一张“核成”卡片并破坏对方场上的最多两张卡。这对应了“这张卡召唤成功时，可以把自己墓地存在的1张名字带有「核成」的卡从游戏中除外，对方场上存在的最多2张卡破坏。”
function c10060427.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有符合条件的卡牌可以作为除外COST。
	if chk==0 then return Duel.IsExistingMatchingCard(c10060427.dfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择墓地中符合条件的卡片。
	local g=Duel.SelectMatchingCard(tp,c10060427.dfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡片从游戏中移除作为效果的COST。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 创建并注册一个触发效果，在成功召唤时触发，允许玩家从墓地除外一张“核成”卡片并破坏对方场上的最多两张卡。这对应了“这张卡召唤成功时，可以把自己墓地存在的1张名字带有「核成」的卡从游戏中除外，对方场上存在的最多2张卡破坏。”
function c10060427.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查目标卡是否在场上且属于对方。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择要破坏的目标卡片。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,2,nil)
	-- 设置连锁操作信息，表明当前效果是破坏效果，并指定目标卡组和数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 创建并注册一个触发效果，在成功召唤时触发，允许玩家从墓地除外一张“核成”卡片并破坏对方场上的最多两张卡。这对应了“这张卡召唤成功时，可以把自己墓地存在的1张名字带有「核成」的卡从游戏中除外，对方场上存在的最多2张卡破坏。”
function c10060427.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中目标卡片组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 使用效果破坏目标卡片组中的卡片。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
