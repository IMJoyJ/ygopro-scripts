--悪王アフリマ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张「黯黑世界-暗影敌托邦-」加入手卡。
-- ②：把自己场上1只暗属性怪兽解放才能发动。自己从卡组抽1张。为这个效果发动而把这张卡以外的暗属性怪兽解放的场合，可以作为抽卡的代替而从卡组把1只守备力2000以上的暗属性怪兽加入手卡。
function c86377375.initial_effect(c)
	-- 注册卡片关联密码，表示本卡效果中记载了「黯黑世界-暗影敌托邦-」的卡名
	aux.AddCodeList(c,59160188)
	-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张「黯黑世界-暗影敌托邦-」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86377375,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c86377375.thcost)
	e1:SetTarget(c86377375.thtg)
	e1:SetOperation(c86377375.thop)
	c:RegisterEffect(e1)
	-- ②：把自己场上1只暗属性怪兽解放才能发动。自己从卡组抽1张。为这个效果发动而把这张卡以外的暗属性怪兽解放的场合，可以作为抽卡的代替而从卡组把1只守备力2000以上的暗属性怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86377375,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,86377375)
	e2:SetCost(c86377375.drcost)
	e2:SetTarget(c86377375.drtg)
	e2:SetOperation(c86377375.drop)
	c:RegisterEffect(e2)
end
-- 效果①的发动代价（Cost）函数：把这张卡从手卡丢弃
function c86377375.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 作为发动代价，将这张卡从手牌丢弃送去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 效果①的检索过滤条件：卡名为「黯黑世界-暗影敌托邦-」且能加入手卡
function c86377375.thfilter1(c)
	return c:IsCode(59160188) and c:IsAbleToHand()
end
-- 效果①的发动准备（Target）函数
function c86377375.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「黯黑世界-暗影敌托邦-」
	if chk==0 then return Duel.IsExistingMatchingCard(c86377375.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果的处理包含“从卡组将1张卡加入手牌”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（Operation）函数
function c86377375.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中第一张满足条件的「黯黑世界-暗影敌托邦-」
	local tg=Duel.GetFirstMatchingCard(c86377375.thfilter1,tp,LOCATION_DECK,0,nil)
	if tg then
		-- 将目标卡片加入手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tg)
	end
end
-- 效果②代替抽卡时的检索过滤条件：守备力2000以上的暗属性怪兽且能加入手卡
function c86377375.thfilter2(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsDefenseAbove(2000) and c:IsAbleToHand()
end
-- 效果②的发动代价（Cost）函数：解放自己场上1只暗属性怪兽
function c86377375.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否可以解放场上任意暗属性怪兽且自身可以抽卡
	if chk==0 then return ((Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,nil,ATTRIBUTE_DARK) and Duel.IsPlayerCanDraw(tp,1))
		-- 或者检查是否可以解放这张卡以外的暗属性怪兽，且卡组中存在可检索的守备力2000以上的暗属性怪兽
		or (Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,c,ATTRIBUTE_DARK) and Duel.IsExistingMatchingCard(c86377375.thfilter2,tp,LOCATION_DECK,0,1,nil))) end
	local sg=nil
	-- 如果卡组有符合检索条件的怪兽，但玩家此时无法抽卡，则强制必须解放这张卡以外的暗属性怪兽以进行代替检索
	if Duel.IsExistingMatchingCard(c86377375.thfilter2,tp,LOCATION_DECK,0,1,nil) and not Duel.IsPlayerCanDraw(tp,1) then
		-- 选择解放这张卡以外的1只暗属性怪兽
		sg=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,c,ATTRIBUTE_DARK)
	else
		-- 选择解放包含这张卡在内的任意1只暗属性怪兽
		sg=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,nil,ATTRIBUTE_DARK)
	end
	e:SetLabelObject(sg:GetFirst())
	-- 解放选中的怪兽
	Duel.Release(sg,REASON_COST)
end
-- 效果②的发动准备（Target）函数
function c86377375.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:GetLabelObject()~=e:GetHandler() then
		e:SetCategory(CATEGORY_DRAW+CATEGORY_TOHAND+CATEGORY_SEARCH)
	end
	-- 设置效果处理的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的参数为1（抽卡数量）
	Duel.SetTargetParam(1)
	-- 设置连锁信息，表示该效果的基本处理为“抽1张卡”
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的效果处理（Operation）函数
function c86377375.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断解放的是否为这张卡以外的怪兽，且卡组中存在符合检索条件的怪兽
	if e:GetLabelObject()~=e:GetHandler() and Duel.IsExistingMatchingCard(c86377375.thfilter2,tp,LOCATION_DECK,0,1,nil)
		-- 如果无法抽卡，或者玩家主动选择进行代替抽卡的效果
		and (not Duel.IsPlayerCanDraw(tp,1) or Duel.SelectYesNo(tp,aux.Stringid(86377375,2))) then  --"是否作为抽卡的代替从卡组检索？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1只守备力2000以上的暗属性怪兽
		local g=Duel.SelectMatchingCard(tp,c86377375.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的怪兽加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 让对方玩家确认加入手牌的怪兽
			Duel.ConfirmCards(1-tp,g)
		end
	else
		-- 获取抽卡效果的对象玩家和抽卡张数
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 执行抽卡效果
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
