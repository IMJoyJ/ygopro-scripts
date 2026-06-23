--コアキメイル・ルークロード
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只战士族怪兽给对方观看。或者都不进行让这张卡破坏。这张卡可以把1只名字带有「核成」的怪兽解放作上级召唤。这张卡召唤成功时，可以把自己墓地存在的1张名字带有「核成」的卡从游戏中除外，对方场上存在的最多2张卡破坏。
function c10060427.initial_effect(c)
	-- 建立与「核成兽的钢核」（卡号36623431）的卡名关联，用于特定检索或效果检测
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
-- 维持代价（Maintenance Cost）的触发条件函数：检查当前回合玩家是否为控制者本人
function c10060427.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为当前卡片控制者
	return Duel.GetTurnPlayer()==tp
end
-- 手卡中「核成兽的钢核」的过滤条件函数：必须是手卡中的「核成兽的钢核」且能送去墓地
function c10060427.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 手卡中用于展示的战士族怪兽过滤条件函数：战士族怪兽且未处于公开状态
function c10060427.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_WARRIOR) and not c:IsPublic()
end
-- 维持代价（Maintenance Cost）的效果处理函数：玩家选择支付代价（送墓或展示手卡怪兽）或将此卡破坏
function c10060427.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 为被选中的当前卡片显示选为对象的动画提示
	Duel.HintSelection(Group.FromCards(c))
	-- 获取当前玩家手卡中所有符合送墓条件的「核成兽的钢核」
	local g1=Duel.GetMatchingGroup(c10060427.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取当前玩家手卡中所有未展示的战士族怪兽
	local g2=Duel.GetMatchingGroup(c10060427.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 当手卡中既有「核成兽的钢核」又有战士族怪兽时，玩家选择送墓、展示或破坏此卡
		select=Duel.SelectOption(tp,aux.Stringid(10060427,0),aux.Stringid(10060427,1),aux.Stringid(10060427,2))  --"选择一张「核成兽的钢核」送去墓地/选择一张战士族怪兽给对方观看/破坏「核成城主」"
	elseif g1:GetCount()>0 then
		-- 当手卡中只有「核成兽的钢核」时，玩家选择将其送墓或破坏此卡
		select=Duel.SelectOption(tp,aux.Stringid(10060427,0),aux.Stringid(10060427,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成城主」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 当手卡中只有战士族怪兽时，玩家选择将其展示或破坏此卡
		select=Duel.SelectOption(tp,aux.Stringid(10060427,1),aux.Stringid(10060427,2))+1  --"选择一张战士族怪兽给对方观看/破坏「核成城主」"
	else
		-- 当手卡中无可用卡时，玩家只能选择将此卡破坏
		select=Duel.SelectOption(tp,aux.Stringid(10060427,2))  --"破坏「核成城主」"
		select=2
	end
	if select==0 then
		-- 给玩家发送选择将卡片送去墓地的系统提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选择的「核成兽的钢核」作为维持代价送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 给玩家发送选择要向对方展示的卡片的系统提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 向对方玩家展示选择的战士族怪兽
		Duel.ConfirmCards(1-tp,g)
		-- 展示完毕后将当前玩家的手卡洗牌
		Duel.ShuffleHand(tp)
	else
		-- 若玩家未支付维持代价，将此卡破坏
		Duel.Destroy(c,REASON_COST)
	end
end
-- 用于上级召唤的解放怪兽过滤条件函数：必须是名字带有「核成」的怪兽
function c10060427.otfilter(c,tp)
	return c:IsSetCard(0x1d) and (c:IsControler(tp) or c:IsFaceup())
end
-- 上级召唤手续的条件检查函数：等级在7以上，至少需要1只名字带有「核成」的怪兽作为祭品进行通常召唤
function c10060427.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上可作为上级召唤解放怪兽的名字带有「核成」的怪兽组
	local mg=Duel.GetMatchingGroup(c10060427.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 检查当前召唤卡片等级在7以上，且场上存在可供解放的「核成」怪兽
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 上级召唤手续的选择与解放操作函数
function c10060427.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上所有名字带有「核成」的怪兽组
	local mg=Duel.GetMatchingGroup(c10060427.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家在怪兽组中选择1只作为上级召唤的祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将所选的祭品怪兽解放进行上级召唤
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 除外代价的过滤条件函数：墓地里名字带有「核成」的卡且可以被除外
function c10060427.dfilter(c)
	return c:IsSetCard(0x1d) and c:IsAbleToRemoveAsCost()
end
-- 效果③的除外代价（Cost）处理：从墓地将1张名字带有「核成」的卡除外
function c10060427.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点检查墓地中是否存在至少1张名字带有「核成」的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c10060427.dfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送选择除外卡片的系统提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从墓地选择1张名字带有「核成」的卡
	local g=Duel.SelectMatchingCard(tp,c10060427.dfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡片以表侧表示除外以支付发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果③的发动效果目标（Target）处理：选择对方场上最多2张卡作为破坏对象，并设定效果分类
function c10060427.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 在发动时点检查对方场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给玩家发送选择破坏卡的系统提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上的1至2张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,2,nil)
	-- 设置效果处理信息为破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果③的效果处理（Operation）函数：破坏选中的对方场上最多2张卡
function c10060427.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的目标卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 破坏仍在场上且与该效果有关联的对象卡片
		Duel.Destroy(g,REASON_EFFECT)
	end
end
