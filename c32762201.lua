--古代の機械像
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合，这张卡可以从手卡特殊召唤。
-- ②：把这张卡解放才能发动。除「古代的机械像」外的1只「古代的机械巨人」或者有那个卡名记述的怪兽从手卡·卡组无视召唤条件特殊召唤。
local s,id,o=GetID()
-- 注册两个效果：用aux.AddCodeList登记效果文本中记载的「古代的机械巨人」；e1为手卡中的规则特殊召唤效果（①），e2为场上的起动效果（②）。
function s.initial_effect(c)
	-- 登记本卡效果文本中记载了「古代的机械巨人」（卡号83104731），供后续判断“有那个卡名记述的怪兽”时使用。
	aux.AddCodeList(c,83104731)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：对方场上的怪兽数量比自己场上的怪兽多的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：把这张卡解放才能发动。除「古代的机械像」外的1只「古代的机械巨人」或者有那个卡名记述的怪兽从手卡·卡组无视召唤条件特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①规则特殊召唤的条件函数：当c为nil时视为该特殊召唤手续本身可用；否则要求自己场上有空余怪兽区，且对方场上的怪兽数量多于自己场上的怪兽数量。
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否还有可用的主要怪兽区，以确保能够从手卡特殊召唤。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 比较双方场上怪兽数量，满足对方怪兽数量比自己怪兽数量多的条件时，才能进行①的特殊召唤。
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)<Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)
end
-- ②效果的代价函数：确认这张卡可以解放后，将其解放作为发动代价。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将发动效果的这张卡以解放作为代价送入墓地。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义②效果可特殊召唤的怪兽的筛选条件：必须是「古代的机械巨人」或效果文本中记载了「古代的机械巨人」的怪兽，且不能是「古代的机械像」自身，并且可以无视召唤条件特殊召唤。
function s.spfilter(c,e,tp)
	-- 筛选条件具体为：卡名是83104731（古代的机械巨人）或卡名记述了83104731的怪兽；必须是怪兽卡；不能是本卡（古代的机械像）；且能被无视召唤条件地特殊召唤。
	return (c:IsCode(83104731) or aux.IsCodeListed(c,83104731)) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ②效果的发动目标判定：自己场上有空余怪兽区，且手卡·卡组中存在至少1只符合s.spfilter条件的怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时需要确认自己场上有可用的怪兽区，用于后续特殊召唤。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 发动时需要确认从手卡·卡组存在至少1只符合条件的怪兽可以特殊召唤。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 将本次连锁的操作信息设定为特殊召唤，数量为1，来源为手卡·卡组，用于效果发动后的时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果处理时的操作：若仍有可用怪兽区，则让玩家从手卡·卡组选择1只符合条件的怪兽，将其无视召唤条件以表侧表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上仍有空余的怪兽区，若已无空格则不进行处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡·卡组中选择1张符合s.spfilter条件的怪兽卡。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽无视召唤条件，以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
