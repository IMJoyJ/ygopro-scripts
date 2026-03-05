--ハイネス・デーモン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤的场合，从自己墓地把1张「恶魔」卡除外才能发动。从卡组把「殿下恶魔」以外的2张「恶魔」卡加入手卡。这个效果的发动后，直到回合结束时自己不是「恶魔」怪兽不能从额外卡组特殊召唤。
-- ②：这张卡在墓地存在的状态，自己的仪式怪兽被战斗破坏时才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②效果
function s.initial_effect(c)
	-- ①：这张卡召唤的场合，从自己墓地把1张「恶魔」卡除外才能发动。从卡组把「殿下恶魔」以外的2张「恶魔」卡加入手卡。这个效果的发动后，直到回合结束时自己不是「恶魔」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己的仪式怪兽被战斗破坏时才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检索满足条件的「恶魔」卡（可除外作为代价）
function s.costfilter(c)
	return c:IsSetCard(0x45) and c:IsAbleToRemoveAsCost()
end
-- 效果发动时的费用处理，从墓地选择1张「恶魔」卡除外
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外费用的条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1张满足条件的卡除外
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数，用于检索满足条件的「恶魔」卡（可加入手牌）
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x45) and c:IsAbleToHand()
end
-- 设置检索效果的目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,2,nil) end
	-- 设置检索效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 检索效果的处理，从卡组检索2张「恶魔」卡加入手牌，并设置不能特殊召唤非恶魔怪兽的效果
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的卡组中的「恶魔」卡
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g and g:GetCount()>1 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将选中的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 确认玩家手牌
		Duel.ConfirmCards(1-tp,sg)
	end
	-- 设置不能特殊召唤非恶魔怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤非恶魔怪兽的效果
	Duel.RegisterEffect(e1,tp)
end
-- 设置不能特殊召唤非恶魔怪兽的效果目标
function s.splimit(e,c)
	return not c:IsSetCard(0x45) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤函数，用于判断是否为被战斗破坏的仪式怪兽
function s.cfilter(c,tp)
	local rm=TYPE_RITUAL|TYPE_MONSTER
	return c:GetPreviousTypeOnField()&rm==rm and c:IsPreviousControler(tp)
end
-- 判断是否满足特殊召唤条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 设置特殊召唤效果的目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否满足特殊召唤条件
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
