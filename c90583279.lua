--八雷天神
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡可以把自己墓地1只等级或者阶级是8的怪兽除外，从手卡特殊召唤。
-- ②：以自己墓地1只等级或者阶级是8的仪式·融合·同调·超量怪兽为对象才能发动。那只怪兽回到卡组。那之后，回去的怪兽种类的以下效果适用。
-- ●仪式·融合：自己从卡组抽1张。
-- ●同调·超量：这张卡的攻击力上升1000。
function c90583279.initial_effect(c)
	-- ①：这张卡可以把自己墓地1只等级或者阶级是8的怪兽除外，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c90583279.spcon)
	e1:SetTarget(c90583279.sptg)
	e1:SetOperation(c90583279.spop)
	c:RegisterEffect(e1)
	-- ②：以自己墓地1只等级或者阶级是8的仪式·融合·同调·超量怪兽为对象才能发动。那只怪兽回到卡组。那之后，回去的怪兽种类的以下效果适用。●仪式·融合：自己从卡组抽1张。●同调·超量：这张卡的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,90583279)
	e2:SetTarget(c90583279.tdtg)
	e2:SetOperation(c90583279.tdop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地等级或者阶级是8且可以除外的怪兽
function c90583279.spfilter(c)
	return (c:IsLevel(8) or c:IsRank(8)) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则的条件：怪兽区域有空位，且自己墓地存在满足条件的怪兽
function c90583279.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只等级或者阶级是8的怪兽
		and Duel.IsExistingMatchingCard(c90583279.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤规则的准备：选择自己墓地1只等级或者阶级是8的怪兽，并将其作为标签对象保存
function c90583279.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地所有满足条件的怪兽
	local g=Duel.GetMatchingGroup(c90583279.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的执行：将选择的墓地怪兽除外
function c90583279.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 过滤自己墓地可以回到卡组的、等级或者阶级是8的仪式·融合·同调·超量怪兽，且若为仪式·融合则自己必须能抽卡
function c90583279.tdfilter(c,tp)
	return c:IsAbleToDeck()
		and ((c:IsType(TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO) and c:IsLevel(8))
			or (c:IsType(TYPE_XYZ) and c:IsRank(8)))
		-- 检查玩家是否可以抽卡（针对仪式·融合怪兽），或者该怪兽是同调·超量怪兽
		and (Duel.IsPlayerCanDraw(tp,1) or c:IsType(TYPE_SYNCHRO+TYPE_XYZ))
end
-- 效果②的发动准备：选择自己墓地1只满足条件的怪兽作为对象，并设置操作信息
function c90583279.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c90583279.tdfilter(chkc,tp) end
	-- 检查自己墓地是否存在可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c90583279.tdfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c90583279.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置效果处理信息：将1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	if g:GetFirst():IsType(TYPE_RITUAL+TYPE_FUSION) then
		-- 如果对象是仪式·融合怪兽，设置效果处理信息：自己从卡组抽1张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
-- 效果②的效果处理：将对象怪兽送回卡组（或额外卡组），并根据其种类适用后续效果
function c90583279.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍适用效果，并将其送回卡组（洗切卡组）或额外卡组
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
		and ((tc:IsType(TYPE_RITUAL) and tc:IsLocation(LOCATION_DECK))
			or (tc:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) and tc:IsLocation(LOCATION_EXTRA))) then
		if tc:IsType(TYPE_RITUAL+TYPE_FUSION) then
			-- 中断当前效果，使之后的效果处理（抽卡）视为不同时处理
			Duel.BreakEffect()
			-- 洗切玩家的卡组
			Duel.ShuffleDeck(tp)
			-- 玩家从卡组抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
		if tc:IsType(TYPE_SYNCHRO+TYPE_XYZ)
			and c:IsFaceup() and c:IsRelateToEffect(e) then
			-- 中断当前效果，使之后的效果处理（攻击力上升）视为不同时处理
			Duel.BreakEffect()
			-- ●同调·超量：这张卡的攻击力上升1000。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
