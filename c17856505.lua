--ゴースト大王－パンプキング－
-- 效果：
-- 不死族6星怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。把1张「活死人的呼声」或者有那个卡名记述的卡从卡组加入手卡。
-- ②：只要自己场上有「活死人的呼声」存在，对方不能把自己场上的不死族怪兽作为怪兽的效果的对象。
-- ③：把这张卡1个超量素材取除，以场上最多2张卡为对象才能发动。那些卡回到手卡。
local s,id,o=GetID()
-- 初始化卡片效果：注册XYZ召唤手续和苏生限制，并依次注册三个效果——e1为②的永续效果（使自己场上的不死族怪兽不能成为对方怪兽效果的对象）、e2为①的特殊召唤成功时检索「活死人的呼声」相关卡的诱发效果、e3为③的取除超量素材把场上最多2张卡回到手卡的起动效果
function s.initial_effect(c)
	-- 注册XYZ召唤手续：以2只不死族的6星怪兽作为超量素材进行叠放
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),6,2)
	c:EnableReviveLimit()
	-- 在这张卡上记录卡名记述：此卡的效果文本中记述了「活死人的呼声」（卡号97077563）
	aux.AddCodeList(c,97077563)
	-- ②：只要自己场上有「活死人的呼声」存在，对方不能把自己场上的不死族怪兽作为怪兽的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.tgcon)
	-- 设定该效果的作用对象为自己场上的不死族怪兽，这些怪兽获得不能成为效果对象的抗性
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ZOMBIE))
	e1:SetValue(s.tgval)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤的场合才能发动。把1张「活死人的呼声」或者有那个卡名记述的卡从卡组加入手卡。这个卡名的①的效果1回合只能使用1次。
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
	-- ③：把这张卡1个超量素材取除，以场上最多2张卡为对象才能发动。那些卡回到手卡。这个卡名的③的效果1回合只能使用1次。
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
-- 过滤函数：判定卡片是否为表侧表示存在的「活死人的呼声」（卡号97077563）
function s.indcfilter(c)
	return c:IsFaceup() and c:IsCode(97077563)
end
-- ②效果的适用条件判定：自己场上是否有「活死人的呼声」存在
function s.tgcon(e)
	-- 检查自己场上是否存在至少1张表侧表示的「活死人的呼声」，存在则②效果生效
	return Duel.IsExistingMatchingCard(s.indcfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- ②效果的抗性取值判定：只有对方（rp为对方玩家）发动的怪兽效果，自己场上的不死族怪兽才不能成为其对象
function s.tgval(e,re,rp)
	return rp==1-e:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER)
end
-- ①效果检索用的过滤函数：判定卡片是否为「活死人的呼声」或者有那个卡名记述且可以加入手卡的卡
function s.thfilter(c)
	-- 判定卡片是「活死人的呼声」或效果文本中记述了该卡名，并且可以加入手卡
	return aux.IsCodeOrListed(c,97077563) and c:IsAbleToHand()
end
-- ①效果的对象函数：确认卡组中存在可检索的卡，并设置操作信息为从卡组把1张卡加入手卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：检查自己卡组中是否存在至少1张「活死人的呼声」或有那个卡名记述且可加入手卡的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的操作信息：将从卡组把1张卡加入手卡（CATEGORY_TOHAND，数量为1，持有者为自己，位置为卡组）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组选择1张「活死人的呼声」或有那个卡名记述的卡加入手卡，并向对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选卡提示：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组选择1张满足检索条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 把选择的卡以效果处理的原因加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③效果取对象用的过滤函数：判定卡片是否可以回到手卡
function s.filter(c)
	return c:IsAbleToHand()
end
-- ③效果的发动代价：把这张卡的1个超量素材取除
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ③效果的对象函数：选择场上最多2张可以回到手卡的卡作为对象，并设置回到手卡的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.filter(chkc) end
	-- 发动条件判定：检查双方场上是否存在至少1张可以回到手卡且能成为对象的卡
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送选卡提示：请选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择双方场上1到2张可以回到手卡的卡作为效果对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	-- 设置本次连锁的操作信息：把作为对象的卡回到手卡（CATEGORY_TOHAND，目标为所选的卡，数量为其张数）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- ③效果的处理：把仍留在场上的对象卡全部回到手卡
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与当前连锁相关的对象卡，并筛选出其中仍在场上的卡
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsOnField,nil)
	if g:GetCount()>0 then
		-- 把那些对象卡以效果处理的原因送回持有者的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
