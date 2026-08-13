--超越竜ドリルグナトゥス
-- 效果：
-- 6星怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除，以除外的1只自己的恐龙族怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：没有超量素材的这张卡用和怪兽的战斗给与对方的战斗伤害变成2倍。
-- ③：这张卡被破坏的场合才能发动。从自己墓地选1只通常怪兽回到卡组。那之后，可以把这张卡特殊召唤。
function c30128445.initial_effect(c)
	-- 为这张卡添加超量召唤手续：使用2只6星怪兽叠放（对应“6星怪兽×2”的召唤条件）。
	aux.AddXyzProcedure(c,nil,6,2)
	c:EnableReviveLimit()
	-- 这个卡名的①③的效果1回合各能使用1次。①：把这张卡1个超量素材取除，以除外的1只自己的恐龙族怪兽为对象才能发动。那只怪兽特殊召唤。
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
	-- 将②效果造成的战斗伤害变更设为：对对方玩家造成的战斗伤害变为2倍。
	e2:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e2)
	-- 这个卡名的①③的效果1回合各能使用1次。③：这张卡被破坏的场合才能发动。从自己墓地选1只通常怪兽回到卡组。那之后，可以把这张卡特殊召唤。
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
-- ①效果的发动代价：这张卡有超量素材时才能支付，把这张卡的1个超量素材取除。
function c30128445.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 匹配除外区的对象怪兽：须为表侧表示、恐龙族，且能够被当前效果特殊召唤。
function c30128445.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标选择函数。先验证连锁处理中指定的对象是否合法，再在发动时检查自己场上是否有可用怪兽区、除外区是否存在符合条件的恐龙族对象。
function c30128445.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c30128445.spfilter(chkc,e,tp) end
	-- 发动条件检查：自己场上是否有空闲的主要怪兽区，用于特殊召唤对象怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：除外区是否有1只满足过滤条件的恐龙族怪兽能够成为此效果的对象。
		and Duel.IsExistingTarget(c30128445.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 在选择特殊召唤对象前，向操作者显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从除外区选择1只符合条件的恐龙族怪兽作为效果对象，并自动将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c30128445.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息：本效果处理时将进行1次特殊召唤，对象为已选中的那张卡，供其他卡/效果参考。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理时：取得对象卡，若对象仍与此效果关联，则将其表侧表示特殊召唤。
function c30128445.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的第1个对象卡（即除外区选中的恐龙族怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上（保持常规召唤条件/苏生限制检查）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的适用条件：这张卡正在与怪兽进行战斗，且没有超量素材时，战斗伤害加倍效果适用。
function c30128445.damcon(e)
	local c=e:GetHandler()
	return c:GetBattleTarget()~=nil and c:GetOverlayCount()==0
end
-- ③效果中“从自己墓地选1只通常怪兽”的过滤条件：是通常怪兽且能够返回卡组。
function c30128445.tdfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToDeck()
end
-- ③效果的发动条件与目标设定。先检查墓地是否有符合条件的通常怪兽，再设置回卡组的操作信息，并根据效果发动时这张卡是否在墓地为特殊召唤部分追加相应的分类标记。
function c30128445.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己墓地是否存在至少1只满足条件的通常怪兽（回卡组是必须动作，因此只看这个）。
	if chk==0 then return Duel.IsExistingMatchingCard(c30128445.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：本效果处理时将把1张卡从墓地返回卡组（不取对象，效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	if e:GetActivateLocation()==LOCATION_GRAVE then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	else
		e:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	end
end
-- ③效果处理时：从墓地选1只通常怪兽返回卡组并洗牌；确认返回成功且该卡确实在卡组中后，若这张卡仍关联、场上有空位且玩家选择特殊召唤，则把这张卡特殊召唤。
function c30128445.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 在选择返回卡组的卡片前，向操作者显示“请选择要返回卡组的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择1张符合条件的通常怪兽返回卡组（效果处理时选择，不取对象）。
	local g=Duel.SelectMatchingCard(tp,c30128445.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		local c=e:GetHandler()
		-- 将选中的通常怪兽返回持有者卡组并洗牌；用返回值大于0确认至少1张卡实际被送回卡组。
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
			and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)>0
			-- 判断后续特殊召唤是否可行：这张卡仍与效果关联（未被中断），且自己场上仍有空余的怪兽区。
			and c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 询问操作者是否把这张卡特殊召唤；若选择“是”，才执行后续的特殊召唤处理。
			and Duel.SelectYesNo(tp,aux.Stringid(30128445,2)) then  --"是否把这张卡特殊召唤？"
			-- 中断当前效果处理，使接下来的特殊召唤作为独立处理，以确保时点和关联状态正确。
			Duel.BreakEffect()
			-- 把这张卡以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
