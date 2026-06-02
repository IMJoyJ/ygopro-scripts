--Pumpking the Great Ghost King
-- 效果：
-- 6星不死族怪兽×2
-- 只要自己场上有「活死人的呼声」存在，对方不能把自己场上的不死族怪兽作为怪兽的效果的对象。
-- 「幽灵大王-南瓜王-」的以下效果1回合各能使用1次。
-- 这张卡特殊召唤的场合：可以从卡组把1张「活死人的呼声」或者有那个卡名记述的卡加入手卡。
-- 可以把这张卡1个超量素材取除，以场上最多2张卡为对象；那些卡回到手卡。
local s,id,o=GetID()
-- 注册卡片的初始化效果，包括超量召唤手续、不死族抗性效果、特殊召唤成功的检索效果以及去除超量素材弹回卡片的效果
function s.initial_effect(c)
	-- 添加超量召唤手续：6星不死族怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),6,2)
	c:EnableReviveLimit()
	-- 记录此卡的相关卡片名单中包含「活死人的呼声」
	aux.AddCodeList(c,97077563)
	-- 只要自己场上有「活死人的呼声」存在，对方不能把自己场上的不死族怪兽作为怪兽的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.tgcon)
	-- 指定抗性效果的受体：自己场上的不死族怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ZOMBIE))
	e1:SetValue(s.tgval)
	c:RegisterEffect(e1)
	-- 这张卡特殊召唤的场合：可以从卡组把1张「活死人的呼声」或者有那个卡名记述的卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 可以把这张卡1个超量素材取除，以场上最多2张卡为对象；那些卡回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"回到手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.cost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「活死人的呼声」
function s.indcfilter(c)
	return c:IsFaceup() and c:IsCode(97077563)
end
-- 抗性效果的适用条件判断：检查自己场上是否存在「活死人的呼声」
function s.tgcon(e)
	-- 判断自己场上是否存在表侧表示的「活死人的呼声」
	return Duel.IsExistingMatchingCard(s.indcfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 指定抗性效果的来源限制：对方且必须是怪兽的效果
function s.tgval(e,re,rp)
	return rp==1-e:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER)
end
-- 过滤条件：是「活死人的呼声」或记述有「活死人的呼声」卡名的卡，且可以加入手卡
function s.thfilter(c)
	-- 判断卡片本身是「活死人的呼声」或卡名记述中包含「活死人的呼声」且可以加入手牌
	return aux.IsCodeOrListed(c,97077563) and c:IsAbleToHand()
end
-- 检索效果的发动准备与合法性判定：检查卡组中是否存在满足条件的卡片，并设置连锁操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动判定：检查卡组是否存在可以检索的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息：预计将卡组的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的具体处理：从卡组中选择1张满足条件的卡片加入手卡并向对方玩家确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择1张符合检索条件的卡片
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡片因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家进行确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：可以返回手牌的卡
function s.filter(c)
	return c:IsAbleToHand()
end
-- 弹回卡片效果的发动代价：将这张卡的1个超量素材取除
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 弹回卡片效果的发动准备与对象选择：选择场上最多2张可以返回手牌的卡作为效果的对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.filter(chkc) end
	-- 判断场上是否存在至少1张可以作为对象的卡
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家在双方场上选择1到2张卡作为效果的对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	-- 设置连锁的操作信息：预计将选中的卡片送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- 弹回卡片效果的具体处理：将仍然在场上且与连锁有关的对象卡片全部送回手牌
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在场上且仍然与本次效果连锁相关的对象卡片
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsOnField,nil)
	if g:GetCount()>0 then
		-- 将被选择的卡片送回持有者的手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
