--超越竜ドリルグナトゥス
-- 效果：
-- 6星怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除，以除外的1只自己的恐龙族怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：没有超量素材的这张卡用和怪兽的战斗给与对方的战斗伤害变成2倍。
-- ③：这张卡被破坏的场合才能发动。从自己墓地选1只通常怪兽回到卡组。那之后，可以把这张卡特殊召唤。
function c30128445.initial_effect(c)
	-- 为卡片添加等级为6、需要2只怪兽进行XYZ召唤的手续
	aux.AddXyzProcedure(c,nil,6,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除，以除外的1只自己的恐龙族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30128445,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,30128445)
	e1:SetCost(c30128445.spcost)
	e1:SetTarget(c30128445.sptg)
	e1:SetOperation(c30128445.spop)
	c:RegisterEffect(e1)
	-- ②：没有超量素材的这张卡用和怪兽的战斗给与对方的战斗伤害变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_INVOLVING_BATTLE_DAMAGE)
	e2:SetCondition(c30128445.damcon)
	-- 将此卡在战斗阶段受到的战斗伤害变为2倍
	e2:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e2)
	-- ③：这张卡被破坏的场合才能发动。从自己墓地选1只通常怪兽回到卡组。那之后，可以把这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(30128445,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,30128446)
	e3:SetTarget(c30128445.tdtg)
	e3:SetOperation(c30128445.tdop)
	c:RegisterEffect(e3)
end
-- 支付1个超量素材作为费用
function c30128445.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤满足条件的恐龙族怪兽（可特殊召唤）
function c30128445.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标为除外区的恐龙族怪兽
function c30128445.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c30128445.spfilter(chkc,e,tp) end
	-- 判断场上是否有特殊召唤怪兽的空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断除外区是否有满足条件的恐龙族怪兽
		and Duel.IsExistingTarget(c30128445.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c30128445.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c30128445.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断此卡是否参与战斗且无超量素材
function c30128445.damcon(e)
	local c=e:GetHandler()
	return c:GetBattleTarget()~=nil and c:GetOverlayCount()==0
end
-- 过滤满足条件的通常怪兽（可送回卡组）
function c30128445.tdfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToDeck()
end
-- 设置效果目标为墓地的通常怪兽
function c30128445.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断墓地是否有满足条件的通常怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c30128445.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置效果处理信息为送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	if e:GetActivateLocation()==LOCATION_GRAVE then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	else
		e:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	end
end
-- 执行效果处理：选择墓地怪兽送回卡组并可特殊召唤
function c30128445.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择目标怪兽送回卡组
	local g=Duel.SelectMatchingCard(tp,c30128445.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		local c=e:GetHandler()
		-- 将目标怪兽送回卡组
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
			and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)>0
			-- 判断此卡是否仍在场上且有特殊召唤空间
			and c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 询问玩家是否特殊召唤此卡
			and Duel.SelectYesNo(tp,aux.Stringid(30128445,2)) then  --"是否把这张卡特殊召唤？"
			-- 中断当前连锁处理
			Duel.BreakEffect()
			-- 将此卡特殊召唤到场上
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
