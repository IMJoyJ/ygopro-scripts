--戦華盟将－双龍
-- 效果：
-- 包含风属性「战华」怪兽的兽战士族怪兽2只
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1张「战华」卡加入手卡。
-- ②：自己场上的「战华」怪兽的攻击力·守备力上升500。
-- ③：从自己的手卡·场上把1张卡送去墓地，以对方场上1张表侧表示的卡为对象才能发动。那张卡回到持有者手卡。这个效果在对方回合也能发动。
function c65711558.initial_effect(c)
	-- 设置连接召唤手续：兽战士族怪兽2只，且必须包含满足lcheck过滤条件的怪兽（即风属性「战华」怪兽）
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_BEASTWARRIOR),2,2,c65711558.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1张「战华」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65711558,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,65711558)
	e1:SetCondition(c65711558.srcon)
	e1:SetTarget(c65711558.srtg)
	e1:SetOperation(c65711558.srop)
	c:RegisterEffect(e1)
	-- ②：自己场上的「战华」怪兽的攻击力·守备力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c65711558.atktg)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ③：从自己的手卡·场上把1张卡送去墓地，以对方场上1张表侧表示的卡为对象才能发动。那张卡回到持有者手卡。这个效果在对方回合也能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(65711558,1))  --"回到手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCountLimit(1,65711559)
	e4:SetCost(c65711558.thcost)
	e4:SetTarget(c65711558.thtg)
	e4:SetOperation(c65711558.thop)
	c:RegisterEffect(e4)
end
-- 过滤连接素材：风属性且属于「战华」系列的卡
function c65711558.matfilter(c)
	return c:IsLinkAttribute(ATTRIBUTE_WIND) and c:IsLinkSetCard(0x137)
end
-- 检查连接素材组中是否至少存在1张满足matfilter过滤条件（风属性「战华」）的怪兽
function c65711558.lcheck(g,lc)
	return g:IsExists(c65711558.matfilter,1,nil)
end
-- 效果①的发动条件：这张卡是通过连接召唤特殊召唤的
function c65711558.srcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤检索目标：卡组中属于「战华」系列且能加入手牌的卡
function c65711558.srfilter(c)
	return c:IsSetCard(0x137) and c:IsAbleToHand()
end
-- 效果①的发动准备（检查卡组中是否存在可检索的「战华」卡，并设置检索的操作信息）
function c65711558.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1张满足过滤条件的「战华」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c65711558.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组选择1张「战华」卡加入手牌并给对方确认
function c65711558.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「战华」卡
	local g=Duel.SelectMatchingCard(tp,c65711558.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤攻击力/守备力上升效果的对象：自己场上的「战华」怪兽
function c65711558.atktg(e,c)
	return c:IsSetCard(0x137)
end
-- 过滤效果③的目标卡片：对方场上表侧表示、可回到手牌，且不等于作为cost送去墓地的装备卡（若cost是装备卡）
function c65711558.tgfilter(c,ec)
	return c65711558.thfilter(c) and c:GetEquipTarget()~=ec
end
-- 过滤效果③的cost卡片：自己手牌或场上可以送去墓地，且在送去墓地后对方场上仍存在可作为效果③对象的卡
function c65711558.costfilter(c,tp)
	-- 检查卡片是否能作为cost送去墓地，且此时对方场上是否存在至少1张可作为效果③对象的卡（排除自身作为装备卡的情况）
	return c:IsAbleToGraveAsCost() and Duel.IsExistingTarget(c65711558.tgfilter,tp,0,LOCATION_ONFIELD,1,nil,c)
end
-- 效果③的发动代价（cost）：从自己的手牌或场上选择1张卡送去墓地
function c65711558.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌或场上是否存在可作为cost送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c65711558.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手牌或场上选择1张满足cost条件的卡
	local g=Duel.SelectMatchingCard(tp,c65711558.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 将选择的卡作为发动代价（cost）送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤效果③的目标：场上表侧表示且能回到手牌的卡
function c65711558.thfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 效果③的发动准备（选择对方场上1张表侧表示的卡作为对象，并设置回手牌的操作信息）
function c65711558.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c65711558.thfilter(chkc) end
	-- 检查对方场上是否存在至少1张满足过滤条件的表侧表示卡片
	if chk==0 then return Duel.IsExistingTarget(c65711558.thfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择对方场上1张满足过滤条件的表侧表示卡片作为效果对象
	local g=Duel.SelectTarget(tp,c65711558.thfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁的操作信息：将选中的对象卡片送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果③的效果处理：使作为对象的卡片回到持有者手牌
function c65711558.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡片因效果送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
