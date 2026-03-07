--夢魔鏡の夢物語
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「梦魔镜」怪兽存在的场合，以除外的自己的「圣光之梦魔镜」「黯黑之梦魔镜」各1张为对象才能发动。那些卡回到卡组，选场上1张卡除外。
-- ②：自己场上的「梦魔镜」卡被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c37444964.initial_effect(c)
	-- 记录此卡与「圣光之梦魔镜」和「黯黑之梦魔镜」的关联
	aux.AddCodeList(c,74665651,1050355)
	-- ①：自己场上有「梦魔镜」怪兽存在的场合，以除外的自己的「圣光之梦魔镜」「黯黑之梦魔镜」各1张为对象才能发动。那些卡回到卡组，选场上1张卡除外。
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
-- 过滤函数，用于判断场上是否存在「梦魔镜」怪兽
function c37444964.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x131)
end
-- 效果发动条件判断，检查自己场上是否存在「梦魔镜」怪兽
function c37444964.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只「梦魔镜」怪兽
	return Duel.IsExistingMatchingCard(c37444964.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于判断除外区是否存在「圣光之梦魔魔镜」
function c37444964.filter1(c)
	return c:IsFaceup() and c:IsCode(74665651) and c:IsAbleToDeck()
end
-- 过滤函数，用于判断除外区是否存在「黯黑之梦魔镜」
function c37444964.filter2(c)
	return c:IsFaceup() and c:IsCode(1050355) and c:IsAbleToDeck()
end
-- 效果发动时的处理，检查是否满足发动条件
function c37444964.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己除外区是否存在至少1张「圣光之梦魔镜」
	if chk==0 then return Duel.IsExistingTarget(c37444964.filter1,tp,LOCATION_REMOVED,0,1,nil)
		-- 检查自己除外区是否存在至少1张「黯黑之梦魔镜」
		and Duel.IsExistingTarget(c37444964.filter2,tp,LOCATION_REMOVED,0,1,nil)
		-- 检查自己场上是否存在至少1张可除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择1张「圣光之梦魔镜」作为效果对象
	local g1=Duel.SelectTarget(tp,c37444964.filter1,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择1张「黯黑之梦魔镜」作为效果对象
	local g2=Duel.SelectTarget(tp,c37444964.filter2,tp,LOCATION_REMOVED,0,1,1,nil)
	g1:Merge(g2)
	-- 获取场上所有可除外的卡
	local g3=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置效果处理信息，指定将2张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,2,0,0)
	-- 设置效果处理信息，指定将1张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g3,1,0,0)
end
-- 效果处理函数，执行将对象卡送回卡组并除外场上卡的操作
function c37444964.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的对象卡组，并筛选出与效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将对象卡送回卡组，若成功则继续处理
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择1张场上卡作为除外对象
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThisCard(e))
		if sg:GetCount()>0 then
			-- 显示所选卡作为对象的动画效果
			Duel.HintSelection(sg)
			-- 将选中的卡除外
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 过滤函数，用于判断是否为「梦魔镜」怪兽且因战斗或效果破坏
function c37444964.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x131)
		and c:IsOnField() and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的处理函数，判断是否可以发动此效果
function c37444964.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c37444964.repfilter,1,nil,tp) end
	-- 询问玩家是否发动此效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 返回代替破坏效果的判断结果
function c37444964.repval(e,c)
	return c37444964.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的处理函数，将此卡除外
function c37444964.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
