--コアキメイル・ルークロード
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只战士族怪兽给对方观看。或者都不进行让这张卡破坏。这张卡可以把1只名字带有「核成」的怪兽解放作上级召唤。这张卡召唤成功时，可以把自己墓地存在的1张名字带有「核成」的卡从游戏中除外，对方场上存在的最多2张卡破坏。
function c10060427.initial_effect(c)
	-- 为卡片注册「核成兽的钢核」的卡片代码，用于后续效果判断
	aux.AddCodeList(c,36623431)
	-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只战士族怪兽给对方观看。或者都不进行让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c10060427.mtcon)
	e1:SetOperation(c10060427.mtop)
	c:RegisterEffect(e1)
	-- 这张卡可以把1只名字带有「核成」的怪兽解放作上级召唤。
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
	-- 这张卡召唤成功时，可以把自己墓地存在的1张名字带有「核成」的卡从游戏中除外，对方场上存在的最多2张卡破坏。
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
-- 判断是否为自己的结束阶段
function c10060427.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 过滤手卡中「核成兽的钢核」的卡片
function c10060427.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 过滤手卡中战士族怪兽的卡片
function c10060427.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_WARRIOR) and not c:IsPublic()
end
-- 处理结束阶段效果的选择与执行
function c10060427.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 为效果发动显示选卡动画
	Duel.HintSelection(Group.FromCards(c))
	-- 获取手卡中「核成兽的钢核」的卡片组
	local g1=Duel.GetMatchingGroup(c10060427.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取手卡中战士族怪兽的卡片组
	local g2=Duel.GetMatchingGroup(c10060427.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 当手卡同时有「核成兽的钢核」和战士族怪兽时，选择其一执行效果
		select=Duel.SelectOption(tp,aux.Stringid(10060427,0),aux.Stringid(10060427,1),aux.Stringid(10060427,2))  --"选择一张「核成兽的钢核」送去墓地" / "选择一张战士族怪兽给对方观看" / "破坏「核成城主」"
	elseif g1:GetCount()>0 then
		-- 当手卡只有「核成兽的钢核」时，选择将其送去墓地或破坏卡片
		select=Duel.SelectOption(tp,aux.Stringid(10060427,0),aux.Stringid(10060427,2))  --"选择一张「核成兽的钢核」送去墓地" / "破坏「核成城主」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 当手卡只有战士族怪兽时，选择将其给对方观看或破坏卡片
		select=Duel.SelectOption(tp,aux.Stringid(10060427,1),aux.Stringid(10060427,2))+1  --"选择一张战士族怪兽给对方观看"
	else
		-- 当手卡既无「核成兽的钢核」也无战士族怪兽时，只能选择破坏卡片
		select=Duel.SelectOption(tp,aux.Stringid(10060427,2))  --"破坏「核成城主」"
		select=2
	end
	if select==0 then
		-- 提示选择将卡片送去墓地
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=g1:Select(tp,1,1,nil)
		-- 将选择的卡片送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 提示选择确认卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=g2:Select(tp,1,1,nil)
		-- 向对方确认选择的卡片
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
	else
		-- 将卡片破坏
		Duel.Destroy(c,REASON_COST)
	end
end
-- 过滤场上名字带有「核成」的怪兽
function c10060427.otfilter(c,tp)
	return c:IsSetCard(0x1d) and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断是否满足上级召唤的条件
function c10060427.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上名字带有「核成」的怪兽组
	local mg=Duel.GetMatchingGroup(c10060427.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判断是否满足上级召唤的条件（等级、祭品数量、是否有祭品）
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 执行上级召唤的处理
function c10060427.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上名字带有「核成」的怪兽组
	local mg=Duel.GetMatchingGroup(c10060427.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 选择用于上级召唤的祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放选择的祭品
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 过滤墓地中名字带有「核成」的卡片
function c10060427.dfilter(c)
	return c:IsSetCard(0x1d) and c:IsAbleToRemoveAsCost()
end
-- 处理破坏效果的费用
function c10060427.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的墓地卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c10060427.dfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示选择将卡片除外
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择一张墓地中的「核成」卡
	local g=Duel.SelectMatchingCard(tp,c10060427.dfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡片除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置破坏效果的目标选择
function c10060427.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查是否有满足条件的对方场上卡片
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择对方场上1到2张卡片作为破坏目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,2,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果
function c10060427.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将目标卡片破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
