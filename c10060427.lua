--コアキメイル・ルークロード
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只战士族怪兽给对方观看。或者都不进行让这张卡破坏。这张卡可以把1只名字带有「核成」的怪兽解放作上级召唤。这张卡召唤成功时，可以把自己墓地存在的1张名字带有「核成」的卡从游戏中除外，对方场上存在的最多2张卡破坏。
function c10060427.initial_effect(c)
	-- 添加关联卡片：将「核成兽的钢核」（卡号36623431）加入到本卡的关联卡片列表中，便于规则检索或分类
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
-- 维持效果的发动条件判定：判断当前是否为自己的回合
function c10060427.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件判断：当前回合玩家是本卡的控制者时返回真
	return Duel.GetTurnPlayer()==tp
end
-- 过滤函数：筛选手牌中的「核成兽的钢核」且该卡可以作为Cost送去墓地
function c10060427.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 过滤函数：筛选手牌中非公开的战士族怪兽
function c10060427.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_WARRIOR) and not c:IsPublic()
end
-- 维持效果的 operation 函数（效果处理）：让控制者选择将「核成兽的钢核」送去墓地、展示战士族怪兽或破坏此卡
function c10060427.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示信息：在场上高亮显示本卡，表明本卡正在进行维持效果的处理
	Duel.HintSelection(Group.FromCards(c))
	-- 获取卡片组：获取玩家手牌中所有符合条件的「核成兽的钢核」
	local g1=Duel.GetMatchingGroup(c10060427.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取卡片组：获取玩家手牌中所有符合条件的战士族怪兽
	local g2=Duel.GetMatchingGroup(c10060427.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 选择选项：玩家手牌中同时拥有「核成兽的钢核」和战士族怪兽时，提供三个选项供玩家选择
		select=Duel.SelectOption(tp,aux.Stringid(10060427,0),aux.Stringid(10060427,1),aux.Stringid(10060427,2))  --"选择一张「核成兽的钢核」送去墓地/选择一张战士族怪兽给对方观看/破坏「核成城主」"
	elseif g1:GetCount()>0 then
		-- 选择选项：玩家手牌中仅有「核成兽的钢核」时，提供送墓或破坏的选择
		select=Duel.SelectOption(tp,aux.Stringid(10060427,0),aux.Stringid(10060427,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成城主」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 选择选项：玩家手牌中仅有战士族怪兽时，提供展示或破坏的选择
		select=Duel.SelectOption(tp,aux.Stringid(10060427,1),aux.Stringid(10060427,2))+1  --"选择一张战士族怪兽给对方观看/破坏「核成城主」"
	else
		-- 选择选项：手牌中既没有钢核也没有战士族怪兽，强行选择破坏此卡
		select=Duel.SelectOption(tp,aux.Stringid(10060427,2))  --"破坏「核成城主」"
		select=2
	end
	if select==0 then
		-- 提示信息：提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 送去墓地：将选择的「核成兽的钢核」送去墓地作为维持代价
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 提示信息：提示玩家选择给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 卡片确认：给对方确认选中的战士族怪兽
		Duel.ConfirmCards(1-tp,g)
		-- 洗牌：洗切玩家的手牌
		Duel.ShuffleHand(tp)
	else
		-- 破坏卡片：将此卡破坏作为未支付维持代价的惩罚
		Duel.Destroy(c,REASON_COST)
	end
end
-- 过滤函数：筛选场上由自己控制的或处于表侧表示的名字带有「核成」的怪兽
function c10060427.otfilter(c,tp)
	return c:IsSetCard(0x1d) and (c:IsControler(tp) or c:IsFaceup())
end
-- 召唤条件判定：判断该卡是否为7星以上怪兽，且玩家是否可以通过解放1只「核成」怪兽来进行通常召唤
function c10060427.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取卡片组：获取场上所有可以作为祭品解放的「核成」怪兽
	local mg=Duel.GetMatchingGroup(c10060427.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 条件判断：卡片等级为7星以上、所需的祭品下限不大于1、且场上存在可供解放的1只「核成」怪兽
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 召唤操作处理：选择场上1只「核成」怪兽，将其解放作为该卡通常召唤的祭品
function c10060427.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取卡片组：获取场上所有可以被解放的名字带有「核成」的怪兽
	local mg=Duel.GetMatchingGroup(c10060427.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 选择祭品：由玩家选择1只「核成」怪兽作为上级召唤的祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放怪兽：解放被选为祭品的怪兽并将其作为召唤素材
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 过滤函数：筛选墓地中名字带有「核成」且可以除外的卡
function c10060427.dfilter(c)
	return c:IsSetCard(0x1d) and c:IsAbleToRemoveAsCost()
end
-- 召唤成功时效果的 cost 函数：检测并从墓地中选择1张「核成」卡除外
function c10060427.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 可行性检测：判断当前自己墓地是否存在至少1张可以除外的「核成」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c10060427.dfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示信息：提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择卡片：由玩家从自己墓地选择1张「核成」卡
	local g=Duel.SelectMatchingCard(tp,c10060427.dfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 除外卡片：将所选卡片表侧表示除外作为效果发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 召唤成功时效果的 target 函数：验证并选择对方场上最多2张卡作为破坏对象
function c10060427.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 可行性检测：判断当前对方场上是否存在至少1张卡可以被选为效果对象
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示信息：提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对象：由玩家选择对方场上最多2张卡作为对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,2,nil)
	-- 设置操作信息：设置效果处理包含破坏，预计破坏的卡片数量为所选卡片的数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 召唤成功时效果的 operation 函数（效果处理）：破坏作为效果对象的对方场上的卡（最多2张）
function c10060427.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息：获取此效果的所有对象卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 破坏卡片：通过效果将仍与该效果存在联系的对象卡片破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
