--聖霊獣騎 キムンファルコス
-- 效果：
-- 「灵兽」怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡所连接区的「灵兽」怪兽的攻击力·守备力上升600。
-- ②：从自己墓地把1张「灵兽」卡除外才能发动。进行手卡1只「灵兽」怪兽的召唤。
-- ③：自己·对方回合，让这张卡回到额外卡组，以自己的除外状态的1只「灵兽使」怪兽和1只「精灵兽」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。
function c58811192.initial_effect(c)
	-- 设置连接召唤手续：需要2只「灵兽」怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xb5),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡所连接区的「灵兽」怪兽的攻击力·守备力上升600。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c58811192.atktg)
	e1:SetValue(600)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ②：从自己墓地把1张「灵兽」卡除外才能发动。进行手卡1只「灵兽」怪兽的召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(58811192,0))  --"手卡1只怪兽召唤"
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,58811192)
	e3:SetCost(c58811192.cost)
	e3:SetTarget(c58811192.target)
	e3:SetOperation(c58811192.operation)
	c:RegisterEffect(e3)
	-- ③：自己·对方回合，让这张卡回到额外卡组，以自己的除外状态的1只「灵兽使」怪兽和1只「精灵兽」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(58811192,1))  --"除外的2只怪兽特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMING_END_PHASE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCost(c58811192.spcost)
	e4:SetTarget(c58811192.sptg)
	e4:SetOperation(c58811192.spop)
	c:RegisterEffect(e4)
end
-- 过滤条件：处于这张卡所连接区且是「灵兽」怪兽。
function c58811192.atktg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c) and c:IsSetCard(0xb5)
end
-- 过滤条件：自己墓地可以除外的「灵兽」卡。
function c58811192.cfilter(c)
	return c:IsSetCard(0xb5) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动代价：从自己墓地把1张「灵兽」卡除外。
function c58811192.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己墓地是否存在至少1张可以除外的「灵兽」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c58811192.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张「灵兽」卡。
	local g=Duel.SelectMatchingCard(tp,c58811192.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选择的卡表侧表示除外作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：手卡中可以进行通常召唤的「灵兽」怪兽。
function c58811192.filter(c)
	return c:IsSetCard(0xb5) and c:IsSummonable(true,nil)
end
-- 效果②的靶向/发动检查：检查手卡中是否存在可以召唤的「灵兽」怪兽，并设置操作信息。
function c58811192.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查手卡中是否存在至少1只可以召唤的「灵兽」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c58811192.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 向对方玩家提示所发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：包含召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果②的效果处理：从手卡选择1只「灵兽」怪兽进行通常召唤。
function c58811192.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从手卡选择1只满足召唤条件的「灵兽」怪兽。
	local g=Duel.SelectMatchingCard(tp,c58811192.filter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 让玩家对选择的怪兽进行通常召唤。
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 效果③的发动代价：让这张卡回到额外卡组。
function c58811192.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	-- 将这张卡送回持有者的额外卡组作为发动代价。
	Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_COST)
end
-- 过滤条件：自己除外状态的、可以守备表示特殊召唤的「灵兽使」怪兽，且此时存在可特殊召唤的「精灵兽」怪兽。
function c58811192.spfilter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x10b5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 并且除外状态存在至少1只可以守备表示特殊召唤的「精灵兽」怪兽。
		and Duel.IsExistingTarget(c58811192.spfilter2,tp,LOCATION_REMOVED,0,1,c,e,tp)
end
-- 过滤条件：自己除外状态的、可以守备表示特殊召唤的「精灵兽」怪兽。
function c58811192.spfilter2(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x20b5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果③的靶向/发动检查：选择除外状态的1只「灵兽使」怪兽和1只「精灵兽」怪兽为对象，并设置操作信息。
function c58811192.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 并且在这张卡离开场后，自己场上的怪兽区域空位大于1个。
		and Duel.GetMZoneCount(tp,e:GetHandler())>1
		-- 并且存在可以作为特殊召唤对象的「灵兽使」怪兽。
		and Duel.IsExistingTarget(c58811192.spfilter1,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向对方玩家提示所发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择除外状态的1只「灵兽使」怪兽作为效果对象。
	local g1=Duel.SelectTarget(tp,c58811192.spfilter1,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择除外状态的1只「精灵兽」怪兽作为效果对象。
	local g2=Duel.SelectTarget(tp,c58811192.spfilter2,tp,LOCATION_REMOVED,0,1,1,g1:GetFirst(),e,tp)
	g1:Merge(g2)
	-- 设置操作信息：包含特殊召唤这2只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- 效果③的效果处理：将作为对象的2只怪兽守备表示特殊召唤。
function c58811192.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用怪兽区域的数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取作为效果对象且仍对该效果有效的卡片。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==0 then return end
	if g:GetCount()<=ft then
		-- 将这些怪兽表侧守备表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	else
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,ft,ft,nil)
		-- 将选择的怪兽表侧守备表示特殊召唤。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		g:Sub(sg)
		-- 根据规则，将无法特殊召唤的其余对象怪兽送去墓地。
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
