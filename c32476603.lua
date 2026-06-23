--シルバーヴァレット・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，把对方的额外卡组确认，那之内的1张除外。
-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「银色弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
function c32476603.initial_effect(c)
	-- ①：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，把对方的额外卡组确认，那之内的1张除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32476603,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,32476603)
	e1:SetCondition(c32476603.descon)
	e1:SetTarget(c32476603.destg)
	e1:SetOperation(c32476603.desop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「银色弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c32476603.regop)
	c:RegisterEffect(e2)
end
-- 判断连锁效果是否针对此卡且为连接怪兽效果
function c32476603.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取连锁效果的对象卡组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsContains(c) then return false end
	return re:IsActiveType(TYPE_LINK)
end
-- 设置效果发动时的处理信息，包括破坏和除外
function c32476603.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取对方额外卡组中可除外的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil)
	if chk==0 then return c:IsDestructable() and g:GetCount()>0 end
	-- 设置将此卡破坏的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	-- 设置将对方额外卡组1张卡除外的处理信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行效果处理，包括破坏自身、确认对方额外卡组并除外1张卡
function c32476603.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方额外卡组的所有卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	-- 判断此卡是否参与了效果处理且成功破坏
	if e:GetHandler():IsRelateToEffect(e) and Duel.Destroy(e:GetHandler(),REASON_EFFECT)>0 and g:GetCount()>0 then
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 向玩家确认对方额外卡组的卡
		Duel.ConfirmCards(tp,g)
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local tg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
		if tg:GetCount()>0 then
			-- 将选择的卡除外
			Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
		end
		-- 洗切对方额外卡组
		Duel.ShuffleExtra(1-tp)
	end
end
-- 在墓地时触发的效果，用于在结束阶段特殊召唤「弹丸」怪兽
function c32476603.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD) then
		-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「银色弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(32476603,1))
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1,32476604)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c32476603.sptg)
		e1:SetOperation(c32476603.spop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤函数，用于筛选「弹丸」怪兽且不是银色弹丸龙
function c32476603.spfilter(c,e,tp)
	return c:IsSetCard(0x102) and not c:IsCode(32476603) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤的处理信息
function c32476603.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在符合条件的「弹丸」怪兽
		and Duel.IsExistingMatchingCard(c32476603.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置将1只「弹丸」怪兽特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤处理，从卡组选择并特殊召唤符合条件的怪兽
function c32476603.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择符合条件的「弹丸」怪兽
	local g=Duel.SelectMatchingCard(tp,c32476603.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
