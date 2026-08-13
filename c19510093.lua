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
	-- 为这张卡添加灵摆怪兽属性，使其可以作为灵摆卡在灵摆区域发动，并能进行灵摆召唤。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：自己场上有「超重武者」怪兽存在的场合才能发动。从卡组把1只「超重武者装留」怪兽加入手卡。
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
-- 灵摆效果的发动条件函数：检查自己场上是否存在表侧表示且属于「超重武者」系列的怪兽。
function c19510093.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己场上是否存在至少1张表侧表示且卡名含有「超重武者」的怪兽。
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,1,nil,0x9a)
end
-- 检索过滤函数：筛选出卡组中属于「超重武者装留」系列且能够加入手卡的怪兽。
function c19510093.thfilter(c)
	return c:IsSetCard(0x109a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 灵摆效果的发动目标函数：发动时检查卡组是否存在符合检索条件的卡，并设置处理信息为从卡组检索1张加入手卡。
function c19510093.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时检查卡组中是否存在至少1张符合条件的「超重武者装留」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c19510093.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息：本次处理为从卡组将1张卡加入手卡，具体卡在效果处理时确定，因此对象为nil。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 灵摆效果的实际处理：让玩家从卡组选择1张「超重武者装留」怪兽加入手卡，并让对方确认。
function c19510093.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家弹出选择提示“请选择要加入手牌的卡”，并写入选择消息缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张符合条件的「超重武者装留」怪兽。
	local g=Duel.SelectMatchingCard(tp,c19510093.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索到的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 怪兽效果①的发动条件函数：检查自己墓地不存在魔法·陷阱卡。
function c19510093.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己墓地没有魔法或陷阱卡存在。
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 送墓过滤函数：筛选手卡/卡组中卡号为3117804（超重武者 大弁庆-K）且能够送去墓地的卡。
function c19510093.tgfilter(c)
	return c:IsCode(3117804) and c:IsAbleToGrave()
end
-- 怪兽效果①的发动目标函数：发动时确认自己主要怪兽区有空位、这张卡能特殊召唤，且手卡/卡组存在可送去墓地的「超重武者 大弁庆-K」。
function c19510093.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在效果发动时检查自己主要怪兽区域是否存在可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 同时检查手卡·卡组中是否存在至少1张符合条件且能送去墓地的「超重武者 大弁庆-K」。
		and Duel.IsExistingMatchingCard(c19510093.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息：本次处理会将这张卡自身特殊召唤（确定的卡为c，数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置连锁处理信息：本次处理会从手卡·卡组把1张「超重武者 大弁庆-K」送去墓地，具体卡在效果处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 怪兽效果①的实际处理：从手卡/卡组选择1张「超重武者 大弁庆-K」送去墓地，成功且这张卡仍与效果关联时将其特殊召唤。
function c19510093.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取手卡·卡组中所有符合条件的「超重武者 大弁庆-K」，供后续选择。
	local g=Duel.GetMatchingGroup(c19510093.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	if #g==0 then return end
	-- 向玩家弹出选择提示“请选择要送去墓地的卡”，并写入选择消息缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	-- 将选择的卡送去墓地；若成功且该卡仍在墓地，继续执行特殊召唤处理。
	if Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE)
		and c:IsRelateToEffect(e) then
		-- 将这张卡以表侧攻击表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 怪兽效果②的发动条件函数：检查这张卡作为同调素材后以表侧表示加入额外卡组（即被同调召唤作为素材送去额外牌组）。
function c19510093.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() and r==REASON_SYNCHRO
end
-- 怪兽效果②的发动目标函数：发动时检查自己的灵摆区域是否有可用的空位。
function c19510093.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时检查自己灵摆区域的左或右是否存在空位。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 怪兽效果②的实际处理：若这张卡仍与效果关联，将其放置到自己的灵摆区域。
function c19510093.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡移动到自己的灵摆区域，以表侧表示放置，并立刻适用其效果（可发动灵摆效果）。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
