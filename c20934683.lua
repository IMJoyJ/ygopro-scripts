--アザミナ・オフェイレーテス
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己·对方的主要阶段才能发动。额外卡组1只「蓟花」融合怪兽给对方观看，那个等级每4星为1张的「罪宝」卡从自己的手卡·场上送去墓地（里侧表示卡翻开确认）。那之后，给人观看的怪兽当作融合召唤作特殊召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「蓟花」怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册两个效果：①融合召唤效果和②从墓地特殊召唤效果
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段才能发动。额外卡组1只「蓟花」融合怪兽给对方观看，那个等级每4星为1张的「罪宝」卡从自己的手卡·场上送去墓地（里侧表示卡翻开确认）。那之后，给人观看的怪兽当作融合召唤作特殊召唤。
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
	-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「蓟花」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.fusion_effect=true
-- 判断当前是否为自己的主要阶段
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤满足条件的融合怪兽：等级大于等于4，为融合类型，属于蓟花卡组，能作为融合素材，可以特殊召唤
function s.filter(c,e,tp,mg)
	if c:GetLevel()<4 then return false end
	local ct=math.floor(c:GetLevel()/4)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1bc) and c:CheckFusionMaterial()
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and mg:CheckSubGroup(s.gcheck,ct,ct,tp,c)
end
-- 检查融合素材组是否满足召唤条件：场地空位足够且所有卡都能送去墓地
function s.gcheck(g,tp,fc)
	-- 检查额外卡组的怪兽是否能特殊召唤
	return Duel.GetLocationCountFromEx(tp,tp,g,fc)>0
		and g:FilterCount(Card.IsAbleToGrave,nil)==g:GetCount()
end
-- 设置连锁处理信息：准备特殊召唤1只额外卡组的融合怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手牌和场上的罪宝卡组的卡
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil,0x19e)
	-- 检查是否满足融合召唤的必要素材条件
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 检查是否存在满足条件的融合怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g) end
	-- 设置连锁处理信息：准备特殊召唤1只额外卡组的融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行融合召唤效果：选择融合怪兽，确认其为对方观看，选择罪宝卡组的卡送去墓地，然后特殊召唤该融合怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查是否满足融合召唤的必要素材条件
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 获取手牌和场上的罪宝卡组的卡
	local mg=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil,0x19e)
	-- 提示玩家选择要特殊召唤的融合怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的融合怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
	local tc=g:GetFirst()
	if tc then
		-- 向对方展示所选的融合怪兽
		Duel.ConfirmCards(1-tp,tc)
		local ct=math.floor(tc:GetLevel()/4)
		-- 提示玩家选择要送去墓地的罪宝卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=mg:SelectSubGroup(tp,s.gcheck,false,ct,ct,tp,tc)
		local cg=sg:Filter(Card.IsFacedown,nil)
		-- 向对方展示所选的里侧表示的罪宝卡
		Duel.ConfirmCards(1-tp,cg)
		-- 将罪宝卡送去墓地并判断是否成功
		if Duel.SendtoGrave(sg,REASON_EFFECT)~=0 and sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)~=0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			tc:SetMaterial(nil)
			-- 将融合怪兽特殊召唤
			if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP) then
				tc:CompleteProcedure()
			end
		end
	end
end
-- 过滤墓地中的蓟花怪兽：属于蓟花卡组，可以特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1bc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置墓地特殊召唤效果的处理信息：选择墓地中的蓟花怪兽作为对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查场上是否有足够的召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的蓟花怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的蓟花怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的蓟花怪兽作为对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理信息：准备特殊召唤1只墓地中的蓟花怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行墓地特殊召唤效果：选择墓地中的蓟花怪兽并特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然有效并满足特殊召唤条件，然后特殊召唤
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
