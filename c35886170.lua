--ゴゴゴゴブリンドバーグ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤时才能发动。从自己的手卡·卡组·墓地把1只战士族以外的「隆隆隆」怪兽特殊召唤。这张卡是攻击表示的场合，再让这张卡变成守备表示。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
-- ②：超量素材的这张卡为让超量怪兽的效果发动而被取除的场合才能发动。从卡组把1只「怒怒怒」怪兽加入手卡。
local s,id,o=GetID()
-- 注册这张卡的两个诱发效果：①召唤成功时可从手卡·卡组·墓地特殊召唤1只战士族以外的「隆隆隆」怪兽，并根据情况变守备表示，同时给自己附加额外卡组自肃；②作为超量素材被取除时可从卡组检索「怒怒怒」怪兽。
function s.initial_effect(c)
	-- ①：这张卡召唤时才能发动。从自己的手卡·卡组·墓地把1只战士族以外的「隆隆隆」怪兽特殊召唤。这张卡是攻击表示的场合，再让这张卡变成守备表示。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：超量素材的这张卡为让超量怪兽的效果发动而被取除的场合才能发动。从卡组把1只「怒怒怒」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_MOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 定义特殊召唤的过滤条件：对象不是战士族、属于「隆隆隆」系列，且可以被这个效果特殊召唤。
function s.spfilter(c,e,tp)
	return not c:IsRace(RACE_WARRIOR) and c:IsSetCard(0x59) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时点的合法性检查：自己场上存在可用怪兽区域，且手卡·卡组·墓地存在至少1只符合条件的「隆隆隆」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域空位，作为发动条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组·墓地是否存在至少1只满足s.spfilter的「隆隆隆」怪兽，作为发动条件之二。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向系统登记本效果将进行的从手卡·卡组·墓地的特殊召唤操作，供连锁处理与效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 执行①效果：从手卡·卡组·墓地选择1只符合条件的「隆隆隆」怪兽特殊召唤；成功后若这张卡仍为表侧攻击表示，则改为表侧守备表示；最后给发动者附加直到结束阶段的“非超量怪兽不能从额外卡组特殊召唤”限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res=false
	-- 效果处理时再次确认自己场上存在可用的怪兽区域。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 弹出“请选择要特殊召唤的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡·卡组·墓地选择1只符合条件的「隆隆隆」怪兽（墓地选择经过王家长眠之谷过滤），且不选择发动者自身。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上，并记录是否成功。
			res=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0
		end
	end
	if res and c:IsRelateToChain() and c:IsPosition(POS_FACEUP_ATTACK) then
		-- 中断当前效果处理，使随后的表示形式变更作为独立处理，避免错过时点。
		Duel.BreakEffect()
		-- 将这张卡从表侧攻击表示变为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
	-- 这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。②：超量素材的这张卡为让超量怪兽的效果发动而被取除的场合才能发动。从卡组把1只「怒怒怒」怪兽加入手卡。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTarget(s.splimit)
	-- 将自肃效果作为场地效果注册，使tp玩家在回合结束前不能从额外卡组特殊召唤非超量怪兽。
	Duel.RegisterEffect(e2,tp)
end
-- 自肃的判定条件：从额外卡组特殊召唤时，非超量怪兽不能特殊召唤。
function s.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
-- ②效果的发动条件：这张卡作为超量素材，因超量怪兽效果的发动而被取除（COST）的场合。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and c:IsPreviousLocation(LOCATION_OVERLAY)
end
-- 检索的过滤条件：属于「怒怒怒」系列的怪兽卡，且可以加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x82) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的发动条件：卡组中存在符合条件的「怒怒怒」怪兽；并登记本次操作信息为从卡组将1张卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1只满足s.thfilter的「怒怒怒」怪兽，以决定能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向系统登记本效果将进行的从卡组加入手卡的操作，供连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1只「怒怒怒」怪兽加入手卡，并让对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要加入手卡的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只符合条件的「怒怒怒」怪兽（效果处理时选择，不取对象）。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的「怒怒怒」怪兽加入其持有者的手卡（因效果）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片，以确认检索内容。
		Duel.ConfirmCards(1-tp,g)
	end
end
