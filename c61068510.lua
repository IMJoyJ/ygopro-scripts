--トルネード
-- 效果：
-- 对方的魔法与陷阱卡区域卡有3张以上存在时才能发动。对方的魔法与陷阱卡区域存在的1张卡破坏。
function c61068510.initial_effect(c)
	-- 对方的魔法与陷阱卡区域卡有3张以上存在时才能发动。对方的魔法与陷阱卡区域存在的1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c61068510.condition)
	e1:SetTarget(c61068510.target)
	e1:SetOperation(c61068510.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否位于魔法与陷阱区域（不含场地魔法格和灵摆区域）
function c61068510.cfilter(c)
	return c:GetSequence()<5
end
-- 发动条件：对方的魔法与陷阱卡区域卡有3张以上存在
function c61068510.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方的魔法与陷阱区域是否存在至少3张卡（不含场地和灵摆）
	return Duel.IsExistingMatchingCard(c61068510.cfilter,tp,0,LOCATION_SZONE,3,nil)
end
-- 过滤函数：检查卡片是否位于魔法与陷阱区域（不含场地魔法格和灵摆区域）
function c61068510.filter(c)
	return c:GetSequence()<5
end
-- 效果发动时的目标选择与处理
function c61068510.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and c61068510.filter(chkc) end
	-- 在发动时，检查对方的魔法与陷阱区域是否存在至少1张可以作为对象且符合过滤条件的卡
	if chk==0 then return Duel.IsExistingTarget(c61068510.filter,tp,0,LOCATION_SZONE,1,nil) end
	-- 给玩家发送提示信息：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方魔法与陷阱区域的1张卡作为效果对象
	local g=Duel.SelectTarget(tp,c61068510.filter,tp,0,LOCATION_SZONE,1,1,nil)
	-- 设置操作信息：在连锁处理时将破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理的执行函数
function c61068510.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 因效果破坏目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
