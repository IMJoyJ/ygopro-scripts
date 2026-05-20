--エレキック・ファイター
-- 效果：
-- 「电气念力斗士」的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功时，以对方墓地1张卡为对象才能发动。那张卡回到对方卡组最上面或者最下面。
function c81028112.initial_effect(c)
	-- 「电气念力斗士」的效果1回合只能使用1次。①：这张卡召唤·特殊召唤成功时，以对方墓地1张卡为对象才能发动。那张卡回到对方卡组最上面或者最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81028112,0))  --"墓地干扰"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,81028112)
	e1:SetTarget(c81028112.target)
	e1:SetOperation(c81028112.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 效果①的Target（发动准备）函数：进行对象选择与合法性检测
function c81028112.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToDeck() end
	-- 在发动效果的阶段（chk==0），检查对方墓地是否存在至少1张可以回到卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil) end
	-- 给发动效果的玩家发送“请选择要返回卡组的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方墓地1张可以回到卡组的卡作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置当前连锁的操作信息，表示该效果包含“送回卡组”的操作，对象为选择的卡，数量为1张
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果①的Operation（效果处理）函数：将作为对象的卡送回持有者卡组的最上面或最下面
function c81028112.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果处理中作为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:IsExtraDeckMonster()
			-- 如果该卡是额外卡组怪兽则直接判定（因为只能回额外卡组），否则让玩家选择将其放回卡组最上面（选项0）还是最下面（选项1），并判断是否选择了最上面
			or Duel.SelectOption(tp,aux.Stringid(81028112,1),aux.Stringid(81028112,2))==0 then  --"卡组最上面/卡组最下面"
			-- 通过效果将目标卡片送回持有者卡组的最上面
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		else
			-- 通过效果将目标卡片送回持有者卡组的最下面
			Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
