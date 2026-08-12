--神竜アクアバザル
-- 效果：
-- 把这张卡以外的自己场上表侧表示存在的1只水属性怪兽解放，选择自己墓地存在的1张永续魔法或者场地魔法卡发动。选择的卡从自己墓地回到卡组最上面。这个效果1回合只能使用1次。
function c67964209.initial_effect(c)
	-- 把这张卡以外的自己场上表侧表示存在的1只水属性怪兽解放，选择自己墓地存在的1张永续魔法或者场地魔法卡发动。选择的卡从自己墓地回到卡组最上面。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67964209,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c67964209.tdcost)
	e1:SetTarget(c67964209.tdtg)
	e1:SetOperation(c67964209.tdop)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的水属性怪兽
function c67964209.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 代价处理：解放自己场上除这张卡以外的1只表侧表示水属性怪兽
function c67964209.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在除这张卡以外可解放的表侧表示水属性怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c67964209.cfilter,1,e:GetHandler()) end
	-- 选择自己场上1只除这张卡以外的表侧表示水属性怪兽
	local g=Duel.SelectReleaseGroup(tp,c67964209.cfilter,1,1,e:GetHandler())
	-- 解放选择的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 过滤条件：自己墓地可以回到卡组的永续魔法或场地魔法卡
function c67964209.filter(c)
	local tpe=c:GetType()
	return bit.band(tpe,TYPE_SPELL)~=0 and bit.band(tpe,TYPE_CONTINUOUS+TYPE_FIELD)~=0 and c:IsAbleToDeck()
end
-- 效果的目标选择与发动准备
function c67964209.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c67964209.filter(chkc) end
	-- 检查自己墓地是否存在符合条件的永续魔法或场地魔法卡
	if chk==0 then return Duel.IsExistingTarget(c67964209.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1张符合条件的卡作为效果对象
	local g=Duel.SelectTarget(tp,c67964209.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理：将选中的卡送回卡组最上面
function c67964209.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片送回持有者卡组的最上面
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
