--ブロックドラゴン
-- 效果：
-- 这张卡不能通常召唤。把自己的手卡·墓地3只地属性怪兽除外的场合才能从手卡·墓地特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己场上的岩石族怪兽不会被战斗以外破坏。
-- ②：这张卡从场上送去墓地的场合才能发动。等级合计直到变成8星为止，从卡组把最多3只岩石族怪兽加入手卡。
function c94689206.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己的手卡·墓地3只地属性怪兽除外的场合才能从手卡·墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCondition(c94689206.spcon)
	e2:SetTarget(c94689206.sptg)
	e2:SetOperation(c94689206.spop)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在怪兽区域存在，自己场上的岩石族怪兽不会被战斗以外破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 过滤出场上的岩石族怪兽作为该永续效果的适用对象
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ROCK))
	e3:SetValue(c94689206.indesval)
	c:RegisterEffect(e3)
	-- ②：这张卡从场上送去墓地的场合才能发动。等级合计直到变成8星为止，从卡组把最多3只岩石族怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(94689206,0))  --"加入手卡"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,94689206)
	e4:SetCondition(c94689206.thcon)
	e4:SetTarget(c94689206.thtg)
	e4:SetOperation(c94689206.thop)
	c:RegisterEffect(e4)
end
-- 过滤自身特殊召唤所需除外的地属性怪兽
function c94689206.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则的条件判断：检查怪兽区域是否有空位，以及手卡·墓地是否存在3只地属性怪兽
function c94689206.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡·墓地是否存在至少3只可以作为Cost除外的地属性怪兽（排除自身）
		and Duel.IsExistingMatchingCard(c94689206.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,3,c)
end
-- 特殊召唤规则的准备阶段：从手卡·墓地选择3只地属性怪兽，并将其保存为标签对象
function c94689206.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己手卡·墓地中所有满足除外条件的地属性怪兽
	local g=Duel.GetMatchingGroup(c94689206.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,c)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,3,3,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行阶段：将选中的3只怪兽除外，并完成特殊召唤
function c94689206.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽以特殊召唤的Cost为原因表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 破坏代替的判定函数：当破坏原因不是规则破坏或战斗破坏（即效果破坏）时返回true
function c94689206.indesval(e,re,r,rp)
	return bit.band(r,REASON_RULE+REASON_BATTLE)==0
end
-- 检索效果的发动条件：检查这张卡此前是否在场上存在
function c94689206.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组中可以加入手卡的岩石族怪兽
function c94689206.thfilter(c)
	return c:IsRace(RACE_ROCK) and c:IsAbleToHand()
end
-- 检索效果的发动准备：检查卡组中是否存在等级合计为8的最多3只岩石族怪兽，并设置操作信息
function c94689206.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组中所有可以加入手卡的岩石族怪兽
	local g=Duel.GetMatchingGroup(c94689206.thfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:CheckWithSumEqual(Card.GetLevel,8,1,3) end
	-- 设置连锁处理的操作信息，表示该效果会将卡组的卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行：从卡组选择等级合计为8的最多3只岩石族怪兽加入手卡，并向对方展示
function c94689206.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有可以加入手卡的岩石族怪兽
	local g=Duel.GetMatchingGroup(c94689206.thfilter,tp,LOCATION_DECK,0,nil)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local sg=g:SelectWithSumEqual(tp,Card.GetLevel,8,1,3)
	if sg and sg:GetCount()>0 then
		-- 将选中的怪兽因效果加入玩家手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
