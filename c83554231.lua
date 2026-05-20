--転生炎獣の再起
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地2只卡名不同的「转生炎兽」怪兽为对象才能发动。那些怪兽加入手卡。
-- ②：盖放的这张卡被效果破坏送去墓地的场合才能发动。从卡组把「转生炎兽的再起」以外的1张「转生炎兽」魔法·陷阱卡加入手卡。
function c83554231.initial_effect(c)
	-- ①：以自己墓地2只卡名不同的「转生炎兽」怪兽为对象才能发动。那些怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,83554231)
	e1:SetTarget(c83554231.target)
	e1:SetOperation(c83554231.activate)
	c:RegisterEffect(e1)
	-- ②：盖放的这张卡被效果破坏送去墓地的场合才能发动。从卡组把「转生炎兽的再起」以外的1张「转生炎兽」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83554231,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,83554232)
	e2:SetCondition(c83554231.thcon)
	e2:SetTarget(c83554231.thtg)
	e2:SetOperation(c83554231.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地的「转生炎兽」怪兽，且可以加入手卡、可以作为效果对象
function c83554231.thfilter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x119) and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
-- ①号效果的发动准备与对象选择
function c83554231.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c83554231.thfilter(chkc,e) end
	-- 获取自己墓地所有满足过滤条件的「转生炎兽」怪兽
	local g=Duel.GetMatchingGroup(c83554231.thfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=2 end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从符合条件的卡片中选择2张卡名不同的卡
	local g1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	-- 将选择的卡片作为效果处理的对象
	Duel.SetTargetCard(g1)
	-- 设置操作信息，表示此连锁的效果处理为将这2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- ①号效果的处理：将作为对象的怪兽加入手牌
function c83554231.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将仍符合条件的卡片因效果加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
-- ②号效果的发动条件：盖放的这张卡被效果破坏送去墓地
function c83554231.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,0x41)==0x41 and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 过滤条件：卡组中「转生炎兽的再起」以外的「转生炎兽」魔法·陷阱卡，且可以加入手卡
function c83554231.filter(c)
	return c:IsSetCard(0x119) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(83554231) and c:IsAbleToHand()
end
-- ②号效果的发动准备
function c83554231.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c83554231.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此连锁的效果处理为从卡组将1张卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②号效果的处理：从卡组检索1张「转生炎兽」魔陷加入手牌
function c83554231.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足过滤条件的卡片
	local g=Duel.SelectMatchingCard(tp,c83554231.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
