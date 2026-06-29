--アザミナ・オフェイレーテス
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己·对方的主要阶段才能发动。额外卡组1只「蓟花」融合怪兽给对方观看，那个等级每4星为1张的「罪宝」卡从自己的手卡·场上送去墓地（里侧表示卡翻开确认）。那之后，给人观看的怪兽当作融合召唤作特殊召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「蓟花」怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册融合召唤「阿萨密纳」融合怪兽的效果、以及墓地除外特召「阿萨密纳」怪兽的效果
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段才能发动。额外卡组1只「阿萨密纳」融合怪兽给对方观看，那只怪兽的等级每4星有1张的「罪宝」卡从自己的手卡·场上送去墓地（里侧表示卡翻开确认）。那之后，给人观看的怪兽当作融合召唤作特殊召唤。
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
	-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「阿萨密纳」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 将墓地的此卡除外作为效果发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.fusion_effect=true
-- 主要阶段的发动条件判断
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 确保当前正处于自己或对方的主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 可特召的额外卡组「阿萨密纳」融合怪兽的过滤条件
function s.filter(c,e,tp,mg)
	if c:GetLevel()<4 then return false end
	local ct=math.floor(c:GetLevel()/4)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1bc) and c:CheckFusionMaterial()
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and mg:CheckSubGroup(s.gcheck,ct,ct,tp,c)
end
-- 送去墓地的「罪宝」素材的数量及合法性检查条件
function s.gcheck(g,tp,fc)
	-- 检查在将素材送去墓地后，是否能腾出空位进行融合特殊召唤
	return Duel.GetLocationCountFromEx(tp,tp,g,fc)>0
		and g:FilterCount(Card.IsAbleToGrave,nil)==g:GetCount()
end
-- 融合特殊召唤效果的发动准备
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手卡和场上所有的「罪宝」卡片
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil,0x19e)
	-- 检查是否满足强制融合素材的系统规则限制
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 检查额外卡组中是否存在可以融合特殊召唤的「阿萨密纳」融合怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g) end
	-- 设置操作信息为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合特殊召唤效果的执行
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若不满足强制融合素材的系统限制，则效果不处理
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 获取自己手卡和场上所有的「罪宝」卡片
	local mg=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil,0x19e)
	-- 向玩家发送提示，请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择额外卡组中1只表侧表示的「阿萨密纳」融合怪兽为目标
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
	local tc=g:GetFirst()
	if tc then
		-- 向对方玩家展示选中的融合怪兽
		Duel.ConfirmCards(1-tp,tc)
		local ct=math.floor(tc:GetLevel()/4)
		-- 向玩家发送提示，请选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=mg:SelectSubGroup(tp,s.gcheck,false,ct,ct,tp,tc)
		local cg=sg:Filter(Card.IsFacedown,nil)
		-- 向对方玩家展示并确认选中素材中属于里侧表示的卡片
		Duel.ConfirmCards(1-tp,cg)
		-- 若选中的「罪宝」卡片成功送去墓地，则继续处理
		if Duel.SendtoGrave(sg,REASON_EFFECT)~=0 and sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)~=0 then
			-- 切断效果处理的连锁时点
			Duel.BreakEffect()
			tc:SetMaterial(nil)
			-- 将被展示的融合怪兽当作融合召唤特殊召唤到场上
			if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)>0 then
				tc:CompleteProcedure()
			end
		end
	end
end
-- 可从墓地特殊召唤的「阿萨密纳」怪兽的过滤条件
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1bc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 墓地特殊召唤效果的发动准备与对象选择
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空闲的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在可被特殊召唤的「阿萨密纳」怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 向玩家发送提示，请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地中1只满足条件的「阿萨密纳」怪兽为效果对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息为将选中的怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 墓地特殊召唤效果的执行
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选择特殊召唤的墓地怪兽对象
	local tc=Duel.GetFirstTarget()
	-- 将未受墓地无效效果影响的选中怪兽特殊召唤到自己场上
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
