--混沌の呪術師
-- 效果：
-- 反转：从自己或对方的墓地里选择1张怪兽卡，将被选择的卡从游戏中除外。
function c75946257.initial_effect(c)
	-- 反转：从自己或对方的墓地里选择1张怪兽卡，将被选择的卡从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75946257,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c75946257.target)
	e1:SetOperation(c75946257.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：判断卡片是否为怪兽卡且可以被除外
function c75946257.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 效果的发动准备：进行对象合法性检测，提示并让玩家选择1个墓地怪兽作为对象，并注册除外操作信息
function c75946257.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c75946257.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家发送选择提示，显示“请选择要除外的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己或对方墓地中的1张怪兽卡作为效果的对象
	local g=Duel.SelectTarget(tp,c75946257.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 设置操作信息，表明该效果会将选中的墓地卡片除外
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,tc:GetControler(),LOCATION_GRAVE)
	end
end
-- 效果的处理：获取对象卡片，若其仍与效果相关联，则将其除外
function c75946257.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片以表侧表示因效果除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
