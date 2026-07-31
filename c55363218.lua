--カートゥーン・シェード
local s,id,o=GetID()
-- 注册卡片的效果及特殊召唤手续
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。用卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件：不能通常召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 场上有表侧表示的非通常召唤怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.spcon)
	c:RegisterEffect(e2)
	-- 这张卡特殊召唤成功的场合才能发动。从卡组把1只攻击力或守备力是2000的非通常召唤怪兽加入手牌。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	-- 场上的这张卡被解放的场合，以场上1张卡为对象才能发动（自己场上有攻击力或守备力是2000的怪兽存在的场合，那个数量可以最多变成2张）。那些卡返回手牌。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e4:SetCode(EVENT_RELEASE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCondition(s.rthcon)
	e4:SetTarget(s.rthtg)
	e4:SetOperation(s.rthop)
	c:RegisterEffect(e4)
end
-- 特殊召唤条件过滤：表侧表示且为非通常召唤怪兽
function s.spfilter(c)
	return c:IsFaceup() and not c:IsSummonableCard()
end
-- 特殊召唤条件：自己场上有空格且场上存在满足条件的怪兽
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有空余的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查场上是否存在表侧表示的非通常召唤怪兽
		Duel.IsExistingMatchingCard(s.spfilter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 检索过滤条件：攻击力或守备力为2000的非通常召唤怪兽且能加入手牌
function s.thfilter(c)
	return (c:IsAttack(2000) or c:IsDefense(2000)) and not c:IsSummonableCard() and c:IsAbleToHand()
end
-- 检索目标选择：确认卡组存在符合条件的卡并设置加入手牌分类
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在攻击力或守备力为2000的非通常召唤怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理分类为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果处理：从卡组选择1只符合条件的怪兽加入手牌并确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送选择要加入手牌卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 发动条件：卡片原本在场上
function s.rthcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：自己场上表侧表示且攻击力或守备力为2000的怪兽
function s.cfilter2(c)
	return c:IsFaceup() and (c:IsAttack(2000) or c:IsDefense(2000))
end
-- 弹卡目标选择：选择场上的卡为对象
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=1
	-- 检查自己场上是否存在攻击力或守备力为2000的怪兽以增加目标数量上限
	if Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil) then
		ct=2
	end
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 检查场上是否存在可以返回手牌的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 发送选择要返回手牌卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1～ct张可以返回手牌的卡作为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	-- 设置效果处理分类为将选中的对象卡返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 弹卡效果处理：将选中的对象卡返回手牌
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍存在于场上的对象卡
	local tg=Duel.GetTargetsRelateToChain():Filter(Card.IsOnField,nil)
	if tg:GetCount()>0 then
		-- 将对象卡因效果返回手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
