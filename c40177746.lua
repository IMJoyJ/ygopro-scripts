--イーバ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡被送去墓地的场合，把这张卡以外的自己的场上·墓地最多2只天使族·光属性怪兽除外才能发动。把除外数量的「地外生命」以外的2星以下的天使族·光属性怪兽从卡组加入手卡（同名卡最多1张）。
function c40177746.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡被送去墓地的场合，把这张卡以外的自己的场上·墓地最多2只天使族·光属性怪兽除外才能发动。把除外数量的「地外生命」以外的2星以下的天使族·光属性怪兽从卡组加入手卡（同名卡最多1张）。
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
-- 筛选可作为发动代价除外的卡：本方场上表侧表示或墓地中的卡，须为天使族·光属性，且可以作为代价除外。
function c40177746.cfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemoveAsCost()
end
-- 筛选检索目标的卡：等级2以下的天使族·光属性怪兽，卡名不是「地外生命」，且可以被加入手卡。
function c40177746.filter(c)
	return c:IsLevelBelow(2) and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT) and not c:IsCode(40177746) and c:IsAbleToHand()
end
-- 效果发动条件判定部分：当进行合法性检查（chk==0）时，确认本方场上有可除外代价的怪兽且卡组中有可检索的目标卡，满足才可发动。
function c40177746.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本方场上（表侧表示）或墓地是否存在至少1只满足除外代价条件的怪兽（天使族·光属性且可作为代价除外），且不包含本卡自身。
	if chk==0 then return Duel.IsExistingMatchingCard(c40177746.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,e:GetHandler())
		-- 检查卡组是否存在至少1只满足检索条件的卡（等级2以下天使族·光属性、不是「地外生命」、可以加入手卡）。
		and Duel.IsExistingMatchingCard(c40177746.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 获取卡组中所有满足检索条件的卡（等级2以下、天使族、光属性、非「地外生命」、可加入手卡）的集合。
	local dg=Duel.GetMatchingGroup(c40177746.filter,tp,LOCATION_DECK,0,nil)
	local ct=math.min(2,dg:GetClassCount(Card.GetCode))
	-- 给玩家发送选择提示，提示内容为‘请选择要除外的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从本方场上表侧表示或墓地的可除外怪兽中选择1到ct张作为发动代价（ct为之前计算的检索数量上限，最多2），不能选择本卡自身。
	local rg=Duel.SelectMatchingCard(tp,c40177746.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,ct,e:GetHandler())
	-- 将选中的卡片正面表示除外，原因标记为REASON_COST（作为发动代价），并返回实际除外的数量rc。
	local rc=Duel.Remove(rg,POS_FACEUP,REASON_COST)
	e:SetLabel(rc)
	-- 设置效果处理信息：本次效果将把rc张卡从卡组加入手卡（CATEGORY_TOHAND），目标玩家为tp，来源位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,rc,tp,LOCATION_DECK)
end
-- 效果处理：根据除外数量，从卡组选取相应数量的、卡名互不相同的检索目标卡加入手卡，并向对方展示。
function c40177746.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理中再次获取卡组中所有满足检索条件的卡集合。
	local dg=Duel.GetMatchingGroup(c40177746.filter,tp,LOCATION_DECK,0,nil)
	local ct=e:GetLabel()
	if dg:GetClassCount(Card.GetCode)<ct then return end
	-- 给玩家发送选择提示，提示内容为‘请选择要加入手牌的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从检索候选组中选出ct张卡，并要求这些卡卡名互不相同（通过aux.dncheck检查），选择不可取消。
	local g=dg:SelectSubGroup(tp,aux.dncheck,false,ct,ct)
	-- 将选中的卡加入其持有者的手卡，原因标记为REASON_EFFECT（效果处理）。
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 向对方玩家展示本次加入手卡的卡。
	Duel.ConfirmCards(1-tp,g)
end
