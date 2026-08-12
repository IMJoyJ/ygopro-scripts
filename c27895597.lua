--フォーチュンレディ・コーリング
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「命运女郎」怪兽存在的场合才能发动。同名卡不在自己场上存在的1只「命运女郎」怪兽从卡组特殊召唤。这张卡的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
function c27895597.initial_effect(c)
	-- ①：自己场上有「命运女郎」怪兽存在的场合才能发动。同名卡不在自己场上存在的1只「命运女郎」怪兽从卡组特殊召唤。这张卡的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,27895597+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c27895597.spcon)
	e1:SetTarget(c27895597.sptg)
	e1:SetOperation(c27895597.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查场上是否存在「命运女郎」怪兽（正面表示）
function c27895597.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x31)
end
-- 效果条件函数，判断自己场上是否存在「命运女郎」怪兽
function c27895597.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以自己为视角的场上是否存在至少1张「命运女郎」怪兽
	return Duel.IsExistingMatchingCard(c27895597.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，检查卡组中是否存在满足条件的「命运女郎」怪兽（可特殊召唤且场上无同名卡）
function c27895597.tfilter(c,e,tp)
	return c:IsSetCard(0x31) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查场上是否存在与该怪兽同名且正面表示的怪兽
		and not Duel.IsExistingMatchingCard(c27895597.bfilter,tp,LOCATION_ONFIELD,0,1,nil,c)
end
-- 过滤函数，检查场上是否存在与指定怪兽同名且正面表示的怪兽
function c27895597.bfilter(c,tc)
	return tc:IsCode(c:GetCode()) and c:IsFaceup()
end
-- 效果发动时的处理函数，判断是否满足发动条件
function c27895597.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的「命运女郎」怪兽
		and Duel.IsExistingMatchingCard(c27895597.tfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤1只「命运女郎」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行特殊召唤操作并设置后续限制
function c27895597.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择满足条件的1只「命运女郎」怪兽
		local g=Duel.SelectMatchingCard(tp,c27895597.tfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- ①：自己场上有「命运女郎」怪兽存在的场合才能发动。同名卡不在自己场上存在的1只「命运女郎」怪兽从卡组特殊召唤。这张卡的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c27895597.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果函数，禁止非同调怪兽从额外卡组特殊召唤
function c27895597.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
