--インフェルノイド・イヴィル
-- 效果：
-- 「狱火机」怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合，从自己墓地把1只「狱火机」怪兽除外才能发动。和那只怪兽的等级相同数量的「狱火机」怪兽从卡组送去墓地（同名卡最多1张）。
-- ②：这张卡被送去墓地的场合或者被除外的场合才能发动。从卡组把1张「炼狱」魔法·陷阱卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含融合召唤手续、①效果（融合召唤成功时从卡组送墓）和②效果（送墓或除外时检索「炼狱」魔陷）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续，需要2只「狱火机」怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xbb),2,true)
	-- ①：这张卡融合召唤的场合，从自己墓地把1只「狱火机」怪兽除外才能发动。和那只怪兽的等级相同数量的「狱火机」怪兽从卡组送去墓地（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从卡组送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tgcon)
	e1:SetCost(s.tgcost)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合或者被除外的场合才能发动。从卡组把1张「炼狱」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从卡组加入手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：这张卡是融合召唤成功的场合
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤卡组中可以送去墓地的「狱火机」怪兽
function s.tgfilter(c)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 过滤墓地中可以作为cost除外的「狱火机」怪兽，且其等级不能超过卡组中不同名「狱火机」怪兽的总数
function s.rmfilter(c,ct)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and c:IsLevelBelow(ct)
end
-- 效果①的发动代价（Cost）处理：从自己墓地选择1只等级不超过卡组中不同名「狱火机」怪兽数量的「狱火机」怪兽除外，并记录其等级
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组中所有满足条件的「狱火机」怪兽
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	-- 检查墓地中是否存在至少1只满足除外条件的「狱火机」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE,0,1,nil,ct) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的「狱火机」怪兽
	local rg=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil,ct)
	-- 将选中的怪兽表侧表示除外作为发动代价
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	e:SetLabel(rg:GetFirst():GetLevel())
end
-- 效果①的靶向（Target）处理：检查是否已支付代价，并设置将卡组中对应数量的卡送去墓地的操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 设置操作信息：从卡组将与除外怪兽等级相同数量的卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,e:GetLabel(),tp,LOCATION_DECK)
end
-- 效果①的效果处理（Operation）：从卡组选择与除外怪兽等级相同数量的不同名「狱火机」怪兽送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local l=e:GetLabel()
	-- 获取卡组中所有满足条件的「狱火机」怪兽
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	local c=g:GetClassCount(Card.GetCode)
	if c>=l then
		-- 提示玩家选择要送去墓地的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 开启卡片组同名卡检查，确保选择的卡片卡名各不相同
		aux.GCheckAdditional=aux.dncheck
		-- 让玩家从卡组中选择与除外怪兽等级相同数量的不同名「狱火机」怪兽
		local sg=g:SelectSubGroup(tp,aux.TRUE,false,l,l)
		-- 重置卡片组附加检查函数
		aux.GCheckAdditional=nil
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
-- 过滤卡组中可以加入手牌的「炼狱」魔法·陷阱卡
function s.thfilter(c)
	return c:IsSetCard(0xc5) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果②的靶向（Target）处理：检查卡组中是否存在可检索的「炼狱」魔陷，并设置检索的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张可以加入手牌的「炼狱」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理（Operation）：从卡组将1张「炼狱」魔法·陷阱卡加入手牌并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「炼狱」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
