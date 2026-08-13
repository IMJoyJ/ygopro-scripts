--計量機塊カッパスケール
-- 效果：
-- 「机块」怪兽1只
-- 这个卡名的①②的效果1回合各能使用1次。这张卡在连接召唤的回合不能作为连接素材。
-- ①：把互相连接状态的这张卡解放才能发动。从自己墓地选「计量机块 电子秤河童」以外的1只「机块」连接怪兽特殊召唤。
-- ②：把不在互相连接状态的这张卡解放才能发动。从自己墓地选1只4星以下的「机块」怪兽特殊召唤。
function c4729591.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：用1只「机块」怪兽作为连接素材（代码中用IsLinkSetCard限定为「机块」连接怪兽）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x14b),1,1)
	-- 这张卡在连接召唤的回合不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(c4729591.lmlimit)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把互相连接状态的这张卡解放才能发动。从自己墓地选「计量机块 电子秤河童」以外的1只「机块」连接怪兽特殊召唤。
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
	-- 这个卡名的①②的效果1回合各能使用1次。②：把不在互相连接状态的这张卡解放才能发动。从自己墓地选1只4星以下的「机块」怪兽特殊召唤。
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
-- 作为不能成为连接素材的限制条件：当这张卡在本回合通过连接召唤上场时返回真。
function c4729591.lmlimit(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- ①效果的代价：发动时确认此卡处于互相连接状态且可以解放；实际发动时将此卡解放作为代价。
function c4729591.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetMutualLinkedGroupCount()>0 and e:GetHandler():IsReleasable() end
	-- 将这张卡解放，作为①效果发动的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 墓地中满足条件的选卡过滤器：字段为「机块」、连接怪兽、卡名不是「计量机块 电子秤河童」、且可以被特殊召唤。
function c4729591.spfilter1(c,e,tp)
	return c:IsSetCard(0x14b) and c:IsType(TYPE_LINK) and not c:IsCode(4729591) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标条件：自己有可用的怪兽区，且墓地存在至少1只满足条件的「机块」连接怪兽（不取对象，处理时选择）。
function c4729591.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己场上存在可用的怪兽区空格。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 并确认墓地存在至少1只满足条件的「机块」连接怪兽（非本卡名且可特殊召唤）。
		and Duel.IsExistingMatchingCard(c4729591.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置本次连锁的操作信息：效果类别为特殊召唤，预定从墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ①效果处理：若仍有可用怪兽区，从墓地选择1只满足条件的「机块」连接怪兽（非本卡名）以表侧表示特殊召唤到自己场上。
function c4729591.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上仍有可用的怪兽区，否则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只不受王家长眠之谷影响且满足spfilter1条件的「机块」连接怪兽（非本卡名）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c4729591.spfilter1),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的代价：发动时确认此卡没有处于互相连接状态且可以解放；实际发动时将此卡解放作为代价。
function c4729591.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetMutualLinkedGroupCount()==0 and e:GetHandler():IsReleasable() end
	-- 将这张卡解放，作为②效果发动的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 墓地中满足条件的选卡过滤器：字段为「机块」、等级4以下、且可以被特殊召唤。
function c4729591.spfilter2(c,e,tp)
	return c:IsSetCard(0x14b) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标条件：自己有可用的怪兽区，且墓地存在至少1只满足条件的4星以下「机块」怪兽（不取对象，处理时选择）。
function c4729591.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己场上存在可用的怪兽区空格。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 并确认墓地存在至少1只满足条件的4星以下「机块」怪兽。
		and Duel.IsExistingMatchingCard(c4729591.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置本次连锁的操作信息：效果类别为特殊召唤，预定从墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果处理：若仍有可用怪兽区，从墓地选择1只满足条件的4星以下「机块」怪兽以表侧表示特殊召唤到自己场上。
function c4729591.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上仍有可用的怪兽区，否则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只不受王家长眠之谷影响且满足spfilter2条件的4星以下「机块」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c4729591.spfilter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
