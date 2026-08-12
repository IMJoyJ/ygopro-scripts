--カートゥーン・シェード
-- 效果：
-- 这张卡不能通常召唤。「阴暗漫画卡通」1回合1次在不能通常召唤的怪兽在场上表侧表示存在的场合才能特殊召唤。
-- ①：这张卡特殊召唤的场合才能发动。把1只攻击力或守备力是2000的不能通常召唤的怪兽从卡组加入手卡。
-- ②：场上的这张卡被解放的场合，以场上1张卡为对象才能发动（自己场上有攻击力或守备力是2000的怪兽存在的场合，这个效果的对象可以变成2张）。那张卡回到手卡。
local s,id,o=GetID()
-- 初始化卡片效果：设置苏生限制，注册不能通常召唤的召唤条件（e1）、手卡特殊召唤规则（e2）、特殊召唤成功时检索卡组的诱发效果（e3）以及被解放时把场上卡弹回手卡的诱发效果（e4）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件设为恒为否，即这张卡不能以通常方式特殊召唤（不能通常召唤）
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 「阴暗漫画卡通」1回合1次在不能通常召唤的怪兽在场上表侧表示存在的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.spcon)
	c:RegisterEffect(e2)
	-- ①：这张卡特殊召唤的场合才能发动。把1只攻击力或守备力是2000的不能通常召唤的怪兽从卡组加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	-- ②：场上的这张卡被解放的场合，以场上1张卡为对象才能发动（自己场上有攻击力或守备力是2000的怪兽存在的场合，这个效果的对象可以变成2张）。那张卡回到手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e4:SetCode(EVENT_RELEASE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCondition(s.rthcon)
	e4:SetTarget(s.rthtg)
	e4:SetOperation(s.rthop)
	c:RegisterEffect(e4)
end
-- 过滤器：筛选场上表侧表示存在且不能通常召唤的怪兽
function s.spfilter(c)
	return c:IsFaceup() and not c:IsSummonableCard()
end
-- 特殊召唤条件：判定特殊召唤合法性的场合直接通过；否则要求自己的主要怪兽区有空位，且场上存在表侧表示的不能通常召唤的怪兽
function s.spcon(e,c)
	if c==nil then return true end
	-- 确认这张卡的控制者的主要怪兽区还有可用的空格
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查双方主要怪兽区是否存在至少1只表侧表示的不能通常召唤的怪兽
		Duel.IsExistingMatchingCard(s.spfilter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 检索过滤器：筛选攻击力或守备力是2000、不能通常召唤且可以加入手卡的怪兽
function s.thfilter(c)
	return (c:IsAttack(2000) or c:IsDefense(2000)) and not c:IsSummonableCard() and c:IsAbleToHand()
end
-- 检索效果的对象阶段：确认卡组存在满足条件的怪兽，并设置从卡组把1张卡加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己卡组存在至少1只攻击力或守备力是2000的不能通常召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预计从自己卡组把1张卡加入手卡（用于检索效果的连锁检测）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理：让玩家从卡组选择1只满足条件的怪兽加入手卡，并向对方展示确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示「请选择要加入手牌的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组选择1只攻击力或守备力是2000的不能通常召唤的怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的怪兽以效果原因加入持有者的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示确认加入手卡的这张卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 发动条件：这张卡被解放前在场上存在（即场上的这张卡被解放的场合）
function s.rthcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤器：筛选自己场上表侧表示且攻击力或守备力是2000的怪兽
function s.cfilter2(c)
	return c:IsFaceup() and (c:IsAttack(2000) or c:IsDefense(2000))
end
-- 弹回手卡效果的对象阶段：默认对象数为1，若自己场上有攻击力或守备力是2000的怪兽则改为2；选择场上可以回到手卡的卡作为对象并设置操作信息
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=1
	-- 检查自己主要怪兽区是否存在表侧表示的攻击力或守备力是2000的怪兽，存在则效果对象可以变成2张
	if Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil) then
		ct=2
	end
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 发动条件检查：场上存在至少1张可以回到手卡并能成为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示「请选择要返回手牌的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择场上1到ct张可以回到手卡的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	-- 设置操作信息：把作为对象的这些卡弹回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 弹回手卡效果的处理：取得与本连锁相关且仍在场上的对象卡，把它们弹回持有者的手卡
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与本连锁关联的对象卡中仍在场上的部分
	local tg=Duel.GetTargetsRelateToChain():Filter(Card.IsOnField,nil)
	if tg:GetCount()>0 then
		-- 把这些对象卡以效果原因弹回持有者的手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
