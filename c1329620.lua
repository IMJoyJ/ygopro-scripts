--壱世壊に澄み渡る残響
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「珠泪哀歌族」怪兽或者「维萨斯-斯塔弗罗斯特」存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效，那张卡回到持有者卡组。那之后，从自己手卡选1只怪兽送去墓地。
-- ②：这张卡被效果送去墓地的场合，以除外的1只自己的「珠泪哀歌族」怪兽为对象才能发动。那只怪兽加入手卡。
function c1329620.initial_effect(c)
	-- 为卡片注册与「维萨斯-斯塔弗罗斯特」相关的卡片代码，用于后续效果判断
	aux.AddCodeList(c,56099748)
	-- ①：自己场上有「珠泪哀歌族」怪兽或者「维萨斯-斯塔弗罗斯特」存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效，那张卡回到持有者卡组。那之后，从自己手卡选1只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,1329620)
	e1:SetCondition(c1329620.condition)
	e1:SetTarget(c1329620.target)
	e1:SetOperation(c1329620.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合，以除外的1只自己的「珠泪哀歌族」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,1329620)
	e2:SetCondition(c1329620.thcon)
	e2:SetTarget(c1329620.thtg)
	e2:SetOperation(c1329620.thop)
	c:RegisterEffect(e2)
end
-- 定义用于判断场上是否存在「珠泪哀歌族」怪兽或「维萨斯-斯塔弗罗斯特」的过滤函数
function c1329620.actcfilter(c)
	return ((c:IsSetCard(0x181) and c:IsLocation(LOCATION_MZONE)) or c:IsCode(56099748)) and c:IsFaceup()
end
-- 定义效果①的发动条件判断函数
function c1329620.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断发动的卡是否为怪兽效果或魔法/陷阱卡发动
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
		-- 判断自己场上是否存在「珠泪哀歌族」怪兽或「维萨斯-斯塔弗罗斯特」
		and Duel.IsExistingMatchingCard(c1329620.actcfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 定义用于判断手牌中是否存在可送去墓地的怪兽的过滤函数
function c1329620.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 定义效果①的发动时处理函数
function c1329620.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即手牌中存在可送去墓地的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c1329620.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置连锁处理时的无效效果操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁处理时的回卡组效果操作信息
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
	-- 设置连锁处理时的送去墓地效果操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- 定义效果①的发动处理函数
function c1329620.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	-- 使连锁发动无效并判断目标卡是否在场
	if Duel.NegateActivation(ev) and ec:IsRelateToEffect(re) then
		ec:CancelToGrave()
		-- 将无效的卡送回卡组并判断是否成功送回
		if Duel.SendtoDeck(ec,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and ec:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
			-- 提示玩家选择要送去墓地的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			-- 选择手牌中满足条件的怪兽
			local g=Duel.SelectMatchingCard(tp,c1329620.cfilter,tp,LOCATION_HAND,0,1,1,nil)
			if #g>0 then
				-- 中断当前效果处理，使后续处理视为错时点
				Duel.BreakEffect()
				-- 将选择的怪兽送去墓地
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
		end
	end
end
-- 定义效果②的发动条件判断函数
function c1329620.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 定义用于判断除外区是否存在符合条件的「珠泪哀歌族」怪兽的过滤函数
function c1329620.thfilter(c)
	return c:IsSetCard(0x181) and c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsAbleToHand()
end
-- 定义效果②的发动时处理函数
function c1329620.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c1329620.thfilter(chkc) end
	-- 检查是否满足发动条件，即除外区存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c1329620.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择除外区中符合条件的怪兽
	local g=Duel.SelectTarget(tp,c1329620.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置连锁处理时的加入手牌效果操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 定义效果②的发动处理函数
function c1329620.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
