--アスピスクール
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤时才能发动。从手卡把1只6星以下的鱼族怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
-- ②：这张卡被除外的场合才能发动。这张卡守备表示特殊召唤。
local s,id,o=GetID()
-- 创建并注册两个诱发效果：①召唤成功时，从手卡把1只6星以下的鱼族怪兽守备表示特殊召唤，且该怪兽离场时除外；②自身被除外的场合，自身守备表示特殊召唤，且②效果一回合只能使用1次。
function s.initial_effect(c)
	-- ①：这张卡召唤时才能发动。从手卡把1只6星以下的鱼族怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡被除外的场合才能发动。这张卡守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"这张卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 定义选择手牌怪兽的过滤函数：必须是鱼族、6星以下，且能够以表侧守备表示被当前效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_FISH) and c:IsLevelBelow(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的发动条件判定：己方主要怪兽区存在空位，且手牌中存在至少1只满足s.spfilter条件的怪兽。
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动时己方主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌是否存在至少1只符合条件的鱼族怪兽（6星以下且可表侧守备特殊召唤）。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本效果要进行的处理是特殊召唤，处理时从手牌特殊召唤1只怪兽（数量1，来源为手牌）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果处理：先确认己方主要怪兽区仍有空位；然后提示玩家选择要特殊召唤的卡，从手牌中选择1只符合条件的鱼族怪兽；若选择成功且该怪兽能被表侧守备特殊召唤，则先将其纳入特殊召唤处理，并给它附加“离场时除外”的效果；最后完成特殊召唤流程。
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认己方主要怪兽区是否有空位，若没有空位则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示信息，提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手牌中选择1张满足s.spfilter条件的卡（鱼族、6星以下、可表侧守备特殊召唤），返回选中的卡组g。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功选中怪兽且该怪兽能通过特殊召唤处理（以表侧守备表示特殊召唤），则开始执行特殊召唤步骤。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这个效果特殊召唤的怪兽从场上离开的场合除外。②：这张卡被除外的场合才能发动。这张卡守备表示特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)
	end
	-- 完成由SpecialSummonStep累积的特殊召唤，将进行过特殊召唤步骤的怪兽实际特殊召唤上场。
	Duel.SpecialSummonComplete()
end
-- ②效果的发动条件判定：己方主要怪兽区存在空位，且这张卡自身能够以表侧守备表示被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：本效果要进行的处理是特殊召唤，对象是效果怪兽自身（e:GetHandler()），数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与当前连锁有联系（仍在除外区未被其他效果移动），则将其表侧守备表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧守备表示特殊召唤到玩家tp的场上（从除外区回到主要怪兽区）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
