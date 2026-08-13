--マシンナーズ・メガフォーム
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把这张卡解放才能发动。从手卡·卡组把「机甲部队·超大变形」以外的1只「机甲」怪兽特殊召唤。
-- ②：这张卡在墓地存在的状态，自己场上的「机甲要塞」被送去自己墓地的场合，把那1只「机甲要塞」从墓地除外才能发动。这张卡特殊召唤。
function c51617185.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：把这张卡解放才能发动。从手卡·卡组把「机甲部队·超大变形」以外的1只「机甲」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51617185,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,51617185)
	e1:SetCost(c51617185.spcost1)
	e1:SetTarget(c51617185.sptg1)
	e1:SetOperation(c51617185.spop1)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：这张卡在墓地存在的状态，自己场上的「机甲要塞」被送去自己墓地的场合，把那1只「机甲要塞」从墓地除外才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51617185,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,51617185)
	e2:SetCost(c51617185.spcost2)
	e2:SetTarget(c51617185.sptg2)
	e2:SetOperation(c51617185.spop2)
	c:RegisterEffect(e2)
end
-- 效果①的代价判定与执行：确认这张卡当前可以被解放后，将其解放作为发动代价。
function c51617185.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡作为代价解放送去墓地。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 特殊召唤候选的筛选条件：拥有「机甲」字段（0x36）、卡名不是「机甲部队·超大变形」本身、并且满足特殊召唤的规则限制。
function c51617185.spfilter(c,e,tp)
	return c:IsSetCard(0x36) and not c:IsCode(51617185) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①发动时的条件判定：因为发动代价会解放自身并空出区域，所以只需场上区域数大于-1，并且自己手卡·卡组中存在符合条件的「机甲」怪兽可供特殊召唤。
function c51617185.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上可用的怪兽区域数量是否允许发动（代价解放后会有空位，因此允许当前无空位的情况）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查自己手卡·卡组是否存在至少1张满足spfilter条件的「机甲」怪兽。
		and Duel.IsExistingMatchingCard(c51617185.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 将此次效果处理标记为特殊召唤操作，来源为手卡·卡组，数量为1，操作玩家为tp，以便后续连锁和卡片检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果①的最终处理：若自己场上仍有可用怪兽区域，则从手卡·卡组选择1只符合条件的「机甲」怪兽，以表侧表示特殊召唤到自己场上。
function c51617185.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认场上是否有可用怪兽区域，若已无空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家tp显示“请选择要特殊召唤的卡”的提示文字，用于下一步选卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己手卡·卡组中筛选并选择1只满足条件的「机甲」怪兽，该怪兽同时需能被正常特殊召唤。
	local g=Duel.SelectMatchingCard(tp,c51617185.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到玩家tp的怪兽区域，完成特殊召唤处理。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②中可被除外作为代价的「机甲要塞」的判定条件：卡名必须是「机甲要塞」（5556499）、当前控制者是自己、刚才是从自己的场上表侧表示被送去自己墓地、并且可以作为代价从墓地除外。
function c51617185.cfilter(c,tp)
	return c:IsCode(5556499) and c:IsControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(tp) and c:IsAbleToRemoveAsCost()
end
-- 效果②的代价检测与执行：确认本次送去墓地的卡组不包括本卡，且其中存在符合条件的「机甲要塞」；之后从这些「机甲要塞」中选择1只从墓地除外作为代价。
function c51617185.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not eg:IsContains(e:GetHandler()) and eg:IsExists(c51617185.cfilter,1,nil,tp) end
	-- 给玩家tp显示“请选择要除外的卡”的提示文字，用于选择作为代价的「机甲要塞」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local g=eg:FilterSelect(tp,c51617185.cfilter,1,1,nil,tp)
	-- 将选中的「机甲要塞」从墓地除外，作为效果②发动的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②发动时的条件判定：自己场上需要有可用怪兽区域，且墓地中的本卡可以被特殊召唤，满足这些条件后设置特殊召唤操作信息。
function c51617185.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1个可用的怪兽区域，用于后续特殊召唤本卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，声明本次效果将把墓地中的本卡特殊召唤到自己场上（数量1，目标玩家为自己的怪兽区）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的最终处理：若墓地中的本卡仍与该效果相关联（没有被除外或移动），则将其以表侧表示特殊召唤到自己场上。
function c51617185.spop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将墓地中的本卡以表侧表示特殊召唤到玩家tp的怪兽区域。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
