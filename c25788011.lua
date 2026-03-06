--調星師ライズベルト
-- 效果：
-- ①：这张卡特殊召唤成功时，以场上1只表侧表示怪兽为对象才能发动。直到回合结束时，那只怪兽的等级上升最多3星。
function c25788011.initial_effect(c)
	-- 效果原文内容：①：这张卡特殊召唤成功时，以场上1只表侧表示怪兽为对象才能发动。直到回合结束时，那只怪兽的等级上升最多3星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25788011,0))  --"等级上升"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c25788011.target)
	e1:SetOperation(c25788011.operation)
	c:RegisterEffect(e1)
end
-- 检索满足条件的表侧表示怪兽（等级大于等于1）
function c25788011.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
-- 效果作用：选择一个场上的表侧表示怪兽作为对象
function c25788011.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c25788011.filter(chkc) end
	-- 判断是否满足选择对象的条件（场上存在符合条件的怪兽）
	if chk==0 then return Duel.IsExistingTarget(c25788011.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择一个表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一个场上的表侧表示怪兽作为对象
	Duel.SelectTarget(tp,c25788011.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果作用：设置等级上升效果
function c25788011.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 让玩家选择等级上升的数值（1/2/3星）
		local lv=Duel.SelectOption(tp,aux.Stringid(25788011,1),aux.Stringid(25788011,2),aux.Stringid(25788011,3))  --"等级上升1/等级上升2/等级上升3"
		-- 效果原文内容：直到回合结束时，那只怪兽的等级上升最多3星。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(lv+1)
		tc:RegisterEffect(e1)
	end
end
