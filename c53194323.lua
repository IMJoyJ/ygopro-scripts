--ダーク・エレメント
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己墓地有「门之守护神」怪兽存在的场合，把基本分支付一半才能发动。从手卡·卡组·额外卡组把1只11星以上的「门之守护神」怪兽无视召唤条件特殊召唤。
-- ②：把墓地的这张卡除外才能发动。自己的卡组·除外状态的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」的其中1只加入手卡。
local s,id,o=GetID()
-- 注册卡片效果，设置两个效果分别为①和②，①为发动时特殊召唤，②为墓地发动的效果
function s.initial_effect(c)
	-- 记录该卡与「门之守护神」系列卡的关联，用于条件判断
	aux.AddCodeList(c,25955164,62340868,98434877)
	-- 效果①：将此卡作为发动效果的魔法卡，可自由连锁发动，限制1回合1次，需要满足条件并支付LP，目标为特殊召唤1只11星以上「门之守护神」怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 效果②：从墓地发动，将此卡除外，检索1张「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」加入手牌
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	-- 效果②的费用为将此卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 判断自己墓地是否存在「门之守护神」怪兽
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否有至少1张「门之守护神」怪兽
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE,0,1,nil,0x1052)
end
-- 支付一半基本分作为效果①的费用
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付当前LP的一半作为LP费用
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 定义特殊召唤的过滤条件，包括为「门之守护神」系列、等级≥11、可特殊召唤且场上存在召唤空间
function s.filter(c,e,tp)
	-- 满足「门之守护神」系列、等级≥11、可特殊召唤且有召唤空间的条件
	return c:IsSetCard(0x1052) and c:IsLevelAbove(11) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 设置效果①的目标，检查是否有符合条件的怪兽可以特殊召唤
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌·卡组·额外卡组是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息为特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_HAND)
end
-- 执行效果①的操作，选择并特殊召唤符合条件的怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽作为特殊召唤对象
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
-- 定义检索效果中可加入手牌的魔神系列怪兽过滤条件
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsCode(25955164,62340868,98434877) and c:IsAbleToHand()
end
-- 设置效果②的目标，检查卡组或除外区是否存在符合条件的魔神怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或除外区是否存在符合条件的魔神怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil) end
	-- 设置操作信息为将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
-- 执行效果②的操作，选择并加入手牌符合条件的魔神怪兽
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的魔神怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的魔神怪兽作为加入手牌对象
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		-- 将选中的魔神怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看所选的魔神怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
