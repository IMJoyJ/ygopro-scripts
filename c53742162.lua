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
-- 自己场上表侧表示存在的、可用于效果①破坏的「冰水」怪兽的过滤条件
function c53742162.disfilter(c)
	return c:IsSetCard(0x16c) and c:IsFaceup()
end
-- 效果①的发动准备与对象选择
function c53742162.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查对方场上是否存在可以被无效效果的表侧表示卡片
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查自己场上是否存在表侧表示的「冰水」怪兽
		and Duel.IsExistingMatchingCard(c53742162.disfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示选择需要无效化效果的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1张表侧表示的卡作为无效的对象
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 获取自己场上符合破坏条件的「冰水」怪兽组
	local dg=Duel.GetMatchingGroup(c53742162.disfilter,tp,LOCATION_MZONE,0,nil)
	-- 设置操作信息为破坏己方场上的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
	-- 设置操作信息为无效化对方的卡片
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 破坏己方「冰水」怪兽并无效对方卡片效果的执行
function c53742162.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家提示选择需要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己场上选择1只表侧表示的「冰水」怪兽
	local g=Duel.SelectMatchingCard(tp,c53742162.disfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选择的「冰水」怪兽破坏，若破坏成功则处理后续的无效化
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		-- 获取当前连锁中关联的作为无效对象的卡片
		local tc=Duel.GetFirstTarget()
		if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
			-- 切断并无效与该卡关联的所有已在处理的连锁效果
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 注册使该卡片效果无效的单体无效化持续效果
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 注册在该回合内全面压制该卡片所触发一切动作效果的单体无效化效果
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 若该卡属于陷阱怪兽，另外注册使其陷阱怪兽属性无效化的单体无效化效果
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
	end
end
-- 自己场上原本表侧表示存在的水属性怪兽，因对方原因以破坏以外的手法离开场上时的过滤条件
function c53742162.filter(c,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and not c:IsReason(REASON_DESTROY) and c:GetReasonPlayer()==1-tp
end
-- 判断是否触发了水属性怪兽因对方非破坏离场的时间时点
function c53742162.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c53742162.filter,1,nil,tp)
end
-- 卡组中属于「冰水」字段，可以加入手牌或者在场上有空位时可特殊召唤的怪兽的过滤条件
function c53742162.ffilter(c,e,tp,ft)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x16c) and (c:IsAbleToHand() or ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 效果②的发动准备与合法性检查
function c53742162.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己当前怪兽格的剩余位置，以判断是否能够特召
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检查卡组中是否存在可以检索或特殊召唤的「冰水」怪兽
		return Duel.IsExistingMatchingCard(c53742162.ffilter,tp,LOCATION_DECK,0,1,nil,e,tp,ft)
	end
end
-- 从卡组检索或特殊召唤「冰水」怪兽的执行
function c53742162.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时己方场上空闲的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 向玩家提示选择需要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择1只符合条件的「冰水」怪兽
	local g=Duel.SelectMatchingCard(tp,c53742162.ffilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft)
	local tc=g:GetFirst()
	if tc then
		-- 若该怪兽能加入手牌且由于位置受限或玩家主动选择“加入手牌”时，则进入检索流程
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选择的「冰水」怪兽卡片加入手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 将加入手牌的怪兽展示给对方确认
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将该「冰水」怪兽以表侧表示特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
