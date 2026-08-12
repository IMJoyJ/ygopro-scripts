--イビリチュア・ネーレイマナス
-- 效果：
-- 「遗式」仪式魔法卡降临。
-- ①：这张卡仪式召唤成功的场合，以自己墓地1只水属性怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡不会被和从额外卡组特殊召唤的怪兽的战斗破坏。
-- ③：1回合1次，对方把怪兽的效果发动时才能发动。选自己场上1只「遗式」仪式怪兽回到持有者手卡，那个发动无效并回到持有者卡组。
function c88926295.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤成功的场合，以自己墓地1只水属性怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88926295,0))  --"墓地怪兽特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c88926295.spcon)
	e1:SetTarget(c88926295.sptg)
	e1:SetOperation(c88926295.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡不会被和从额外卡组特殊召唤的怪兽的战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c88926295.indes)
	c:RegisterEffect(e2)
	-- ③：1回合1次，对方把怪兽的效果发动时才能发动。选自己场上1只「遗式」仪式怪兽回到持有者手卡，那个发动无效并回到持有者卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(88926295,1))  --"无效并回到卡组"
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_TOHAND+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCountLimit(1)
	e3:SetCondition(c88926295.negcon)
	e3:SetTarget(c88926295.negtg)
	e3:SetOperation(c88926295.negop)
	c:RegisterEffect(e3)
end
-- 判定此卡是否通过仪式召唤成功。
function c88926295.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤条件：自己墓地的水属性且可以特殊召唤的怪兽。
function c88926295.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与目标选择，检查墓地是否存在符合条件的水属性怪兽。
function c88926295.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c88926295.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只符合条件的水属性怪兽作为对象。
		and Duel.IsExistingTarget(c88926295.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的水属性怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c88926295.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理信息，表示该效果包含特殊召唤所选怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的实际处理：将选择的墓地怪兽特殊召唤。
function c88926295.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的作为效果对象的水属性怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判定与之战斗的怪兽是否是从额外卡组特殊召唤的怪兽。
function c88926295.indes(e,c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果③的发动条件：此卡未被战斗破坏，且对方发动了怪兽的效果，且该发动可以被无效。
function c88926295.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 判定发动效果的是对方玩家，且该发动可以被无效，且发动的效果属于怪兽效果。
		and rp==1-tp and Duel.IsChainNegatable(ev) and re:IsActiveType(TYPE_MONSTER)
end
-- 过滤条件：自己场上表侧表示的「遗式」仪式怪兽，且能送回手牌。
function c88926295.filter(c)
	return c:IsSetCard(0x3a) and c:IsType(TYPE_RITUAL) and c:IsAbleToHand() and c:IsFaceup()
end
-- 效果③的发动准备，检查对方发动的卡是否能回到卡组，以及自己场上是否存在可回手牌的「遗式」仪式怪兽。
function c88926295.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then return (not rc:IsRelateToEffect(re) or rc:IsAbleToDeck())
		-- 检查自己场上是否存在至少1只符合条件的「遗式」仪式怪兽。
		and Duel.IsExistingMatchingCard(c88926295.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置连锁处理信息，表示该效果包含将自己场上1张卡送回手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE)
	-- 设置连锁处理信息，表示该效果包含使对方怪兽效果的发动无效的操作。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if rc:IsRelateToEffect(re) then
		-- 设置连锁处理信息，表示该效果包含将对方发动的卡送回卡组的操作。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
	if re:GetActivateLocation()==LOCATION_GRAVE then
		e:SetCategory(e:GetCategory()|CATEGORY_GRAVE_ACTION)
	else
		e:SetCategory(e:GetCategory()&~CATEGORY_GRAVE_ACTION)
	end
end
-- 效果③的实际处理：选自己场上1只「遗式」仪式怪兽回到手牌，使对方的效果发动无效并回到卡组。
function c88926295.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择自己场上1只符合条件的「遗式」仪式怪兽。
	local tc=Duel.SelectMatchingCard(tp,c88926295.filter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	-- 如果成功将选中的怪兽送回手牌且其确实到达了手牌。
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND)
		-- 成功使该发动无效，且对方发动的卡在连锁处理时仍与该效果相关联。
		and Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将被无效发动的卡送回持有者卡组并洗牌。
		Duel.SendtoDeck(eg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
