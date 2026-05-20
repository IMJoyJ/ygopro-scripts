--夜光列車ブルートラベラー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次，②的效果在决斗中只能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。从自己的卡组·墓地把1张「机关连接」或「回转调车」加入手卡。
-- ②：这张卡在墓地存在的场合，以自己墓地1只其他的机械族·地属性怪兽为对象才能发动。那只怪兽和这张卡特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（检索）和②效果（墓地特召）。
function s.initial_effect(c)
	-- 注册卡片效果中提及的特定卡片密码（「机关连接」与「回转调车」）。
	aux.AddCodeList(c,60879050,76136345)
	-- ①：把这张卡从手卡丢弃才能发动。从自己的卡组·墓地把1张「机关连接」或「回转调车」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己墓地1只其他的机械族·地属性怪兽为对象才能发动。那只怪兽和这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价（Cost）函数：检查并把这张卡从手卡丢弃。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 作为发动代价，将这张卡丢弃送去墓地。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：卡名是「机关连接」或「回转调车」且能加入手卡的卡。
function s.thfilter(c)
	return c:IsCode(60879050,76136345) and c:IsAbleToHand()
end
-- ①效果的发动目标（Target）函数：检查卡组或墓地是否存在可检索的卡，并设置操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或墓地是否存在至少1张满足过滤条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁的操作信息为：从卡组或墓地将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果的效果处理（Operation）函数：从卡组或墓地选择1张目标卡加入手卡并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1张满足过滤条件且不受「王家长眠之谷」影响的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡加入玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：机械族·地属性且可以特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标（Target）函数：检查是否满足特召条件，选择墓地1只其他的机械族·地属性怪兽作为对象，并设置操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) and chkc~=c end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己的主要怪兽区域是否有2个以上的空位（因为需要同时特殊召唤2只怪兽）。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己墓地是否存在除这张卡以外的、满足过滤条件的机械族·地属性怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己墓地1只除这张卡以外的、满足过滤条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,c,e,tp)
	g:AddCard(c)
	-- 设置连锁的操作信息为：特殊召唤这2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- ②效果的效果处理（Operation）函数：将自身和对象怪兽特殊召唤，并适用“不能从额外卡组特殊召唤机械族以外怪兽”的限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain()
		-- 检查这张卡（自身）是否不受「王家长眠之谷」的影响。
		and aux.NecroValleyFilter()(c)
		-- 检查作为对象的怪兽是否不受「王家长眠之谷」的影响。
		and aux.NecroValleyFilter()(tc)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 then
		local g=Group.FromCards(c,tc)
		-- 将自身和对象怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是机械族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该限制效果，使其对玩家生效。
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能特殊召唤非机械族的怪兽，且该限制仅适用于额外卡组。
function s.splimit(e,c)
	return not c:IsRace(RACE_MACHINE) and c:IsLocation(LOCATION_EXTRA)
end
