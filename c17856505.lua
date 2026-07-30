--ゴースト大王－パンプキング－
-- 效果：
-- 6星不死族怪兽×2
-- 只要自己场上有「活死人的呼声」存在，对方不能把自己场上的不死族怪兽作为怪兽的效果的对象。
-- 「幽灵大王-南瓜王-」的以下效果1回合各能使用1次。
-- 这张卡特殊召唤的场合：可以从卡组把1张「活死人的呼声」或者有那个卡名记述的卡加入手卡。
-- 可以把这张卡1个超量素材取除，以场上最多2张卡为对象；那些卡回到手卡。
local s,id,o=GetID()
-- 初始化效果函数，设置XYZ召唤手续、启用复活限制、添加卡名代码列表并注册三个效果
function s.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，要求使用等级为6且为不死族的怪兽进行叠放，最少2只最多2只
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),6,2)
	c:EnableReviveLimit()
	-- 记录该卡上记载着「活死人的呼声」（卡号97077563）
	aux.AddCodeList(c,97077563)
	-- 注册一个永续效果，当自己场上有「活死人的呼声」存在时，对方不能把自己场上的不死族怪兽作为怪兽的效果的对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.tgcon)
	-- 设置该效果的目标为场上的所有不死族怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ZOMBIE))
	e1:SetValue(s.tgval)
	c:RegisterEffect(e1)
	-- 注册一个诱发效果，特殊召唤成功时可以检索1张「活死人的呼声」或其相关卡加入手牌
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
	-- 注册一个起动效果，消耗1个超量素材，可以选择场上最多2张卡回到手牌
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
-- 定义过滤函数，用于判断场上的卡是否为表侧表示且为「活死人的呼声」
function s.indcfilter(c)
	return c:IsFaceup() and c:IsCode(97077563)
end
-- 定义条件函数，判断自己场地上是否存在「活死人的呼声」
function s.tgcon(e)
	-- 检查自己场地上是否存在至少1张「活死人的呼声」
	return Duel.IsExistingMatchingCard(s.indcfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 定义效果值函数，当对方怪兽效果被发动时，若该效果的发动者不是自己，则该效果不能针对此卡
function s.tgval(e,re,rp)
	return rp==1-e:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER)
end
-- 定义检索过滤函数，用于筛选可以加入手牌的「活死人的呼声」或其相关卡
function s.thfilter(c)
	-- 判断卡片是否为「活死人的呼声」或其相关卡且能加入手牌
	return aux.IsCodeOrListed(c,97077563) and c:IsAbleToHand()
end
-- 定义检索效果的目标函数，检查自己卡组是否存在满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1张满足检索条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的操作信息，表示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义检索效果的处理函数，选择并把符合条件的卡加入手牌并确认给对方
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认被送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义目标过滤函数，用于判断卡是否能回到手牌
function s.filter(c)
	return c:IsAbleToHand()
end
-- 定义消耗函数，检查并移除1个超量素材作为效果的发动费用
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义效果的目标函数，选择场上最多2张卡作为对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.filter(chkc) end
	-- 检查自己场上是否存在至少1张满足条件的卡作为目标
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上最多2张卡作为对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	-- 设置效果的操作信息，表示将把选中的卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- 定义效果的处理函数，将选中的卡送回手牌
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与连锁相关的选中目标，并筛选出在场上的卡
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsOnField,nil)
	if g:GetCount()>0 then
		-- 将符合条件的卡送回手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
