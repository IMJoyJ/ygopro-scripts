--スプリガンズ・コール！
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只「护宝炮妖」怪兽或者「阿不思的落胤」为对象才能发动。那只怪兽特殊召唤。
-- ②：从自己墓地把1只融合怪兽和这个回合没有送去墓地的这张卡除外，以自己场上1只「护宝炮妖」超量怪兽为对象才能发动。从额外卡组把以「阿不思的落胤」为融合素材的1只融合怪兽作为那只怪兽的超量素材。
function c83199011.initial_effect(c)
	-- 记录这张卡上记载了「阿不思的落胤」的卡名
	aux.AddCodeList(c,68468459)
	-- ①：以自己墓地1只「护宝炮妖」怪兽或者「阿不思的落胤」为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83199011,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,83199011)
	e1:SetTarget(c83199011.sptg)
	e1:SetOperation(c83199011.spop)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把1只融合怪兽和这个回合没有送去墓地的这张卡除外，以自己场上1只「护宝炮妖」超量怪兽为对象才能发动。从额外卡组把以「阿不思的落胤」为融合素材的1只融合怪兽作为那只怪兽的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83199011,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,83199012)
	-- 限制该效果在送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	e2:SetCost(c83199011.ovcost)
	e2:SetTarget(c83199011.ovtg)
	e2:SetOperation(c83199011.ovop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中可以特殊召唤的「护宝炮妖」怪兽或「阿不思的落胤」
function c83199011.spfilter(c,e,tp)
	return (c:IsSetCard(0x155) and c:IsType(TYPE_MONSTER) or c:IsCode(68468459)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备与目标选择
function c83199011.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c83199011.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空格，以及自己墓地是否存在可以特殊召唤的「护宝炮妖」怪兽或「阿不思的落胤」
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c83199011.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c83199011.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息为特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的处理
function c83199011.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己墓地中可以作为cost除外的融合怪兽
function c83199011.costfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsAbleToRemoveAsCost()
end
-- ②效果的发动代价处理
function c83199011.ovcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地的这张卡是否能作为cost除外，以及自己墓地是否存在其他可以除外的融合怪兽
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(c83199011.costfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地1只满足条件的融合怪兽
	local g=Duel.SelectMatchingCard(tp,c83199011.costfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将选中的卡片作为发动代价除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤自己场上表侧表示的「护宝炮妖」超量怪兽
function c83199011.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x155) and c:IsType(TYPE_XYZ)
end
-- 过滤额外卡组中以「阿不思的落胤」为融合素材的融合怪兽，且该卡可以作为超量素材
function c83199011.ovfilter(c,e)
	-- 判断卡片是否为融合怪兽、是否以「阿不思的落胤」为融合素材、是否能作为超量素材，且不受当前效果影响
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459) and c:IsCanOverlay() and (not e or not c:IsImmuneToEffect(e))
end
-- ②效果的发动准备与目标选择
function c83199011.ovtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c83199011.tgfilter(chkc) end
	-- 检查自己场上是否存在可以作为对象的「护宝炮妖」超量怪兽，以及额外卡组是否存在可以作为超量素材的融合怪兽
	if chk==0 then return Duel.IsExistingTarget(c83199011.tgfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(c83199011.ovfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的「护宝炮妖」超量怪兽作为效果的对象
	Duel.SelectTarget(tp,c83199011.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果的处理
function c83199011.ovop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象超量怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 提示玩家选择要作为超量素材的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 从额外卡组选择1只以「阿不思的落胤」为融合素材的融合怪兽
		local g=Duel.SelectMatchingCard(tp,c83199011.ovfilter,tp,LOCATION_EXTRA,0,1,1,nil,e)
		local oc=g:GetFirst()
		if oc then
			-- 将选中的融合怪兽重叠在对象超量怪兽下面作为超量素材
			Duel.Overlay(tc,oc)
		end
	end
end
