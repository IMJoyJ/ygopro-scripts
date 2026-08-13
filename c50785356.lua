--ハウリング・ウォリアー
-- 效果：
-- 这张卡召唤·特殊召唤成功时，选择自己场上表侧表示存在的1只怪兽才能发动。选择的怪兽的等级变成3星。
function c50785356.initial_effect(c)
	-- 这张卡召唤·特殊召唤成功时，选择自己场上表侧表示存在的1只怪兽才能发动。选择的怪兽的等级变成3星。
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
-- 筛选可成为对象的怪兽：必须是自己场上表侧表示且等级不是3星、等级在1以上的怪兽。
function c50785356.filter(c)
	return c:IsFaceup() and not c:IsLevel(3) and c:IsLevelAbove(1)
end
-- 效果发动的目标处理：确认存在合法对象后，让玩家从自己场上表侧表示怪兽中选择1只，并将其设为效果对象。
function c50785356.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c50785356.filter(chkc) end
	-- 效果发动时的合法性检查：若自己场上不存在1只满足filter的表侧表示怪兽，则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c50785356.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示选择提示“请选择表侧表示的卡”，让玩家知道接下来要选择的对象种类。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上的表侧表示怪兽中选择1只满足filter的怪兽作为效果对象，并关联到当前连锁。
	Duel.SelectTarget(tp,c50785356.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理时，若对象怪兽仍与效果关联且表侧表示，则令其等级变成3星，并注册该等级变化效果。
function c50785356.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果选择的第1张对象卡（目标怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 选择的怪兽的等级变成3星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(3)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
