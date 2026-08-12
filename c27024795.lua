--極星霊アルヴィース
-- 效果：
-- 这个卡名的②的效果在决斗中只能使用1次。
-- ①：「极星」连接怪兽的效果只让这张卡被除外的场合才能发动。等级合计直到10的「极星」怪兽从自己场上1只，从卡组2只送去墓地。那之后，从额外卡组把1只「极神」怪兽特殊召唤。
-- ②：自己的「极神」怪兽因战斗以外的方法被对方送去墓地的场合，把墓地的这张卡除外才能发动。同名卡不在自己墓地的1只「极神」怪兽从额外卡组特殊召唤。
function c27024795.initial_effect(c)
	-- ①：「极星」连接怪兽的效果只让这张卡被除外的场合才能发动。等级合计直到10的「极星」怪兽从自己场上1只，从卡组2只送去墓地。那之后，从额外卡组把1只「极神」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27024795,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_REMOVE)
	e1:SetRange(LOCATION_REMOVED)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c27024795.spcon)
	e1:SetTarget(c27024795.sptg)
	e1:SetOperation(c27024795.spop)
	c:RegisterEffect(e1)
	-- ②：自己的「极神」怪兽因战斗以外的方法被对方送去墓地的场合，把墓地的这张卡除外才能发动。同名卡不在自己墓地的1只「极神」怪兽从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27024795,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,27024795+EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(c27024795.spcon2)
	-- 将这张卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c27024795.sptg2)
	e2:SetOperation(c27024795.spop2)
	c:RegisterEffect(e2)
end
-- 效果发动的条件：被除外的卡是这张卡，且除外的卡是「极星」连接怪兽
function c27024795.spcon(e,tp,eg,ep,ev,re,r,rp)
	return #eg==1 and eg:GetFirst()==e:GetHandler() and re and re:IsActiveType(TYPE_LINK) and re:GetHandler():IsSetCard(0x42)
end
-- 用于筛选满足条件的「极星」怪兽作为素材
function c27024795.matfilter(c)
	return c:IsSetCard(0x42) and c:IsType(TYPE_MONSTER) and (c:IsFaceup() or c:IsLocation(LOCATION_DECK)) and c:IsLevelAbove(1)
end
-- 用于判断所选的3张卡是否满足等级合计为10且其中2张来自卡组
function c27024795.fgoal(sg,e,tp)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)==2 and sg:GetSum(Card.GetLevel)==10
		-- 确保从额外卡组可以特殊召唤符合条件的「极神」怪兽
		and Duel.IsExistingMatchingCard(c27024795.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg)
end
-- 用于筛选可以特殊召唤的「极神」怪兽
function c27024795.spfilter(c,e,tp,mg)
	-- 确保所选的「极神」怪兽可以被特殊召唤且场上存在召唤空间
	return c:IsSetCard(0x4b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
-- 设置效果处理时的操作信息：将3张卡送去墓地，1只怪兽特殊召唤
function c27024795.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取所有满足条件的「极星」怪兽作为素材候选
		local mg=Duel.GetMatchingGroup(c27024795.matfilter,tp,LOCATION_DECK+LOCATION_MZONE,0,nil)
		return mg:CheckSubGroup(c27024795.fgoal,3,3,e,tp)
	end
	-- 设置将3张卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,3,tp,LOCATION_DECK+LOCATION_MZONE)
	-- 设置从额外卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：选择3张满足条件的卡送去墓地，然后从额外卡组特殊召唤1只怪兽
function c27024795.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有满足条件的「极星」怪兽作为素材候选
	local mg=Duel.GetMatchingGroup(c27024795.matfilter,tp,LOCATION_DECK+LOCATION_MZONE,0,nil)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=mg:SelectSubGroup(tp,c27024795.fgoal,false,3,3,e,tp)
	-- 将选中的卡送去墓地，若成功送去3张则继续处理
	if sg and Duel.SendtoGrave(sg,REASON_EFFECT)==3 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择从额外卡组特殊召唤的「极神」怪兽
		local tg=Duel.SelectMatchingCard(tp,c27024795.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
		if tg:GetCount()>0 then
			-- 中断当前效果处理，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 将选中的「极神」怪兽特殊召唤到场上
			Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 用于筛选被送去墓地的「极神」怪兽
function c27024795.cfilter(c,tp)
	return c:IsPreviousSetCard(0x4b) and c:IsPreviousControler(tp)
end
-- 效果发动的条件：对方将「极神」怪兽送去墓地且不是通过战斗
function c27024795.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and eg:IsExists(c27024795.cfilter,1,nil,tp)
end
-- 用于筛选可以特殊召唤的「极神」怪兽
function c27024795.spfilter2(c,e,tp)
	-- 确保所选的「极神」怪兽可以被特殊召唤且场上存在召唤空间
	return c:IsSetCard(0x4b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		-- 确保同名卡不在自己墓地
		and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
end
-- 设置效果处理时的操作信息：从额外卡组特殊召唤1只怪兽
function c27024795.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以特殊召唤至少1只「极神」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c27024795.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置从额外卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：从额外卡组特殊召唤1只符合条件的「极神」怪兽
function c27024795.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择从额外卡组特殊召唤的「极神」怪兽
	local g=Duel.SelectMatchingCard(tp,c27024795.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的「极神」怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
