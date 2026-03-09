--計量機塊カッパスケール
-- 效果：
-- 「机块」怪兽1只
-- 这个卡名的①②的效果1回合各能使用1次。这张卡在连接召唤的回合不能作为连接素材。
-- ①：把互相连接状态的这张卡解放才能发动。从自己墓地选「计量机块 电子秤河童」以外的1只「机块」连接怪兽特殊召唤。
-- ②：把不在互相连接状态的这张卡解放才能发动。从自己墓地选1只4星以下的「机块」怪兽特殊召唤。
function c4729591.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用1只以上满足过滤条件的「机块」怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x14b),1,1)
	-- ①：把互相连接状态的这张卡解放才能发动。从自己墓地选「计量机块 电子秤河童」以外的1只「机块」连接怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(c4729591.lmlimit)
	c:RegisterEffect(e1)
	-- ②：把不在互相连接状态的这张卡解放才能发动。从自己墓地选1只4星以下的「机块」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4729591,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,4729591)
	e2:SetCost(c4729591.spcost1)
	e2:SetTarget(c4729591.sptg1)
	e2:SetOperation(c4729591.spop1)
	c:RegisterEffect(e2)
	-- 将卡片设置为不能作为连接素材的效果，仅在本回合通过连接召唤特殊召唤时生效
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4729591,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,4729592)
	e3:SetCost(c4729591.spcost2)
	e3:SetTarget(c4729591.sptg2)
	e3:SetOperation(c4729591.spop2)
	c:RegisterEffect(e3)
end
-- 判断该卡是否在本回合通过连接召唤特殊召唤
function c4729591.lmlimit(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 检查发动效果时是否满足条件：互相连接状态的这张卡且可以解放
function c4729591.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetMutualLinkedGroupCount()>0 and e:GetHandler():IsReleasable() end
	-- 以支付代价的方式解放自身
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤满足「机块」属性、连接类型、非本卡、可特殊召唤的墓地怪兽
function c4729591.spfilter1(c,e,tp)
	return c:IsSetCard(0x14b) and c:IsType(TYPE_LINK) and not c:IsCode(4729591) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断发动效果时是否满足条件：场上存在空位且墓地存在符合条件的怪兽
function c4729591.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在空位
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查墓地是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c4729591.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤1只来自墓地的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 执行效果处理：选择并特殊召唤符合条件的墓地怪兽
function c4729591.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地中选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c4729591.spfilter1),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检查发动效果时是否满足条件：非互相连接状态的这张卡且可以解放
function c4729591.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetMutualLinkedGroupCount()==0 and e:GetHandler():IsReleasable() end
	-- 以支付代价的方式解放自身
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤满足「机块」属性、等级不超过4、可特殊召唤的墓地怪兽
function c4729591.spfilter2(c,e,tp)
	return c:IsSetCard(0x14b) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断发动效果时是否满足条件：场上存在空位且墓地存在符合条件的怪兽
function c4729591.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在空位
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查墓地是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c4729591.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤1只来自墓地的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 执行效果处理：选择并特殊召唤符合条件的墓地怪兽
function c4729591.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地中选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c4729591.spfilter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
