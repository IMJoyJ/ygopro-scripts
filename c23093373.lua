--天魔の聲選姫
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡召唤·灵摆召唤的场合才能发动。从卡组把「天魔之声选姬」以外的1张「异响鸣」卡加入手卡。
-- ②：只要自己场上有「天魔之声选姬」以外的怪兽存在，对方怪兽不能选择这张卡作为攻击对象。
-- ③：这张卡被送去墓地的场合，若自己的灵摆区域有2张「异响鸣」卡存在则能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 注册卡片的3个效果，包括召唤时检索、灵摆召唤时检索、以及被送去墓地时的特殊处理
function s.initial_effect(c)
	-- ①：这张卡召唤·灵摆召唤的场合才能发动。从卡组把「天魔之声选姬」以外的1张「异响鸣」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索「异响鸣」卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.thcon)
	c:RegisterEffect(e2)
	-- ②：只要自己场上有「天魔之声选姬」以外的怪兽存在，对方怪兽不能选择这张卡作为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atcon)
	-- 设置效果值为过滤函数aux.imval1，用于判断是否能成为攻击对象
	e3:SetValue(aux.imval1)
	c:RegisterEffect(e3)
	-- ③：这张卡被送去墓地的场合，若自己的灵摆区域有2张「异响鸣」卡存在则能发动。这张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"这张卡加入手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.thtg2)
	e4:SetOperation(s.thop2)
	c:RegisterEffect(e4)
end
-- 过滤函数：检索满足条件的「异响鸣」卡，排除自身且能加入手牌
function s.thfilter(c)
	return c:IsSetCard(0x1a3) and not c:IsCode(id) and c:IsAbleToHand()
end
-- 设置效果处理时的检索操作信息，确定要检索的卡为1张「异响鸣」卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件，即卡组中是否存在至少1张满足条件的「异响鸣」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索操作，提示玩家选择卡牌并发送至手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡发送至手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方能看到被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断是否为灵摆召唤成功触发的效果
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 过滤函数：判断场上是否存在非自身且非里侧的怪兽
function s.cfilter(c)
	return not c:IsCode(id) or c:IsFacedown()
end
-- 判断是否满足效果触发条件，即场上存在非自身怪兽
function s.atcon(e)
	-- 判断场上是否存在至少1张非自身且非里侧的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 设置效果处理时的检索操作信息，确定要检索的卡为1张「异响鸣」卡
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand()
		-- 判断灵摆区域是否存在至少2张「异响鸣」卡
		and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,2,nil,0x1a3) end
	-- 设置操作信息，表示将要将自身加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 执行效果处理，将自身加入手牌
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身发送至手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
