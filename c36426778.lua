--幻影騎士団サイレントブーツ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有「幻影骑士团」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从卡组把1张「幻影」魔法·陷阱卡加入手卡。
function c36426778.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有「幻影骑士团」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36426778,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,36426778+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c36426778.spcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：把墓地的这张卡除外才能发动。从卡组把1张「幻影」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36426778,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,36426779)
	-- 设置②效果的发动代价：把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c36426778.thtg)
	e2:SetOperation(c36426778.thop)
	c:RegisterEffect(e2)
end
-- 判断场上是否存在表侧表示且属于「幻影骑士团」系列的怪兽，用于①特殊召唤的发动条件。
function c36426778.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x10db)
end
-- ①特殊召唤规则的适用条件：自己场上有表侧表示「幻影骑士团」怪兽存在，且自己主要怪兽区有空位；若c为nil视为规则询问，返回true。
function c36426778.spcon(e,c)
	if c==nil then return true end
	-- 检查自己主要怪兽区是否有空位，确保特殊召唤后有可用区域。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1张表侧表示「幻影骑士团」怪兽，满足①特殊召唤的条件。
		and Duel.IsExistingMatchingCard(c36426778.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 检索过滤器：卡名含有「幻影」的魔法·陷阱卡，且能加入手卡。
function c36426778.thfilter(c)
	return c:IsSetCard(0xdb) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②效果发动时的合法性判断：卡组中存在1张符合检索条件的「幻影」魔法·陷阱卡；并设置本次操作信息为从卡组将1张卡加入手卡。
function c36426778.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时（chk==0）检查卡组是否存在符合条件的检索对象，若没有则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c36426778.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本效果处理时预计从卡组将1张卡加入手卡（数量为1，检索区域为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1张符合条件的「幻影」魔法·陷阱卡加入手卡，并让对方确认。
function c36426778.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示卡片选择提示，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张符合条件的「幻影」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c36426778.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
