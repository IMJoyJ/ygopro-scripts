--イーバ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡被送去墓地的场合，把这张卡以外的自己的场上·墓地最多2只天使族·光属性怪兽除外才能发动。把除外数量的「地外生命」以外的2星以下的天使族·光属性怪兽从卡组加入手卡（同名卡最多1张）。
function c40177746.initial_effect(c)
	-- 效果原文内容：①：这张卡被送去墓地的场合，把这张卡以外的自己的场上·墓地最多2只天使族·光属性怪兽除外才能发动。把除外数量的「地外生命」以外的2星以下的天使族·光属性怪兽从卡组加入手卡（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40177746,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,40177746)
	e1:SetTarget(c40177746.thtg)
	e1:SetOperation(c40177746.thop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断场上或墓地的天使族·光属性怪兽是否可以作为除外的代价
function c40177746.cfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemoveAsCost()
end
-- 过滤函数，用于判断卡组中2星以下的天使族·光属性怪兽是否可以加入手牌
function c40177746.filter(c)
	return c:IsLevelBelow(2) and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT) and not c:IsCode(40177746) and c:IsAbleToHand()
end
-- 效果的发动时点处理函数，用于判断是否满足发动条件
function c40177746.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上或墓地是否存在至少1只满足条件的天使族·光属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c40177746.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,e:GetHandler())
		-- 判断自己卡组中是否存在至少1张满足条件的2星以下的天使族·光属性怪兽
		and Duel.IsExistingMatchingCard(c40177746.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 获取卡组中所有满足条件的2星以下的天使族·光属性怪兽
	local dg=Duel.GetMatchingGroup(c40177746.filter,tp,LOCATION_DECK,0,nil)
	local ct=math.min(2,dg:GetClassCount(Card.GetCode))
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上或墓地的天使族·光属性怪兽进行除外
	local rg=Duel.SelectMatchingCard(tp,c40177746.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,ct,e:GetHandler())
	-- 将选中的怪兽除外，并返回实际除外的数量
	local rc=Duel.Remove(rg,POS_FACEUP,REASON_COST)
	e:SetLabel(rc)
	-- 设置效果处理时的操作信息，表示将要从卡组检索怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,rc,tp,LOCATION_DECK)
end
-- 效果的处理函数，用于执行效果的后续处理
function c40177746.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足条件的2星以下的天使族·光属性怪兽
	local dg=Duel.GetMatchingGroup(c40177746.filter,tp,LOCATION_DECK,0,nil)
	local ct=e:GetLabel()
	if dg:GetClassCount(Card.GetCode)<ct then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从满足条件的卡中选择指定数量且卡名不同的怪兽
	local g=dg:SelectSubGroup(tp,aux.dncheck,false,ct,ct)
	-- 将选中的怪兽加入手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 向对方确认手牌内容
	Duel.ConfirmCards(1-tp,g)
end
