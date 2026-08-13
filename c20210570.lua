--レグルス
-- 效果：
-- 选择自己墓地存在的1张场地魔法卡发动。选择的卡回到卡组。这个效果1回合只能使用1次。
function c20210570.initial_effect(c)
	-- 选择自己墓地存在的1张场地魔法卡发动。选择的卡回到卡组。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20210570,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c20210570.target)
	e1:SetOperation(c20210570.operation)
	c:RegisterEffect(e1)
end
-- 定义过滤条件：仅选择自己墓地存在的场地魔法卡，且该卡满足能够返回卡组的条件（不受“不能回卡组”等限制）。
function c20210570.filter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToDeck()
end
-- 效果发动时的目标选择与合法性判定函数：检查是否存在合法对象，选择自己墓地1张场地魔法卡作为对象，并设置本次连锁的回卡组操作信息。
function c20210570.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c20210570.filter(chkc) end
	-- 效果发动前（chk==0）检查自己墓地是否存在至少1张满足条件的场地魔法卡可作为对象，若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c20210570.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向操作玩家显示“请选择要返回卡组的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让操作玩家从自己墓地的场地魔法卡中选择1张作为效果对象，并将其登记为当前连锁的对象卡。
	local g=Duel.SelectTarget(tp,c20210570.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本次连锁将执行“返回卡组”的操作信息：对象为已选择的卡，数量为其数量（1张），供相关卡/效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理时的执行函数：取得效果对象，若对象仍与效果关联，则将其返回持有者卡组并洗牌。
function c20210570.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果发动时选择的对象卡（第一张目标卡）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡返回其持有者卡组，并执行卡组洗切（回卡组后洗牌）。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
