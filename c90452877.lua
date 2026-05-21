--Kozmo－エナジーアーツ
-- 效果：
-- 「星际仙踪-能术」在1回合只能发动1张。
-- ①：以自己场上1只「星际仙踪」怪兽为对象才能发动。那只怪兽破坏，选对方的场上·墓地1张卡除外。
function c90452877.initial_effect(c)
	-- 「星际仙踪-能术」在1回合只能发动1张。①：以自己场上1只「星际仙踪」怪兽为对象才能发动。那只怪兽破坏，选对方的场上·墓地1张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,90452877+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c90452877.destg)
	e1:SetOperation(c90452877.desop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「星际仙踪」怪兽
function c90452877.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd2)
end
-- 效果的发动准备与合法性检测
function c90452877.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c90452877.desfilter(chkc) end
	-- 检查自己场上是否存在满足条件的「星际仙踪」怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c90452877.desfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上或墓地是否存在可以除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只表侧表示的「星际仙踪」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c90452877.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：除外对方场上或墓地的1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 效果处理：破坏作为对象的怪兽，并除外对方场上或墓地的1张卡
function c90452877.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍适用此效果，则将其破坏，且必须破坏成功才进行后续处理
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 由发动效果的玩家从对方场上或墓地选择1张可以除外的卡（优先从场上选择）
		local g=aux.SelectCardFromFieldFirst(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
		if #g>0 then
			-- 将选中的卡表侧表示除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
