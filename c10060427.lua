--コアキメイル・ルークロード
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只战士族怪兽给对方观看。或者都不进行让这张卡破坏。这张卡可以把1只名字带有「核成」的怪兽解放作上级召唤。这张卡召唤成功时，可以把自己墓地存在的1张名字带有「核成」的卡从游戏中除外，对方场上存在的最多2张卡破坏。
function c10060427.initial_effect(c)
	-- 声明本卡关联「核成兽的钢核」
	aux.AddCodeList(c,36623431)
	-- 维持效果：每次自己的结束阶段，如果不把手牌中的「核成兽的钢核」送去墓地，或者把手牌中的战士族怪兽展示，则这张卡破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c10060427.mtcon)
	e1:SetOperation(c10060427.mtop)
	c:RegisterEffect(e1)
	-- 上级召唤手续：可以使用1只「核成」怪兽解放进行召唤
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
	-- 破坏效果：召唤成功时除外墓地1张「核成」卡，破坏对方场上最多2张卡
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
-- 维持效果条件：必须在自己的结束阶段
function c10060427.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 维持效果过滤：手牌中的「核成兽的钢核」
function c10060427.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 维持效果过滤：手牌中的战士族怪兽
function c10060427.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_WARRIOR) and not c:IsPublic()
end
-- 维持效果的实际操作：支付维持代价或自毁
function c10060427.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 在场上高亮选择本卡
	Duel.HintSelection(Group.FromCards(c))
	-- 获取手牌中所有的「核成兽的钢核」
	local g1=Duel.GetMatchingGroup(c10060427.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取手牌中所有符合条件的战士族怪兽
	local g2=Duel.GetMatchingGroup(c10060427.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 选择支付代价的选项：送去墓地、展示战士族或自毁
		select=Duel.SelectOption(tp,aux.Stringid(10060427,0),aux.Stringid(10060427,1),aux.Stringid(10060427,2))  --"选择一张「核成兽的钢核」送去墓地/选择一张战士族怪兽给对方观看/破坏「核成城主」"
	elseif g1:GetCount()>0 then
		-- 选择支付代价的选项：送去墓地或自毁
		select=Duel.SelectOption(tp,aux.Stringid(10060427,0),aux.Stringid(10060427,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成城主」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 选择支付代价的选项：展示战士族或自毁
		select=Duel.SelectOption(tp,aux.Stringid(10060427,1),aux.Stringid(10060427,2))+1  --"选择一张战士族怪兽给对方观看/破坏「核成城主」"
	else
		-- 无可支付代价，直接自毁
		select=Duel.SelectOption(tp,aux.Stringid(10060427,2))  --"破坏「核成城主」"
		select=2
	end
	if select==0 then
		-- 提示选择送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将维持代价的卡片送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 提示选择给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 将选中的战士族怪兽展示给对方
		Duel.ConfirmCards(1-tp,g)
		-- 将手牌洗牌
		Duel.ShuffleHand(tp)
	else
		-- 将本卡自毁
		Duel.Destroy(c,REASON_COST)
	end
end
-- 过滤可以被解放用于上级召唤的「核成」怪兽
function c10060427.otfilter(c,tp)
	return c:IsSetCard(0x1d) and (c:IsControler(tp) or c:IsFaceup())
end
-- 上级召唤条件检查
function c10060427.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取可以解放的怪兽组
	local mg=Duel.GetMatchingGroup(c10060427.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 检查是否能够通过解放1只核成怪兽完成召唤
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 上级召唤解放的实际操作
function c10060427.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取符合解放条件的怪兽
	local mg=Duel.GetMatchingGroup(c10060427.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 选择1只祭品怪兽
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放选中的祭品怪兽
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 过滤墓地中可以用作代价除外的「核成」卡
function c10060427.dfilter(c)
	return c:IsSetCard(0x1d) and c:IsAbleToRemoveAsCost()
end
-- 破坏效果代价的实际处理
function c10060427.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地是否存在可用作除外Cost的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c10060427.dfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示选择除外目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地中选择要除外的卡片
	local g=Duel.SelectMatchingCard(tp,c10060427.dfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将卡片从游戏中除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 破坏效果的目标锁定
function c10060427.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在目标卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示选择破坏的目标卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择最多2个目标卡片进行锁定
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,2,nil)
	-- 声明破坏卡片的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的实际操作
function c10060427.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取锁定的目标卡片组合
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将所有关联目标卡片破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
