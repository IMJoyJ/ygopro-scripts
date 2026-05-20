--星騎士 リュラ
-- 效果：
-- 这个卡名在规则上也当作「星圣」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「星骑士 织女星」以外的「星骑士」、「星圣」怪兽召唤的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·反转召唤·特殊召唤的场合才能发动。从卡组把1张「星骑士」魔法卡加入手卡。
function c79210531.initial_effect(c)
	-- ①：自己场上有「星骑士 织女星」以外的「星骑士」、「星圣」怪兽召唤的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,79210531)
	e1:SetCondition(c79210531.spcon)
	e1:SetTarget(c79210531.sptg)
	e1:SetOperation(c79210531.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·反转召唤·特殊召唤的场合才能发动。从卡组把1张「星骑士」魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,79210532)
	e2:SetTarget(c79210531.thtg)
	e2:SetOperation(c79210531.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	c79210531.star_knight_summon_effect=e2
end
-- 判断召唤的怪兽是否为自己场上「星骑士 织女星」以外的「星骑士」或「星圣」怪兽
function c79210531.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return not ec:IsCode(79210531) and ec:IsControler(tp) and ec:IsSetCard(0x9c,0x53)
end
-- 效果①（手卡特殊召唤）的发动准备与合法性检测
function c79210531.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息为：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①（手卡特殊召唤）的效果处理
function c79210531.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤卡组中可加入手牌的「星骑士」魔法卡
function c79210531.thfilter(c)
	return c:IsSetCard(0x9c) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果②（检索魔法卡）的发动准备与合法性检测
function c79210531.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可加入手牌的「星骑士」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c79210531.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理中的操作信息为：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②（检索魔法卡）的效果处理
function c79210531.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件的「星骑士」魔法卡
	local g=Duel.SelectMatchingCard(tp,c79210531.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 then return end
	-- 将选中的卡片加入玩家手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 向对方玩家展示加入手牌的卡片
	Duel.ConfirmCards(1-tp,g)
end
