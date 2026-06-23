--幻影騎士団サイレントブーツ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有「幻影骑士团」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从卡组把1张「幻影」魔法·陷阱卡加入手卡。
function c36426778.initial_effect(c)
	-- ①：自己场上有「幻影骑士团」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36426778,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,36426778+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c36426778.spcon)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从卡组把1张「幻影」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36426778,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,36426779)
	-- 将此卡从墓地除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c36426778.thtg)
	e2:SetOperation(c36426778.thop)
	c:RegisterEffect(e2)
end
-- 过滤场上存在的「幻影骑士团」怪兽
function c36426778.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x10db)
end
-- 判断是否满足特殊召唤条件
function c36426778.spcon(e,c)
	if c==nil then return true end
	-- 判断场上是否有可用怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判断场上是否存在「幻影骑士团」怪兽
		and Duel.IsExistingMatchingCard(c36426778.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 过滤卡组中可加入手牌的「幻影」魔法·陷阱卡
function c36426778.thfilter(c)
	return c:IsSetCard(0xdb) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置检索效果的处理信息
function c36426778.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c36426778.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行将卡加入手牌的效果处理
function c36426778.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c36426778.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
