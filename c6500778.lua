--錬金釜－カオス・ディスティル
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，被送去自己墓地的卡不去墓地而除外。
-- ②：可以从以下效果选择1个发动。
-- ●除「炼金釜-混沌蒸馏釜」外的1张「大宇宙」或者有那个卡名记述的卡从卡组加入手卡。
-- ●场上有「大宇宙」存在的场合，把魔法与陷阱区域的表侧表示的这张卡除外才能发动。从卡组把1只攻击力?的光属性怪兽加入手卡。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果
function s.initial_effect(c)
	-- 在卡片中注册记述了「大宇宙」卡名的卡片列表
	aux.AddCodeList(c,30241314)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，被送去自己墓地的卡不去墓地而除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_DECK,0)
	e2:SetValue(LOCATION_REMOVED)
	e2:SetTarget(s.rmtg)
	c:RegisterEffect(e2)
	-- ●除「炼金釜-混沌蒸馏釜」外的1张「大宇宙」或者有那个卡名记述的卡从卡组加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"检索「大宇宙」或有记述的卡"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	-- ●场上有「大宇宙」存在的场合，把魔法与陷阱区域的表侧表示的这张卡除外才能发动。从卡组把1只攻击力?的光属性怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"检索怪兽"
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.thcon2)
	-- 设置发动代价为：把魔法与陷阱区域的表侧表示的这张卡除外
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.thtg2)
	e4:SetOperation(s.thop2)
	c:RegisterEffect(e4)
end
-- 过滤条件：判断被送去墓地的卡是否属于自己
function s.rmtg(e,c)
	return c:GetOwner()==e:GetHandlerPlayer()
end
-- 过滤条件：卡组中除「炼金釜-混沌蒸馏釜」以外、记述了「大宇宙」卡名且可以加入手牌的卡
function s.filter(c)
	-- 过滤条件：非同名卡，且是「大宇宙」或记述了「大宇宙」卡名的卡，且能加入手牌
	return not c:IsCode(id) and aux.IsCodeOrListed(c,30241314) and c:IsAbleToHand()
end
-- 效果①（检索「大宇宙」相关卡）的发动准备与合法性检测函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示当前发动了哪一个效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果处理信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①（检索「大宇宙」相关卡）的效果处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②（检索攻击力?的光属性怪兽）的发动条件判断函数
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在表侧表示的「大宇宙」
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,30241314)
end
-- 过滤条件：卡组中攻击力为?的光属性且能加入手牌的怪兽
function s.thfilter2(c)
	return c:GetTextAttack()==-2 and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 效果②（检索攻击力?的光属性怪兽）的发动准备与合法性检测函数
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件（攻击力?的光属性怪兽）的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示当前发动了哪一个效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果处理信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②（检索攻击力?的光属性怪兽）的效果处理函数
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件（攻击力?的光属性怪兽）的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
