--ハウリング・ウォリアー
-- 效果：
-- 这张卡召唤·特殊召唤成功时，选择自己场上表侧表示存在的1只怪兽才能发动。选择的怪兽的等级变成3星。
function c50785356.initial_effect(c)
	-- 这张卡召唤·特殊召唤成功时，选择自己场上表侧表示存在的1只怪兽才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50785356,0))  --"等级变化"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c50785356.target)
	e1:SetOperation(c50785356.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 筛选场上表侧表示且等级不是3的怪兽
function c50785356.filter(c)
	return c:IsFaceup() and not c:IsLevel(3) and c:IsLevelAbove(1)
end
-- 选择目标怪兽，确保其为场上的表侧表示怪兽且等级不为3
function c50785356.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c50785356.filter(chkc) end
	-- 检查是否有满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c50785356.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的1只怪兽作为效果对象
	Duel.SelectTarget(tp,c50785356.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 将选中的怪兽等级变为3星
function c50785356.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 设置效果使目标怪兽等级变为3星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(3)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
