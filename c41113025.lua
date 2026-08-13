--ディスクライダー
-- 效果：
-- 把自己墓地存在的1张通常陷阱卡从游戏中除外，这张卡的攻击力直到对方回合的结束阶段时上升500。这个效果1回合只能使用1次。
function c41113025.initial_effect(c)
	-- 把自己墓地存在的1张通常陷阱卡从游戏中除外，这张卡的攻击力直到对方回合的结束阶段时上升500。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41113025,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c41113025.target)
	e1:SetOperation(c41113025.operation)
	c:RegisterEffect(e1)
end
-- 筛选自己墓地中满足条件的通常陷阱卡：卡类型为通常陷阱卡且能被除外。
function c41113025.cfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsAbleToRemove()
end
-- 目标选择函数：选择自己墓地1张通常陷阱卡作为对象，并设置除外信息；同时处理发动时的对象合法性检查和选择提示。
function c41113025.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c41113025.cfilter(chkc) end
	-- 发动合法性检查：确认自己墓地存在至少1张符合条件的通常陷阱卡可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c41113025.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家显示选择提示，要求选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张符合条件的通常陷阱卡，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c41113025.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记效果信息：本次处理将除外1张墓地的卡，供连锁判定等使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
end
-- 效果处理：将对象卡除外；若成功且此卡仍表侧表示并与效果关联，则给此卡附加攻击力上升500的效果。
function c41113025.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判断条件：对象仍与此效果关联且被成功除外，且此卡仍表侧表示并与效果关联；满足则继续赋予攻击力上升。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到对方回合的结束阶段时上升500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e1)
	end
end
