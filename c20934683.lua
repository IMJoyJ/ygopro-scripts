--アザミナ・オフェイレーテス
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己·对方的主要阶段才能发动。额外卡组1只「蓟花」融合怪兽给对方观看，那个等级每4星为1张的「罪宝」卡从自己的手卡·场上送去墓地（里侧表示卡翻开确认）。那之后，给人观看的怪兽当作融合召唤作特殊召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「蓟花」怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册①效果（在主要阶段发动的融合特殊召唤效果，双方一回合各限一次使用①②之一）和②效果（墓地的起动效果，以墓地「蓟花」怪兽为对象特殊召唤）
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段才能发动。额外卡组1只「蓟花」融合怪兽给对方观看，那个等级每4星为1张的「罪宝」卡从自己的手卡·场上送去墓地（里侧表示卡翻开确认）。那之后，给人观看的怪兽当作融合召唤作特殊召唤。这个卡名的①②的效果1回合只能有1次使用其中任意1个。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「蓟花」怪兽为对象才能发动。那只怪兽特殊召唤。这个卡名的①②的效果1回合只能有1次使用其中任意1个。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置发动代价：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.fusion_effect=true
-- 发动条件：当前是自己或对方的主要阶段
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤条件：筛选额外卡组中等级4以上、可当作融合召唤特殊召唤、且能从手卡·场上的「罪宝」卡中选出其等级每4星1张的素材送去墓地的「蓟花」融合怪兽
function s.filter(c,e,tp,mg)
	if c:GetLevel()<4 then return false end
	local ct=math.floor(c:GetLevel()/4)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1bc) and c:CheckFusionMaterial()
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and mg:CheckSubGroup(s.gcheck,ct,ct,tp,c)
end
-- 素材子组检查：这组卡送去墓地后有能容纳额外卡组怪兽出场的空格，且其中所有卡都能送去墓地
function s.gcheck(g,tp,fc)
	-- 确认把这些卡从场上送去墓地后，仍有供额外卡组怪兽特殊召唤的怪兽区域空格
	return Duel.GetLocationCountFromEx(tp,tp,g,fc)>0
		and g:FilterCount(Card.IsAbleToGrave,nil)==g:GetCount()
end
-- ①效果的目标函数：检查手卡·场上的「罪宝」卡，并确认额外卡组存在满足条件的「蓟花」融合怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索自己手卡·场上所有的「罪宝」卡作为素材候选组
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil,0x19e)
	-- 检查是否存在受「必须成为融合素材」效果限制的卡
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 确认额外卡组存在至少1只满足条件的可特殊召唤的「蓟花」融合怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g) end
	-- 设置操作信息：将从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果的处理：选择额外卡组的「蓟花」融合怪兽给对方观看，将对应数量的「罪宝」卡送去墓地，再把那只怪兽当作融合召唤特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若存在必须成为融合素材的限制效果则不处理（该检查不通过时中断）
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 取得自己手卡·场上所有「罪宝」卡作为素材候选组
	local mg=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil,0x19e)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的「蓟花」融合怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
	local tc=g:GetFirst()
	if tc then
		-- 把选择的融合怪兽给对方观看确认
		Duel.ConfirmCards(1-tp,tc)
		local ct=math.floor(tc:GetLevel()/4)
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=mg:SelectSubGroup(tp,s.gcheck,false,ct,ct,tp,tc)
		local cg=sg:Filter(Card.IsFacedown,nil)
		-- 把送去墓地的卡中里侧表示的卡翻开给对方确认
		Duel.ConfirmCards(1-tp,cg)
		-- 将选出的「罪宝」卡送去墓地，并确认确实有卡被送去墓地
		if Duel.SendtoGrave(sg,REASON_EFFECT)~=0 and sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)~=0 then
			-- 中断效果处理，使送墓与之后的特殊召唤视为不同时处理
			Duel.BreakEffect()
			tc:SetMaterial(nil)
			-- 把给人观看的融合怪兽当作融合召唤特殊召唤到自己场上
			if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)>0 then
				tc:CompleteProcedure()
			end
		end
	end
end
-- 过滤条件：可以特殊召唤的「蓟花」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1bc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标函数：确认主要怪兽区域有空格且自己墓地存在可特殊召唤的「蓟花」怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 确认自己的主要怪兽区域有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己墓地存在至少1只可作为对象特殊召唤的「蓟花」怪兽（这张卡自身除外）
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 以自己墓地1只「蓟花」怪兽为对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：将特殊召唤作为对象的那1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的处理：把作为对象的墓地怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得作为对象的卡
	local tc=Duel.GetFirstTarget()
	-- 若对象仍与效果关联且不受王家长眠之谷影响，则将那只怪兽特殊召唤
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
