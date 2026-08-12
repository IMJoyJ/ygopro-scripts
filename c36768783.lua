--星導竜アーミライル
-- 效果：
-- 效果怪兽2只
-- 这张卡不能作为连接素材。这个卡名的效果1回合只能使用1次。
-- ①：以这张卡所连接区1只表侧表示怪兽为对象才能发动。原本等级和那只怪兽相同的1只怪兽从手卡往作为这张卡所连接区的自己场上守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c36768783.initial_effect(c)
	-- 为这张卡添加连接召唤手续，要求使用2只满足类型为效果怪兽的卡作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,2)
	c:EnableReviveLimit()
	-- 这张卡不能作为连接素材
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：以这张卡所连接区1只表侧表示怪兽为对象才能发动。原本等级和那只怪兽相同的1只怪兽从手卡往作为这张卡所连接区的自己场上守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
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
-- 过滤函数，用于判断目标怪兽是否满足条件：等级大于0、表侧表示、在连接区、且手牌中有相同等级的怪兽可以特殊召唤
function c36768783.spfilter1(c,e,tp,zone,lg)
	local lv=c:GetOriginalLevel()
	-- 等级大于0、表侧表示、在连接区、且手牌中有相同等级的怪兽可以特殊召唤
	return lv>0 and c:IsFaceup() and lg:IsContains(c) and Duel.IsExistingMatchingCard(c36768783.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp,lv,zone)
end
-- 过滤函数，用于判断手牌中的怪兽是否满足条件：等级与目标怪兽相同、可以特殊召唤到指定位置
function c36768783.spfilter2(c,e,tp,lv,zone)
	return c:GetOriginalLevel()==lv and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tp,zone)
end
-- 过滤函数，用于判断目标怪兽是否满足条件：表侧表示、在连接区、等级与目标等级相同
function c36768783.spfilter_chkc(c,e,tp,lv,lg)
	return c:IsFaceup() and lg:IsContains(c) and c:GetOriginalLevel()==lv
end
-- 效果处理函数，设置效果的目标为连接区的1只表侧表示怪兽，并检查是否有满足条件的怪兽
function c36768783.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)
	local lg=c:GetLinkedGroup()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c36768783.spfilter_chkc(chkc,e,tp,e:GetLabel(),lg) end
	-- 检查是否满足效果发动条件：连接区存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c36768783.spfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp,zone,lg) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的1只目标怪兽
	local g=Duel.SelectTarget(tp,c36768783.spfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp,zone,lg)
	-- 设置效果操作信息，表示将特殊召唤1张手牌中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	e:SetLabel(g:GetFirst():GetOriginalLevel())
end
-- 效果处理函数，处理特殊召唤和效果无效化
function c36768783.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	local zone=c:GetLinkedZone(tp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的手牌怪兽
	local g=Duel.SelectMatchingCard(tp,c36768783.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp,tc:GetOriginalLevel(),zone)
	local sc=g:GetFirst()
	if sc then
		-- 尝试特殊召唤选定的怪兽
		if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE,zone) then
			-- 使特殊召唤的怪兽效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1)
			-- 使特殊召唤的怪兽效果无效化
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e2)
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
