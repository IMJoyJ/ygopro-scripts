--コアキメイル・ルークロード
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只战士族怪兽给对方观看。或者都不进行让这张卡破坏。这张卡可以把1只名字带有「核成」的怪兽解放作上级召唤。这张卡召唤成功时，可以把自己墓地存在的1张名字带有「核成」的卡从游戏中除外，对方场上存在的最多2张卡破坏。
function c10060427.initial_effect(c)
	-- 在卡片的关联卡片列表中注册「核成兽的钢核」（卡号36623431）
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
-- 维持效果的发动条件：当前回合玩家是这张卡的控制者
function c10060427.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否是自己的控制者
	return Duel.GetTurnPlayer()==tp
end
-- 钢核过滤条件：卡名为「核成兽的钢核」（卡号36623431）且能作为费用送去墓地
function c10060427.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 战士族过滤条件：手卡中表侧表示以外的战士族怪兽
function c10060427.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_WARRIOR) and not c:IsPublic()
end
-- 维持效果的执行：根据手牌情况让玩家选择将「核成兽的钢核」送去墓地、或者展示战士族怪兽、或者都不进行将该卡破坏
function c10060427.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 手动为这张卡显示被选为维持效果对象的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 获取自己手牌中所有满足 cfilter1 过滤条件的卡片组
	local g1=Duel.GetMatchingGroup(c10060427.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取自己手牌中所有满足 cfilter2 过滤条件的卡片组
	local g2=Duel.GetMatchingGroup(c10060427.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 让玩家选择“送去墓地/展示/破坏”中的一个选项
		select=Duel.SelectOption(tp,aux.Stringid(10060427,0),aux.Stringid(10060427,1),aux.Stringid(10060427,2))  --"选择一张「核成兽的钢核」送去墓地/选择一张战士族怪兽给对方观看/破坏「核成城主」"
	elseif g1:GetCount()>0 then
		-- 让玩家选择“送去墓地/破坏”中的一个选项
		select=Duel.SelectOption(tp,aux.Stringid(10060427,0),aux.Stringid(10060427,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成城主」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 让玩家选择“展示/破坏”中的一个选项
		select=Duel.SelectOption(tp,aux.Stringid(10060427,1),aux.Stringid(10060427,2))+1  --"选择一张战士族怪兽给对方观看/破坏「核成城主」"
	else
		-- 让玩家选择是否破坏自身
		select=Duel.SelectOption(tp,aux.Stringid(10060427,2))  --"破坏「核成城主」"
		select=2
	end
	if select==0 then
		-- 在提示框显示“请选择要送去墓地的卡”的系统提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 以费用原因将选中的卡片送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 在提示框显示“请选择给对方确认的卡”的系统提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 将选中的战士族怪兽向对方展示以进行确认
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的手卡
		Duel.ShuffleHand(tp)
	else
		-- 以费用原因为原因破坏这张卡
		Duel.Destroy(c,REASON_COST)
	end
end
-- 上级召唤素材过滤条件：名字带有「核成」的怪兽，若在场上则必须表侧表示
function c10060427.otfilter(c,tp)
	return c:IsSetCard(0x1d) and (c:IsControler(tp) or c:IsFaceup())
end
-- 上级召唤的发动条件：自身是7星以上怪兽、所需的解放数量为1且场上存在符合解放条件的核成怪兽
function c10060427.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上所有符合 otfilter 过滤条件的怪兽卡片组
	local mg=Duel.GetMatchingGroup(c10060427.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 返回是否可以以1张符合条件的怪兽作为祭品进行通常召唤
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 上级召唤的解放操作：玩家选择1只符合条件的「核成」怪兽解放，并将该解放怪兽作为召唤的素材
function c10060427.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上所有符合 otfilter 过滤条件的怪兽卡片组
	local mg=Duel.GetMatchingGroup(c10060427.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家选择1只符合召唤素材条件的怪兽解放
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 以通常召唤素材为原因解放所选的怪兽
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 除外卡片过滤条件：名字带有「核成」的卡且可以被除外
function c10060427.dfilter(c)
	return c:IsSetCard(0x1d) and c:IsAbleToRemoveAsCost()
end
-- 破坏效果的发动费用：检查墓地中是否存在满足条件的核成卡，并从墓地中选择1张卡表侧表示除外
function c10060427.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地中是否存在至少1张满足 dfilter 过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c10060427.dfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 在提示框显示“请选择要除外的卡”的系统提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从墓地中选择1张满足 dfilter 过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c10060427.dfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 以费用原因将选中的卡片表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 破坏效果的发动准备：以对方场上最多2张卡为对象才能发动，并向系统注册破坏的操作信息
function c10060427.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在至少1张卡可以作为效果对象
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 在提示框显示“请选择要破坏的卡”的系统提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1到2张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,2,nil)
	-- 向系统注册当前连锁的操作信息：效果分类为破坏，目标卡片为选中的卡片组g，数量为所选卡片的数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的执行：获取所有被选为对象的卡，将其中与当前效果有联系的卡片破坏
function c10060427.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的所有卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 以效果原因为原因破坏所选的卡片组g
		Duel.Destroy(g,REASON_EFFECT)
	end
end
