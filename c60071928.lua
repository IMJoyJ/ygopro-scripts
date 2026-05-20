--ライティ・ドライバー
-- 效果：
-- 这张卡可以作为「同调士」调整的代替而成为同调素材。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤成功的场合才能发动。从自己的手卡·卡组·墓地选1只「左起子」特殊召唤。
function c60071928.initial_effect(c)
	-- ①：这张卡召唤成功的场合才能发动。从自己的手卡·卡组·墓地选1只「左起子」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60071928,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,60071928)
	e1:SetTarget(c60071928.sptg)
	e1:SetOperation(c60071928.spop)
	c:RegisterEffect(e1)
	-- 这张卡可以作为「同调士」调整的代替而成为同调素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(20932152)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查卡片是否为「左起子」且可以被特殊召唤
function c60071928.spfilter(c,e,tp)
	return c:IsCode(44935634) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①号效果的发动准备与可行性检测函数
function c60071928.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动阶段，检查自己的手卡、卡组、墓地是否存在至少1只可以特殊召唤的「左起子」
		and Duel.IsExistingMatchingCard(c60071928.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息，表明此效果包含从手卡、卡组、墓地特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- ①号效果的实际处理函数
function c60071928.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理阶段，若自己场上已无空余的怪兽区域，则不进行处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡、卡组、墓地中选择1只「左起子」（此操作受「王家长眠之谷」影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c60071928.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到发动效果的玩家场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
