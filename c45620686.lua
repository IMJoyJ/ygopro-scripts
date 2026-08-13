--騒々虫
-- 效果：
-- 把这张卡从手卡送去墓地发动。场上存在的1只怪兽的等级直到结束阶段时上升1星。
function c45620686.initial_effect(c)
	-- 把这张卡从手卡送去墓地发动。场上存在的1只怪兽的等级直到结束阶段时上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45620686,0))  --"等级上升"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c45620686.lvcost)
	e1:SetTarget(c45620686.lvtg)
	e1:SetOperation(c45620686.lvop)
	c:RegisterEffect(e1)
end
-- 定义发动代价函数：chk==0时检查此卡能否作为代价从手卡送去墓地，可支付时实际将这张卡送去墓地作为发动代价。
function c45620686.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡从手卡送去墓地，作为发动效果的代价(COST)。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 定义对象筛选条件：场上表侧表示且等级在0以上的怪兽（即所有表侧表示怪兽）。
function c45620686.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(0)
end
-- 定义取对象目标函数：验证连锁选定的对象是否合法；检查是否存在可选对象；提示玩家选择1只表侧表示怪兽并取为对象。
function c45620686.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c45620686.lvfilter(chkc) end
	-- 发动时检查双方怪兽区是否存在至少1只满足条件的表侧表示怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c45620686.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择表侧表示怪兽的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从双方怪兽区选择1只表侧表示怪兽作为效果对象，并将其登记为当前连锁处理的对象。
	Duel.SelectTarget(tp,c45620686.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 定义效果处理函数：取得对象怪兽，若其仍与此效果关联且表侧表示，则给它附加一个直到结束阶段等级上升1星的效果。
function c45620686.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得此效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 场上存在的1只怪兽的等级直到结束阶段时上升1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
