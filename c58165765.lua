--赤竜の忍者
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，把自己墓地1张名字带有「忍者」或者「忍法」的卡从游戏中除外，选择对方场上盖放的1张卡才能发动。把选择的卡确认，回到持有者卡组最上面或者最下面。对方不能对应这个效果的发动把选择的卡发动。「红龙忍者」的效果1回合只能使用1次。
function c58165765.initial_effect(c)
	-- 这张卡召唤·反转召唤·特殊召唤成功时，把自己墓地1张名字带有「忍者」或者「忍法」的卡从游戏中除外，选择对方场上盖放的1张卡才能发动。把选择的卡确认，回到持有者卡组最上面或者最下面。对方不能对应这个效果的发动把选择的卡发动。「红龙忍者」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58165765,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,58165765)
	e1:SetCost(c58165765.cost)
	e1:SetTarget(c58165765.target)
	e1:SetOperation(c58165765.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己墓地中名字带有「忍者」或「忍法」且可以作为代价除外的卡
function c58165765.cfilter(c)
	return c:IsSetCard(0x2b,0x61) and c:IsAbleToRemoveAsCost()
end
-- 发动代价（Cost）：把自己墓地1张名字带有「忍者」或者「忍法」的卡除外
function c58165765.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c58165765.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己墓地1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c58165765.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：对方场上盖放的且能回到卡组的卡
function c58165765.filter(c)
	return c:IsFacedown() and c:IsAbleToDeck()
end
-- 效果的目标选择与连锁限制处理
function c58165765.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c58165765.filter(chkc) end
	-- 检查对方场上是否存在至少1张满足过滤条件的盖放卡
	if chk==0 then return Duel.IsExistingTarget(c58165765.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方场上1张盖放的卡作为效果对象
	local g=Duel.SelectTarget(tp,c58165765.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：将选择的1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设定连锁限制，使对方不能对应这个效果的发动把选择的卡发动
	Duel.SetChainLimit(c58165765.limit(g:GetFirst()))
end
-- 连锁限制条件函数：限制对方不能发动作为效果对象的卡
function c58165765.limit(c)
	return	function (e,lp,tp)
				return e:GetHandler()~=c
			end
end
-- 效果处理（确认选择的卡并使其回到持有者卡组最上面或最下面）
function c58165765.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象（被选择的卡）
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFacedown() then
		-- 让发动效果的玩家确认选择的卡
		Duel.ConfirmCards(tp,tc)
		-- 中断当前效果处理，使后续的返回卡组处理与确认卡片不同时处理
		Duel.BreakEffect()
		if tc:IsAbleToDeck() then
			if tc:IsExtraDeckMonster()
				-- 如果是额外卡组怪兽，或者玩家选择“返回卡组最上方”
				or Duel.SelectOption(tp,aux.Stringid(58165765,1),aux.Stringid(58165765,2))==0 then  --"返回卡组最上方/返回卡组最下方"
				-- 将选择的卡送回持有者卡组最上面
				Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
			else
				-- 将选择的卡送回持有者卡组最下面
				Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			end
		end
	end
end
