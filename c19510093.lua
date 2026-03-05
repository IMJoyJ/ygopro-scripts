--超重僧兵ビッグベン－K
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己场上有「超重武者」怪兽存在的场合才能发动。从卡组把1只「超重武者装留」怪兽加入手卡。
-- 【怪兽效果】
-- 这个卡名在规则上也当作「超重武者」卡使用。这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：自己墓地没有魔法·陷阱卡存在的场合才能发动。从手卡·卡组把1只「超重武者 大弁庆-K」送去墓地，这张卡从手卡特殊召唤。
-- ②：这张卡作为同调素材表侧表示加入额外卡组的场合才能发动。这张卡在自己的灵摆区域放置。
function c19510093.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上有「超重武者」怪兽存在的场合才能发动。从卡组把1只「超重武者装留」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19510093,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,19510093)
	e1:SetCondition(c19510093.thcon)
	e1:SetTarget(c19510093.thtg)
	e1:SetOperation(c19510093.thop)
	c:RegisterEffect(e1)
	-- ①：自己墓地没有魔法·陷阱卡存在的场合才能发动。从手卡·卡组把1只「超重武者 大弁庆-K」送去墓地，这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19510093,1))  --"这张卡从手卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,19510094)
	e2:SetCondition(c19510093.spcon)
	e2:SetTarget(c19510093.sptg)
	e2:SetOperation(c19510093.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡作为同调素材表侧表示加入额外卡组的场合才能发动。这张卡在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,19510095)
	e3:SetCondition(c19510093.pencon)
	e3:SetTarget(c19510093.pentg)
	e3:SetOperation(c19510093.penop)
	c:RegisterEffect(e3)
end
-- 判断自己场上是否存在「超重武者」怪兽
function c19510093.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只「超重武者」怪兽
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,1,nil,0x9a)
end
-- 定义检索过滤器，用于筛选「超重武者装留」怪兽
function c19510093.thfilter(c)
	return c:IsSetCard(0x109a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置灵摆效果的处理目标，指定从卡组检索1张「超重武者装留」怪兽加入手牌
function c19510093.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在满足条件的「超重武者装留」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c19510093.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行灵摆效果的处理，选择并把符合条件的卡加入手牌
function c19510093.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c19510093.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断自己墓地是否存在魔法·陷阱卡
function c19510093.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否不存在魔法·陷阱卡
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 定义特殊召唤时需要送入墓地的卡的过滤器
function c19510093.tgfilter(c)
	return c:IsCode(3117804) and c:IsAbleToGrave()
end
-- 设置特殊召唤效果的处理目标，指定将自己特殊召唤并送入墓地1张「超重武者 大弁庆-K」
function c19510093.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己手牌或卡组是否存在满足条件的「超重武者 大弁庆-K」
		and Duel.IsExistingMatchingCard(c19510093.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置连锁操作信息，表示将送入墓地1张卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 执行特殊召唤效果的处理，选择并送入墓地1张「超重武者 大弁庆-K」，然后特殊召唤自己
function c19510093.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己手牌或卡组中所有满足条件的「超重武者 大弁庆-K」
	local g=Duel.GetMatchingGroup(c19510093.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	if #g==0 then return end
	-- 提示玩家选择要送入墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	-- 将选中的卡送入墓地并确认其位置
	if Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE)
		and c:IsRelateToEffect(e) then
		-- 将自己从手牌特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断自己是否作为同调素材加入额外卡组
function c19510093.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() and r==REASON_SYNCHRO
end
-- 设置灵摆区域放置效果的处理目标，判断是否可以放置到灵摆区域
function c19510093.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 执行灵摆区域放置效果的处理，将自己移动到灵摆区域
function c19510093.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自己移动到玩家的灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
