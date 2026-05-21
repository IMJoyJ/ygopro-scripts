--侵略の侵喰崩壊
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「入魔」的怪兽从游戏中除外，选择对方场上2张卡回到持有者手卡。
function c90934570.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只名字带有「入魔」的怪兽从游戏中除外，选择对方场上2张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c90934570.target)
	e1:SetOperation(c90934570.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示、名字带有「入魔」且可以被除外的怪兽
function c90934570.rmfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xa) and c:IsAbleToRemove()
end
-- 效果发动的目标选择与合法性检测
function c90934570.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检测自己场上是否存在至少1只满足除外条件的表侧表示「入魔」怪兽
	if chk==0 then return Duel.IsExistingTarget(c90934570.rmfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检测对方场上是否存在至少2张可以回到手牌的卡
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,2,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己场上1只表侧表示的「入魔」怪兽作为除外对象
	local g1=Duel.SelectTarget(tp,c90934570.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,1,0,0)
	-- 提示玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上2张卡作为返回手牌的对象
	local g2=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,2,2,nil)
	-- 设置操作信息：将选中的卡片送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,g2:GetCount(),0,0)
end
-- 效果处理：除外己方「入魔」怪兽，并使对方卡片回到手牌
function c90934570.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取除外操作的目标卡片组
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_REMOVE)
	-- 获取返回手牌操作的目标卡片组
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_TOHAND)
	-- 若作为除外对象的怪兽仍与效果相关且呈表侧表示，则将其除外，若成功除外：
	if g1:GetFirst():IsRelateToEffect(e) and g1:GetFirst():IsFaceup() and Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)~=0 then
		local hg=g2:Filter(Card.IsRelateToEffect,nil,e)
		-- 将对方场上仍与效果相关的对象卡片送回持有者手牌
		Duel.SendtoHand(hg,nil,REASON_EFFECT)
	end
end
