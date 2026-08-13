--魔力誘爆
-- 效果：
-- 对方的魔法与陷阱卡区域表侧表示存在的魔法卡被送去墓地的场合才能发动。选择场上表侧表示存在的1只怪兽破坏。
function c22869904.initial_effect(c)
	-- 对方的魔法与陷阱卡区域表侧表示存在的魔法卡被送去墓地的场合才能发动。选择场上表侧表示存在的1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c22869904.condition)
	e1:SetTarget(c22869904.target)
	e1:SetOperation(c22869904.activate)
	c:RegisterEffect(e1)
end
-- 筛选被送去墓地的卡：必须是魔法卡，且之前位于对方的魔法与陷阱卡区域（不含场地魔法区域序号5），之前表侧表示，之前控制者为对方。
function c22869904.cfilter(c,tp)
	return c:IsType(TYPE_SPELL) and c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(1-tp) and c:GetPreviousSequence()~=5
end
-- 发动条件判定：本次送去墓地的卡组中是否存在至少1张满足上述筛选条件的卡。
function c22869904.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c22869904.cfilter,1,nil,tp)
end
-- 目标筛选函数：怪兽必须是表侧表示。
function c22869904.filter(c)
	return c:IsFaceup()
end
-- 效果发动时的目标选择处理：验证对象合法性，确认存在可选目标，提示玩家选择，选定1只场上表侧表示怪兽作为效果对象，并设置破坏该对象的操作信息。
function c22869904.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c22869904.filter(chkc) end
	-- 发动时点检查：场上是否存在至少1张表侧表示怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c22869904.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示“请选择要破坏的卡”的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让操作玩家从双方怪兽区域选择1张表侧表示怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c22869904.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息：该效果包含破坏分类，对象为已选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理时的操作：取得效果对象，若该怪兽仍表侧表示且与效果仍有关联，则将其破坏。
function c22869904.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时指定的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 以效果原因将对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
