--薔薇占術師
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把这张卡解放才能发动。自己从卡组抽1张。
-- ②：把墓地的这张卡除外，以自己墓地1只植物族怪兽为对象才能发动。那只怪兽加入手卡。这个效果把原本等级是7星以上的植物族怪兽加入手卡的场合，可以再从卡组把1只植物族怪兽送去墓地。
function c2752099.initial_effect(c)
	-- ①：把这张卡解放才能发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2752099,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,2752099)
	e1:SetCost(c2752099.drcost)
	e1:SetTarget(c2752099.drtg)
	e1:SetOperation(c2752099.drop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只植物族怪兽为对象才能发动。那只怪兽加入手卡。这个效果把原本等级是7星以上的植物族怪兽加入手卡的场合，可以再从卡组把1只植物族怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2752099,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,2752099)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c2752099.thtg)
	e2:SetOperation(c2752099.thop)
	c:RegisterEffect(e2)
end
-- 将此卡解放作为费用
function c2752099.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡从场上解放
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 设置效果对象为自身玩家并设置抽卡数量为1
function c2752099.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁效果的对象玩家为使用者
	Duel.SetTargetPlayer(tp)
	-- 设置连锁效果的对象参数为1
	Duel.SetTargetParam(1)
	-- 设置效果处理信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理效果抽卡
function c2752099.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁效果的对象玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤函数，用于筛选植物族且能加入手牌的怪兽
function c2752099.thfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToHand()
end
-- 过滤函数，用于筛选植物族且能送去墓地的怪兽
function c2752099.tgfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToGrave()
end
-- 设置效果目标为墓地的植物族怪兽
function c2752099.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c2752099.thfilter(chkc) end
	-- 检查是否存在满足条件的墓地植物族怪兽
	if chk==0 then return Duel.IsExistingTarget(c2752099.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c2752099.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为将怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理效果将怪兽加入手牌并判断是否满足额外效果条件
function c2752099.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 将目标怪兽加入手牌
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
	if tc:IsLocation(LOCATION_HAND) and tc:GetOriginalLevel()>=7
		-- 检查卡组是否存在植物族怪兽
		and Duel.IsExistingMatchingCard(c2752099.tgfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否发动额外效果
		and Duel.SelectYesNo(tp,aux.Stringid(2752099,2)) then  --"是否再从卡组把1只植物族怪兽送去墓地？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择要送去墓地的卡
		local tg=Duel.SelectMatchingCard(tp,c2752099.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end
