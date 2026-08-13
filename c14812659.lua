--覚星師ライズベルト
-- 效果：
-- 1回合1次，选择场上表侧表示存在的1只怪兽才能发动。选择的怪兽的等级上升1星。这个效果在对方回合也能发动。
function c14812659.initial_effect(c)
	-- 1回合1次，选择场上表侧表示存在的1只怪兽才能发动。选择的怪兽的等级上升1星。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14812659,0))  --"等级上升1"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c14812659.target)
	e1:SetOperation(c14812659.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：怪兽须为表侧表示且等级在1以上，即场上表侧表示的怪兽。
function c14812659.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
-- 效果发动条件与取对象处理：先验证连锁中指定的对象是否合法；发动时检查场上是否存在符合条件的表侧表示怪兽；存在则提示玩家并选择1只作为对象。
function c14812659.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c14812659.filter(chkc) end
	-- 发动检查：若场上不存在至少1只满足条件且能成为效果对象的表侧表示怪兽，则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c14812659.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从双方怪兽区域选择1只满足条件的表侧表示怪兽，并登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,c14812659.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：获取对象怪兽，若其仍在场上且为表侧表示并与该效果关联，则对其赋予等级上升1星的持续效果（持续到怪兽离场等标准重置时）。
function c14812659.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁中登记的对象怪兽（即要上升等级的那只怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的怪兽的等级上升1星。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
