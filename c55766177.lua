--弑逆の魔轟神
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只「魔轰神」怪兽和场上1张表侧表示卡为对象才能发动。选自己1张手卡丢弃，作为对象的墓地的怪兽特殊召唤，作为对象的场上的卡破坏。
function c55766177.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己墓地1只「魔轰神」怪兽和场上1张表侧表示卡为对象才能发动。选自己1张手卡丢弃，作为对象的墓地的怪兽特殊召唤，作为对象的场上的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,55766177+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c55766177.target)
	e1:SetOperation(c55766177.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地可以特殊召唤的「魔轰神」怪兽
function c55766177.spfilter(c,e,tp)
	return c:IsSetCard(0x35) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的对象选择与条件判断
function c55766177.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断场上是否存在除这张卡以外的表侧表示卡作为对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
		-- 判断自己墓地是否存在可以特殊召唤的「魔轰神」怪兽作为对象
		and Duel.IsExistingTarget(c55766177.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 判断自己手卡是否至少有1张，且自己场上是否有可用的怪兽区域
		and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「魔轰神」怪兽作为对象
	local g1=Duel.SelectTarget(tp,c55766177.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	e:SetLabelObject(g1:GetFirst())
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张表侧表示的卡作为对象
	local g2=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,1,0,0)
	-- 设置破坏的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,1,0,0)
	-- 设置丢弃手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果处理的执行逻辑
function c55766177.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	-- 获取当前连锁中被选择为对象的所有卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local lc=tg:GetFirst()
	if lc==tc then lc=tg:GetNext() end
	-- 选自己1张手卡丢弃，并判断作为对象的墓地怪兽是否仍存在且受此效果影响
	if Duel.DiscardHand(tp,nil,1,1,REASON_DISCARD+REASON_EFFECT,nil)>0 and tc:IsRelateToEffect(e) then
		-- 将作为对象的墓地怪兽特殊召唤，并判断作为对象的场上卡片是否仍存在且受此效果影响
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 and lc:IsRelateToEffect(e) then
			-- 将作为对象的场上的卡破坏
			Duel.Destroy(lc,REASON_EFFECT)
		end
	end
end
