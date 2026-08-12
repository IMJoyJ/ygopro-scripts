--プログレオ
-- 效果：
-- 衍生物以外的怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡是已连接召唤的场合，把这张卡所连接区1只自己怪兽和这张卡除外，以自己或者对方的墓地1只连接怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
function c52615248.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用非衍生物的怪兽作为连接素材，最少2个，最多2个
	aux.AddLinkProcedure(c,aux.NOT(aux.FilterBoolFunction(Card.IsLinkType,TYPE_TOKEN)),2,2)
	-- ①：这张卡是已连接召唤的场合，把这张卡所连接区1只自己怪兽和这张卡除外，以自己或者对方的墓地1只连接怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52615248,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,52615248)
	e1:SetCondition(c52615248.spcon)
	e1:SetCost(c52615248.spcost)
	e1:SetTarget(c52615248.sptg)
	e1:SetOperation(c52615248.spop)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：此卡必须是通过连接召唤方式出场的
function c52615248.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 用于筛选满足条件的怪兽作为除外的素材，必须是与当前处理的卡片连接的怪兽，并且可以被除外作为代价，同时确保场上还有足够的怪兽区域
function c52615248.costfilter(c,tp,mc)
	local lg=mc:GetLinkedGroup()
	-- 判断所选怪兽是否为当前处理卡片的连接怪兽、是否能除外作为代价、以及是否满足场上怪兽区域数量要求
	return lg:IsContains(c) and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,Group.FromCards(c,mc))>0
end
-- 设置效果发动的费用：检查是否有满足条件的怪兽可以除外作为代价，同时此卡本身也能被除外
function c52615248.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否存在满足costfilter条件的怪兽（即连接怪兽）可作为除外代价
	if chk==0 then return Duel.IsExistingMatchingCard(c52615248.costfilter,tp,LOCATION_MZONE,0,1,c,tp,c)
		and c:IsAbleToRemoveAsCost() end
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1只怪兽作为除外的代价
	local g=Duel.SelectMatchingCard(tp,c52615248.costfilter,tp,LOCATION_MZONE,0,1,1,c,tp,c)
	g:AddCard(c)
	-- 将选中的怪兽除外作为发动效果的费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 用于筛选墓地中可以特殊召唤的连接怪兽
function c52615248.spfilter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的目标：从墓地中选择一只连接怪兽作为特殊召唤的对象
function c52615248.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c52615248.spfilter(chkc,e,tp) end
	-- 检查是否存在满足spfilter条件的墓地怪兽可作为特殊召唤对象
	if chk==0 then return Duel.IsExistingTarget(c52615248.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择一只满足条件的墓地连接怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c52615248.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置效果操作信息，确定特殊召唤的怪兽数量和目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行效果的操作：将选中的墓地怪兽特殊召唤到场上，并设置其离场时除外的效果
function c52615248.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然存在于场上并成功进行特殊召唤步骤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 为特殊召唤的怪兽添加效果，使其在从场上离开时被除外
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		tc:RegisterEffect(e1,true)
	end
	-- 完成所有特殊召唤的操作处理
	Duel.SpecialSummonComplete()
end
