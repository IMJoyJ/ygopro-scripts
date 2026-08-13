--救護部隊
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己墓地1只通常怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：这张卡在墓地存在，通常怪兽被战斗破坏时才能发动。这张卡变成通常怪兽（战士族·地·3星·攻1200/守400）在怪兽区域守备表示特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c33622465.initial_effect(c)
	-- ①：以自己墓地1只通常怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c33622465.target)
	e1:SetOperation(c33622465.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在，通常怪兽被战斗破坏时才能发动。这张卡变成通常怪兽（战士族·地·3星·攻1200/守400）在怪兽区域守备表示特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33622465,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,33622465)
	e2:SetCondition(c33622465.spcon)
	e2:SetTarget(c33622465.sptg)
	e2:SetOperation(c33622465.spop)
	c:RegisterEffect(e2)
end
-- 筛选条件：卡必须是通常怪兽，并且可以被加入手卡。
function c33622465.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end
-- 发动时的目标选择处理：检查墓地是否存在符合条件的通常怪兽；若存在，则提示玩家选择1只，将其设为对象，并登记“加入手卡”的操作信息。
function c33622465.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c33622465.filter(chkc) end
	-- 发动合法性的第0次检查：确认自己墓地存在至少1只符合筛选条件且能成为对象的通常怪兽。
	if chk==0 then return Duel.IsExistingTarget(c33622465.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只符合条件的通常怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c33622465.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记操作信息：本连锁要将选中的1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理时，取得发动时选择的对象卡；若对象仍与该效果关联，则将其加入持有者的手卡。
function c33622465.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的那张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡送去其持有者的手卡，原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 筛选条件：被战斗破坏的怪兽在场上时的类型包含通常怪兽（使用离场前的类型判断）。
function c33622465.cfilter(c)
	return bit.band(c:GetPreviousTypeOnField(),TYPE_NORMAL)~=0
end
-- 诱发条件：本次被战斗破坏送去墓地的怪兽群中存在至少1只离场前是通常怪兽的怪兽。
function c33622465.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c33622465.cfilter,1,nil)
end
-- 发动合法性与目标设定：检查自己主要怪兽区域是否有空位，且自己能否把这张卡作为通常怪兽特殊召唤；满足则登记特殊召唤操作信息。
function c33622465.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己能否将这张陷阱卡以战士族·地·3星·攻1200/守400的通常怪兽形式特殊召唤到场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,33622465,0,TYPES_NORMAL_TRAP_MONSTER,1200,400,3,RACE_WARRIOR,ATTRIBUTE_EARTH) end
	-- 登记操作信息：本连锁要将这张卡自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理时：若场上仍有空位、这张卡仍在墓地且能够特殊召唤，则把它变成通常怪兽，以表侧守备表示特殊召唤，并赋予其“离场时除外”的效果，最后完成特殊召唤。
function c33622465.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主要怪兽区域有空格；若无空格则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 确认这张卡仍与本效果关联，且玩家依然能够将其作为通常怪兽特殊召唤。
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,33622465,0,TYPES_NORMAL_TRAP_MONSTER,1200,400,3,RACE_WARRIOR,ATTRIBUTE_EARTH) then
		c:AddMonsterAttribute(TYPE_NORMAL)
		-- 将这张卡以表侧守备表示特殊召唤到自己的主要怪兽区域（不检查召唤条件、不进行苏生限制）。
		Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP_DEFENSE)
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2,true)
		-- 完成整个特殊召唤流程（与SpecialSummonStep配套，必须调用以结算特殊召唤）。
		Duel.SpecialSummonComplete()
	end
end
