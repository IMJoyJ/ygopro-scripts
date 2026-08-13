--夢魔鏡の夢物語
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「梦魔镜」怪兽存在的场合，以除外的自己的「圣光之梦魔镜」「黯黑之梦魔镜」各1张为对象才能发动。那些卡回到卡组，选场上1张卡除外。
-- ②：自己场上的「梦魔镜」卡被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c37444964.initial_effect(c)
	-- 将74665651（圣光之梦魔镜）和1050355（黯黑之梦魔镜）登记为本卡记载的卡名，用于规则上涉及这些卡名的判断或检索。
	aux.AddCodeList(c,74665651,1050355)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「梦魔镜」怪兽存在的场合，以除外的自己的「圣光之梦魔镜」「黯黑之梦魔镜」各1张为对象才能发动。那些卡回到卡组，选场上1张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,37444964+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c37444964.condition)
	e1:SetTarget(c37444964.target)
	e1:SetOperation(c37444964.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的「梦魔镜」卡被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c37444964.reptg)
	e2:SetValue(c37444964.repval)
	e2:SetOperation(c37444964.repop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断怪兽是否表侧表示且属于「梦魔镜」字段，用于检查场上是否存在「梦魔镜」怪兽。
function c37444964.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x131)
end
-- 发动条件函数：检查自己场上是否存在至少1只表侧表示的「梦魔镜」怪兽，满足①的发动前提。
function c37444964.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 以自己场上（LOCATION_MZONE）为范围，检索是否存在至少1只满足cfilter的「梦魔镜」怪兽。
	return Duel.IsExistingMatchingCard(c37444964.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 筛选「圣光之梦魔镜」：必须是表侧表示、卡号为74665651且能够返回卡组。
function c37444964.filter1(c)
	return c:IsFaceup() and c:IsCode(74665651) and c:IsAbleToDeck()
end
-- 筛选「黯黑之梦魔镜」：必须是表侧表示、卡号为1050355且能够返回卡组。
function c37444964.filter2(c)
	return c:IsFaceup() and c:IsCode(1050355) and c:IsAbleToDeck()
end
-- 效果目标指定与发动合法性检查：不接受外部指定的对象；发动时需确认除外区存在「圣光之梦魔镜」「黯黑之梦魔镜」各1张，且场上有可除外的卡。
function c37444964.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己除外区是否存在至少1张符合条件的「圣光之梦魔镜」作为对象。
	if chk==0 then return Duel.IsExistingTarget(c37444964.filter1,tp,LOCATION_REMOVED,0,1,nil)
		-- 检查自己除外区是否存在至少1张符合条件的「黯黑之梦魔镜」作为对象。
		and Duel.IsExistingTarget(c37444964.filter2,tp,LOCATION_REMOVED,0,1,nil)
		-- 检查场上（双方）是否存在至少1张可除外的卡（除本卡外），用于后续‘选场上1张卡除外’。
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 给玩家显示选择提示：请选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己除外区选择1张「圣光之梦魔镜」作为对象并加入连锁对象。
	local g1=Duel.SelectTarget(tp,c37444964.filter1,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 再次给玩家显示选择提示：请选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己除外区选择1张「黯黑之梦魔镜」作为对象并加入连锁对象。
	local g2=Duel.SelectTarget(tp,c37444964.filter2,tp,LOCATION_REMOVED,0,1,1,nil)
	g1:Merge(g2)
	-- 获取当前场上（双方）除本卡外所有可以除外的卡，作为除外选择的候选组。
	local g3=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 登记操作信息：将g1中的2张卡返回卡组（CATEGORY_TODECK）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,2,0,0)
	-- 登记操作信息：将从场上选择1张卡除外（CATEGORY_REMOVE），候选组为g3。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g3,1,0,0)
end
-- 效果处理函数：先将对象卡返回卡组洗牌，若成功返回则继续选择并除外场上1张卡。
function c37444964.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁信息中取出发动时选择的对象卡，并筛选出仍与效果保持联系的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将筛选后的对象卡返回持有者卡组并洗牌；若实际返回数量不为0，则继续处理除外。
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 给玩家显示选择提示：请选择要除外的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从双方场上选择1张可以除外的卡（自动排除本效果卡片自身，即aux.ExceptThisCard(e)）。
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThisCard(e))
		if sg:GetCount()>0 then
			-- 为选中的除外卡显示选择为对象的动画，并记录其成为对象。
			Duel.HintSelection(sg)
			-- 将选中的卡以表侧表示除外，完成除外处理。
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 代替破坏判定条件：被破坏的卡需为表侧表示、属于「梦魔镜」字段、在自己场上、因战斗或效果被破坏，且不是由其他代替破坏效果引起。
function c37444964.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x131)
		and c:IsOnField() and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏触发判定：本卡在墓地且可除外，并且有满足条件的「梦魔镜」卡将被破坏；同时询问玩家是否发动此代替效果。
function c37444964.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c37444964.repfilter,1,nil,tp) end
	-- 弹出是否使用墓地此卡代替破坏的确认选择，返回玩家是否同意。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏的替换值函数：将正在被破坏的卡c与控制者玩家传入repfilter，判断该卡是否符合代替条件。
function c37444964.repval(e,c)
	return c37444964.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的操作：将墓地的这张卡除外，作为被破坏卡的代替。
function c37444964.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将效果持有者（即墓地的这张卡）表侧表示除外，完成代替破坏的除外处理。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
