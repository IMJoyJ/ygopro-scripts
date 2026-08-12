--ロワイヤル・デーモン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡·场上的这张卡解放才能发动。从卡组把「王家恶魔」以外的1张「恶魔」卡加入手卡。这个回合，自己不是「恶魔」怪兽不能从额外卡组特殊召唤，在通常召唤外加上只有1次，自己主要阶段可以把1只恶魔族怪兽召唤。
-- ②：这张卡在墓地存在的状态，自己的仪式怪兽被战斗破坏时才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片「王家恶魔」的①起动效果（检索、限制特殊召唤、追加召唤）和②诱发效果（墓地特殊召唤）。
function s.initial_effect(c)
	-- ①：把手卡·场上的这张卡解放才能发动。从卡组把「王家恶魔」以外的1张「恶魔」卡加入手卡。这个回合，自己不是「恶魔」怪兽不能从额外卡组特殊召唤，在通常召唤外加上只有1次，自己主要阶段可以把1只恶魔族怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
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
-- ①效果的发动代价（Cost）判定与执行：把手卡·场上的这张卡解放。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤卡组中「王家恶魔」以外的「恶魔」卡。
function s.thfilter(c)
	return c:IsSetCard(0x45) and not c:IsCode(id) and c:IsAbleToHand()
end
-- ①效果的发动判定与效果分类设置：检查卡组是否存在可检索卡，且玩家是否能进行通常召唤和追加召唤，且本回合未适用过该追加召唤效果。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「王家恶魔」以外的「恶魔」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查玩家当前是否可以进行通常召唤。
		and Duel.IsPlayerCanSummon(tp)
		-- 检查玩家是否可以获得追加召唤的机会。
		and Duel.IsPlayerCanAdditionalSummon(tp)
		-- 检查玩家本回合是否尚未获得过该效果带来的追加召唤机会。
		and Duel.GetFlagEffect(tp,id)==0 end
	-- 设置连锁信息，表示该效果包含从卡组将1张卡加入手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组将1张「王家恶魔」以外的「恶魔」卡加入手牌，并适用“不能从额外卡组特殊召唤「恶魔」以外的怪兽”的限制，以及“在通常召唤外加上只有1次，自己主要阶段可以把1只恶魔族怪兽召唤”的效果。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「恶魔」卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个回合，自己不是「恶魔」怪兽不能从额外卡组特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册“不能从额外卡组特殊召唤「恶魔」以外的怪兽”的限制效果。
	Duel.RegisterEffect(e1,tp)
	-- 判断玩家是否满足获得追加召唤机会的条件。
	if Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) and Duel.GetFlagEffect(tp,id)==0 then
		-- 在通常召唤外加上只有1次，自己主要阶段可以把1只恶魔族怪兽召唤。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(aux.Stringid(id,2))  --"使用「王家恶魔」的效果召唤"
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
		e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
		-- 设置追加召唤的限制条件为恶魔族怪兽。
		e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_FIEND))
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 为玩家注册追加召唤恶魔族怪兽的效果。
		Duel.RegisterEffect(e2,tp)
		-- 为玩家注册本回合已获得该追加召唤效果的标记，防止重复获得。
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 限制不能从额外卡组特殊召唤「恶魔」以外的怪兽。
function s.splimit(e,c)
	return not c:IsSetCard(0x45) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤在自己场上被战斗破坏的仪式怪兽。
function s.cfilter(c,tp)
	local rm=TYPE_RITUAL|TYPE_MONSTER
	return c:GetPreviousTypeOnField()&rm==rm and c:IsPreviousControler(tp)
end
-- ②效果的发动条件判定：自己的仪式怪兽被战斗破坏，且被破坏的怪兽不包含墓地中的这张卡自身。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- ②效果的发动判定与效果分类设置：检查自身是否能特殊召唤，且怪兽区域是否有空位。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家的主要怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息，表示该效果包含将自身特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理：将墓地的这张卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍存在于墓地，且不受「王家长眠之谷」的影响。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡以表侧表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
