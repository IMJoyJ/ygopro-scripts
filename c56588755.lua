--ドラグマ・ジェネシス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以1只自己或者对方的除外状态的融合·同调·超量·连接怪兽和与那只怪兽相同种类（融合·同调·超量·连接）的对方场上1只效果怪兽为对象才能发动。那只除外状态的怪兽回到额外卡组，那只对方场上的怪兽的效果无效。
function c56588755.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以1只自己或者对方的除外状态的融合·同调·超量·连接怪兽和与那只怪兽相同种类（融合·同调·超量·连接）的对方场上1只效果怪兽为对象才能发动。那只除外状态的怪兽回到额外卡组，那只对方场上的怪兽的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,56588755+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c56588755.target)
	e1:SetOperation(c56588755.activate)
	c:RegisterEffect(e1)
end
-- 筛选除外状态的融合、同调、超量、连接怪兽，且对方场上存在与之相同种类的效果怪兽
function c56588755.filter(c,tp)
	local ctype=bit.band(c:GetType(),TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
	return c:IsFaceup() and ctype~=0 and c:IsAbleToExtra()
		-- 检查对方场上是否存在与该除外怪兽相同种类且未被无效的效果怪兽
		and Duel.IsExistingTarget(c56588755.filter2,tp,0,LOCATION_MZONE,1,nil,ctype)
end
-- 筛选对方场上与除外怪兽相同种类且未被无效的效果怪兽
function c56588755.filter2(c,ctype)
	-- 检查卡片是否属于指定的怪兽种类（融合/同调/超量/连接）且是未被无效的效果怪兽
	return c:IsType(ctype) and aux.NegateEffectMonsterFilter(c)
end
-- 效果发动时的对象选择与操作准备阶段
function c56588755.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查除外区是否存在符合条件的融合、同调、超量、连接怪兽作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c56588755.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,tp) end
	-- 提示玩家选择要返回额外卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择1只自己或对方除外状态的融合、同调、超量、连接怪兽作为对象
	local g=Duel.SelectTarget(tp,c56588755.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,tp)
	local ctype=bit.band(g:GetFirst():GetType(),TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
	-- 提示玩家选择要无效效果的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1只与上述怪兽相同种类的效果怪兽作为对象
	local dg=Duel.SelectTarget(tp,c56588755.filter2,tp,0,LOCATION_MZONE,1,1,nil,ctype)
	e:SetLabelObject(g:GetFirst())
	-- 设置连锁信息，表示该效果包含将1张卡送回额外卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
	-- 设置连锁信息，表示该效果包含使1张卡的效果无效的操作
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,dg,1,0,0)
end
-- 效果处理阶段，将除外怪兽送回额外卡组，并无效对方场上怪兽的效果
function c56588755.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为对象的所有卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	local tc1=e:GetLabelObject()
	local tc2=g:GetFirst()
	if tc1==tc2 then tc2=g:GetNext() end
	-- 检查除外的对象怪兽是否仍适用效果，并将其送回额外卡组，确认成功回到额外卡组
	if tc1:IsRelateToEffect(e) and Duel.SendtoDeck(tc1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc1:IsLocation(LOCATION_EXTRA) then
		if tc2:IsRelateToEffect(e) and tc2:IsFaceup() and tc2:IsControler(1-tp) and not tc2:IsDisabled() then
			-- 那只对方场上的怪兽的效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc2:RegisterEffect(e1)
			-- 那只对方场上的怪兽的效果无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc2:RegisterEffect(e2)
		end
	end
end
