--RR－ブレイブ・ストリクス
-- 效果：
-- 5星怪兽×2
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把这张卡1个超量素材取除才能发动。从卡组把1张「急袭猛禽」魔法·陷阱卡在自己场上盖放。
-- ②：这张卡有鸟兽族怪兽在作为超量素材的场合，把这张卡1个超量素材取除才能发动。从卡组把1张「升阶魔法」魔法卡加入手卡。
-- ③：持有这张卡作为素材中的「急袭猛禽」超量怪兽得到以下效果。
-- ●这张卡的攻击力上升自身的阶级×100。
local s,id,o=GetID()
-- 效果初始化函数，注册超量召唤手续、①效果（盖放魔陷）、②效果（检索升阶魔法）以及③效果（作为素材赋予的效果）。
function s.initial_effect(c)
	-- 添加超量召唤手续：5星怪兽×2。
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除才能发动。从卡组把1张「急袭猛禽」魔法·陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- ②：这张卡有鸟兽族怪兽在作为超量素材的场合，把这张卡1个超量素材取除才能发动。从卡组把1张「升阶魔法」魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetCost(s.cost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：持有这张卡作为素材中的「急袭猛禽」超量怪兽得到以下效果。●这张卡的攻击力上升自身的阶级×100。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_XMATERIAL)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.val)
	e3:SetCondition(s.gfcon)
	c:RegisterEffect(e3)
end
-- ①和②效果通用的发动代价：取除这张卡的1个超量素材。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：卡组中可以盖放的「急袭猛禽」魔法·陷阱卡。
function s.setfilter(c)
	return c:IsSetCard(0xba) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ①效果的发动准备，检查魔法与陷阱区域是否有空位，以及卡组中是否存在可盖放的卡。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的魔法与陷阱区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己卡组中是否存在满足条件的「急袭猛禽」魔法·陷阱卡。
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示发动了“盖放”效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))  --"盖放"
end
-- ①效果的效果处理：从卡组选择1张「急袭猛禽」魔法·陷阱卡在自己场上盖放。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张满足条件的「急袭猛禽」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡在自己场上盖放。
		Duel.SSet(tp,g:GetFirst())
	end
end
-- ②效果的发动条件：这张卡有鸟兽族怪兽在作为超量素材。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsRace,1,nil,RACE_WINDBEAST)
end
-- 过滤条件：卡组中可以加入手牌的「升阶魔法」魔法卡。
function s.thfilter(c)
	return c:IsSetCard(0x95) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- ②效果的发动准备，检查卡组中是否存在可检索的「升阶魔法」魔法卡，并设置操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在满足条件的「升阶魔法」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果的处理包含“从卡组将1张卡加入手牌”。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 向对方玩家提示发动了“加入手卡”效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))  --"加入手卡"
end
-- ②效果的效果处理：从卡组把1张「升阶魔法」魔法卡加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「升阶魔法」魔法卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 攻击力上升数值的计算函数：自身的阶级×100。
function s.val(e,c)
	return c:GetRank()*100
end
-- ③效果的赋予条件：持有这张卡作为素材中的「急袭猛禽」超量怪兽。
function s.gfcon(e)
	local c=e:GetHandler()
	return c:IsSetCard(0xba) and c:IsType(TYPE_XYZ)
end
