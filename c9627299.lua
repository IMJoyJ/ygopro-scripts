--斎キ狭依姫
-- 效果：
-- 这张卡不能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，自己场上有攻击力或守备力是800的怪兽存在的场合才能发动。进行这张卡的召唤。
-- ②：这张卡召唤的场合才能发动。从卡组把「斋狭依姬」以外的1只攻击力或守备力是800而4星的光·暗属性怪兽加入手卡。
-- ③：这张卡召唤·反转的回合的结束阶段发动。这张卡回到手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含灵魂怪兽回手、不能特殊召唤、手卡主动召唤、召唤成功检索四个效果。
function s.initial_effect(c)
	-- 注册灵魂怪兽在召唤或反转的回合结束阶段回到手卡的效果。
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件始终为假，即不能特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：这张卡在手卡存在，自己场上有攻击力或守备力是800的怪兽存在的场合才能发动。进行这张卡的召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"召唤"
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡召唤的场合才能发动。从卡组把「斋狭依姬」以外的1只攻击力或守备力是800而4星的光·暗属性怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"检索"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示存在攻击力或守备力是800的怪兽。
function s.cfilter(c)
	return (c:IsAttack(800) or c:IsDefense(800)) and c:IsFaceup()
end
-- 效果①的发动条件：自己场上存在满足过滤条件的怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示且攻击力或守备力为800的怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动准备与合法性检测，检查自身是否可以进行通常召唤，并设置召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSummonable(true,nil) end
	-- 设置连锁中的操作信息为：对自身进行1次通常召唤。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,c,1,0,0)
end
-- 效果①的效果处理：若自身仍在手卡，则对自身进行通常召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsLocation(LOCATION_HAND) then
		-- 让玩家无视每回合通常召唤次数限制，对这张卡进行通常召唤。
		Duel.Summon(tp,c,true,nil)
	end
end
-- 过滤条件：卡组中除「斋狭依姬」以外、攻击力或守备力是800的4星光·暗属性且可加入手卡的怪兽。
function s.thfilter(c)
	return not c:IsCode(id) and (c:IsAttack(800) or c:IsDefense(800)) and c:IsLevel(4) and c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 效果②的发动准备与合法性检测，检查卡组中是否存在满足条件的怪兽，并设置检索的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足检索条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁中的操作信息为：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组选择1张满足条件的怪兽加入手卡并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足检索条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡因效果加入玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
