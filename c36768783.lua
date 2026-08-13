--星導竜アーミライル
-- 效果：
-- 效果怪兽2只
-- 这张卡不能作为连接素材。这个卡名的效果1回合只能使用1次。
-- ①：以这张卡所连接区1只表侧表示怪兽为对象才能发动。原本等级和那只怪兽相同的1只怪兽从手卡往作为这张卡所连接区的自己场上守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c36768783.initial_effect(c)
	-- 为这张卡添加连接召唤手续：需要2只效果怪兽作为连接素材（连接2）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,2)
	c:EnableReviveLimit()
	-- 这张卡不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这个卡名的效果1回合只能使用1次。①：以这张卡所连接区1只表侧表示怪兽为对象才能发动。原本等级和那只怪兽相同的1只怪兽从手卡往作为这张卡所连接区的自己场上守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36768783,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,36768783)
	e2:SetTarget(c36768783.sptg)
	e2:SetOperation(c36768783.spop)
	c:RegisterEffect(e2)
end
-- 定义spfilter1：筛选可作为对象的怪兽，要求其表侧表示且位于这张卡所连接区、原本等级大于0，并且手牌中存在原本等级与之相同且能被特殊召唤的怪兽。
function c36768783.spfilter1(c,e,tp,zone,lg)
	local lv=c:GetOriginalLevel()
	-- 返回对象候选的判定结果：对象原本等级大于0、表侧表示、位于连接区，且手牌中存在满足条件的可特殊召唤怪兽。
	return lv>0 and c:IsFaceup() and lg:IsContains(c) and Duel.IsExistingMatchingCard(c36768783.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp,lv,zone)
end
-- 定义spfilter2：筛选手牌中要特殊召唤的怪兽，要求其原本等级与对象怪兽相同，并且能够以表侧守备表示被玩家tp特殊召唤到指定区域。
function c36768783.spfilter2(c,e,tp,lv,zone)
	return c:GetOriginalLevel()==lv and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tp,zone)
end
-- 定义spfilter_chkc：在连锁确认时用于校验选择的对象，要求对象表侧表示、位于这张卡所连接区且原本等级等于记录的目标等级。
function c36768783.spfilter_chkc(c,e,tp,lv,lg)
	return c:IsFaceup() and lg:IsContains(c) and c:GetOriginalLevel()==lv
end
-- 定义sptg：效果发动时的目标选择流程。获取本卡、连接区域和连接组；若是选择对象确认则检查对象合法性；若为发动合法性检查则确认存在符合条件的对象；随后提示玩家选择对象并将所选对象设为效果对象，同时记录其原本等级。
function c36768783.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)
	local lg=c:GetLinkedGroup()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c36768783.spfilter_chkc(chkc,e,tp,e:GetLabel(),lg) end
	-- 发动合法性检查：确认场上存在符合条件的表侧表示对象（位于这张卡所连接区且手牌有可特殊召唤的对应等级怪兽）。
	if chk==0 then return Duel.IsExistingTarget(c36768783.spfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp,zone,lg) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从符合条件的怪兽中选择1只作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c36768783.spfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp,zone,lg)
	-- 设置操作信息：该效果将进行特殊召唤，预计从手卡特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	e:SetLabel(g:GetFirst():GetOriginalLevel())
end
-- 定义spop：效果处理时先取得本卡和对象，判断双方是否仍与效果关联且对象未变里侧；随后从手牌选择符合等级条件的怪兽，以表侧守备表示特殊召唤到这张卡所连接区，并对成功特殊召唤的怪兽赋予效果无效化。
function c36768783.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	local zone=c:GetLinkedZone(tp)
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1只原本等级与对象怪兽相同且可以特殊召唤的怪兽。
	local g=Duel.SelectMatchingCard(tp,c36768783.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp,tc:GetOriginalLevel(),zone)
	local sc=g:GetFirst()
	if sc then
		-- 使用SpecialSummonStep将选择的怪兽以表侧守备表示特殊召唤到这张卡所连接区，并检查特殊召唤是否成功（需满足召唤条件及苏生限制）。
		if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE,zone) then
			-- 这个效果特殊召唤的怪兽的效果无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1)
			-- 这个效果特殊召唤的怪兽的效果无效化。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e2)
		end
		-- 完成连锁处理中的特殊召唤（与SpecialSummonStep配合），使之前设置的特殊召唤及相关无效化效果正式生效。
		Duel.SpecialSummonComplete()
	end
end
