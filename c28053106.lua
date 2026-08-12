--サイバー・エッグ・エンジェル
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合才能发动。从卡组把1张「机械天使」魔法卡或者「祝福的教会-仪式教堂」加入手卡。
function c28053106.initial_effect(c)
	-- 记录该卡具有「机械天使」卡名的代码
	aux.AddCodeList(c,95658967)
	-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合才能发动。从卡组把1张「机械天使」魔法卡或者「祝福的教会-仪式教堂」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28053106,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,28053106)
	e1:SetTarget(c28053106.thtg)
	e1:SetOperation(c28053106.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选满足条件的「机械天使」魔法卡或「祝福的教会-仪式教堂」卡片
function c28053106.thfilter(c)
	return ((c:IsSetCard(0x124) and c:IsType(TYPE_SPELL)) or c:IsCode(95658967)) and c:IsAbleToHand()
end
-- 效果处理的判断函数，检查是否满足发动条件并设置操作信息
function c28053106.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断条件：检查玩家手牌中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c28053106.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行检索并加入手牌的操作
function c28053106.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡从卡组加入手牌
	local g=Duel.SelectMatchingCard(tp,c28053106.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
