--フォトン・サーベルタイガー
-- 效果：
-- 这张卡召唤·反转召唤成功时，可以从卡组把1只「光子剑齿虎」加入手卡。自己场上没有这张卡以外的「光子剑齿虎」存在的场合，这张卡的攻击力下降800。
function c80495985.initial_effect(c)
	-- 这张卡召唤·反转召唤成功时，可以从卡组把1只「光子剑齿虎」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80495985,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c80495985.thtg)
	e1:SetOperation(c80495985.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 自己场上没有这张卡以外的「光子剑齿虎」存在的场合，这张卡的攻击力下降800。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetCondition(c80495985.atcon)
	e3:SetValue(-800)
	c:RegisterEffect(e3)
end
-- 过滤卡组中卡名为「光子剑齿虎」且可以加入手牌的卡
function c80495985.filter(c)
	return c:IsCode(80495985) and c:IsAbleToHand()
end
-- 检索效果的发动准备与目标确认
function c80495985.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查卡组中是否存在可以加入手牌的「光子剑齿虎」
	if chk==0 then return Duel.IsExistingMatchingCard(c80495985.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行函数
function c80495985.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中第一张满足条件的「光子剑齿虎」
	local tc=Duel.GetFirstMatchingCard(c80495985.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将目标卡片加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 过滤场上表侧表示的「光子剑齿虎」
function c80495985.atfilter(c)
	return c:IsFaceup() and c:IsCode(80495985)
end
-- 攻击力下降效果的生效条件
function c80495985.atcon(e)
	-- 检查自己场上是否存在除自身以外的表侧表示「光子剑齿虎」，若不存在则条件成立
	return not Duel.IsExistingMatchingCard(c80495985.atfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,e:GetHandler())
end
