--氷水浸蝕
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方场上1张表侧表示的卡为对象才能发动。自己场上1只「冰水」怪兽破坏，作为对象的卡的效果直到回合结束时无效。
-- ②：自己场上的表侧表示的水属性怪兽以破坏以外的方法因对方从场上离开的场合才能发动。从卡组选1只「冰水」怪兽加入手卡或特殊召唤。
function c53742162.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以对方场上1张表侧表示的卡为对象才能发动。自己场上1只「冰水」怪兽破坏，作为对象的卡的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53742162,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,53742162)
	e2:SetTarget(c53742162.distg)
	e2:SetOperation(c53742162.disop)
	c:RegisterEffect(e2)
	-- ②：自己场上的表侧表示的水属性怪兽以破坏以外的方法因对方从场上离开的场合才能发动。从卡组选1只「冰水」怪兽加入手卡或特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(53742162,1))  --"加入手卡或特殊召唤"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,53742163)
	e3:SetCondition(c53742162.thcon)
	e3:SetTarget(c53742162.thtg)
	e3:SetOperation(c53742162.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选自己场上的「冰水」怪兽（表侧表示）
function c53742162.disfilter(c)
	return c:IsSetCard(0x16c) and c:IsFaceup()
end
-- 效果处理时的取对象阶段，检查是否存在满足条件的对方场上表侧表示的卡作为对象
function c53742162.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查对方场上是否存在满足无效化条件的卡
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查自己场上是否存在「冰水」怪兽（表侧表示）
		and Duel.IsExistingMatchingCard(c53742162.disfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上一张表侧表示的卡作为对象
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 获取自己场上所有「冰水」怪兽（表侧表示）
	local dg=Duel.GetMatchingGroup(c53742162.disfilter,tp,LOCATION_MZONE,0,nil)
	-- 设置效果处理信息，将要破坏的「冰水」怪兽作为操作对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
	-- 设置效果处理信息，将要无效的卡作为操作对象
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果处理函数，执行①效果的处理流程
function c53742162.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要破坏的「冰水」怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只「冰水」怪兽进行破坏
	local g=Duel.SelectMatchingCard(tp,c53742162.disfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 若成功破坏了怪兽，则继续执行后续无效化处理
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT) then
		-- 获取当前连锁中被选择的对象卡
		local tc=Duel.GetFirstTarget()
		if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
			-- 使对象卡相关的连锁无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 使对象卡的效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 使对象卡的效果在回合结束时无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 若对象卡为陷阱怪兽，则使其陷阱怪兽效果无效
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
	end
end
-- 过滤函数，用于筛选因对方原因离开场上的水属性怪兽
function c53742162.filter(c,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and not c:IsReason(REASON_DESTROY) and c:GetReasonPlayer()==1-tp
end
-- 判断是否有满足条件的水属性怪兽因对方原因离开场上的情况
function c53742162.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c53742162.filter,1,nil,tp)
end
-- 过滤函数，用于筛选卡组中可加入手卡或特殊召唤的「冰水」怪兽
function c53742162.ffilter(c,e,tp,ft)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x16c) and (c:IsAbleToHand() or ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 效果处理时的取对象阶段，检查是否存在满足条件的「冰水」怪兽
function c53742162.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家场上可用的怪兽区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检查卡组中是否存在满足条件的「冰水」怪兽
		return Duel.IsExistingMatchingCard(c53742162.ffilter,tp,LOCATION_DECK,0,1,nil,e,tp,ft)
	end
end
-- 效果处理函数，执行②效果的处理流程
function c53742162.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择1只满足条件的「冰水」怪兽
	local g=Duel.SelectMatchingCard(tp,c53742162.ffilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft)
	local tc=g:GetFirst()
	if tc then
		-- 判断是否选择将怪兽加入手卡
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将怪兽加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方确认加入手卡的怪兽
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
