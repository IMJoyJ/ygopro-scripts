--ヴァレルエンド・ドラゴン
-- 效果：
-- 效果怪兽3只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：场上的这张卡不会被战斗·效果破坏，双方不能把这张卡作为怪兽的效果的对象。
-- ②：这张卡可以向对方怪兽全部各作1次攻击。
-- ③：自己·对方回合，以场上1只效果怪兽和自己墓地1只「弹丸」怪兽为对象才能发动（对方不能对应这个发动把卡的效果发动）。那只场上的怪兽的效果无效，那只墓地的怪兽特殊召唤。
function c98630720.initial_effect(c)
	-- 设置连接召唤手续：需要效果怪兽3只以上作为素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),3)
	c:EnableReviveLimit()
	-- ①：场上的这张卡不会被战斗·效果破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	-- 双方不能把这张卡作为怪兽的效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c98630720.efilter)
	c:RegisterEffect(e3)
	-- ②：这张卡可以向对方怪兽全部各作1次攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_ATTACK_ALL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- ③：自己·对方回合，以场上1只效果怪兽和自己墓地1只「弹丸」怪兽为对象才能发动（对方不能对应这个发动把卡的效果发动）。那只场上的怪兽的效果无效，那只墓地的怪兽特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(98630720,0))
	e5:SetCategory(CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,98630720)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e5:SetTarget(c98630720.distg)
	e5:SetOperation(c98630720.disop)
	c:RegisterEffect(e5)
end
-- 判定效果指向来源是否为怪兽卡，用于怪兽效果的对象抗性过滤。
function c98630720.efilter(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 过滤自己墓地中可以特殊召唤的「弹丸」怪兽。
function c98630720.spfilter(c,e,tp)
	return c:IsSetCard(0x102) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动判定与对象选择。
function c98630720.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判定自己场上是否有空余的怪兽区域用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定场上是否存在可以被无效效果的效果怪兽。
		and Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 判定自己墓地是否存在可以特殊召唤的「弹丸」怪兽。
		and Duel.IsExistingTarget(c98630720.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要无效的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择场上1只表侧表示的效果怪兽作为效果无效的对象。
	local g1=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「弹丸」怪兽作为特殊召唤的对象。
	local g2=Duel.SelectTarget(tp,c98630720.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表示该效果包含使怪兽效果无效的操作。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g1,1,0,0)
	-- 设置连锁信息，表示该效果包含特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
	-- 设定连锁限制，使对方不能对应此效果的发动来发动卡的效果。
	Duel.SetChainLimit(c98630720.chlimit)
end
-- 连锁限制条件：只有发动该效果的玩家自己可以进行连锁（即对方不能连锁）。
function c98630720.chlimit(e,ep,tp)
	return tp==ep
end
-- 效果③的无效与特殊召唤效果处理。
function c98630720.disop(e,tp,eg,ep,ev,re,r,rp)
	local hc=e:GetLabelObject()
	-- 获取当前连锁中被选择为对象的所有卡片。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==hc then tc=g:GetNext() end
	if hc:IsRelateToEffect(e) and hc:IsCanBeDisabledByEffect(e) then
		-- 使与目标怪兽相关的连锁中已发动的效果无效化。
		Duel.NegateRelatedChain(hc,RESET_TURN_SET)
		local c=e:GetHandler()
		-- 那只场上的怪兽的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		hc:RegisterEffect(e1)
		-- 那只场上的怪兽的效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		hc:RegisterEffect(e2)
		if tc:IsRelateToEffect(e) then
			-- 将作为对象的墓地中的「弹丸」怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
