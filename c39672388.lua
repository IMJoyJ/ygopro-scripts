--エヴォルダー・ダルウィノス
-- 效果：
-- 这张卡用名字带有「进化虫」的怪兽的效果特殊召唤成功时，可以选择场上表侧表示存在的1只怪兽等级上升最多2星。
function c39672388.initial_effect(c)
	-- 这张卡用名字带有「进化虫」的怪兽的效果特殊召唤成功时，可以选择场上表侧表示存在的1只怪兽等级上升最多2星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39672388,0))  --"等级上升"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 效果触发条件为使用「进化虫」怪兽的效果特殊召唤成功
	e1:SetCondition(aux.evospcon)
	e1:SetTarget(c39672388.lvtg)
	e1:SetOperation(c39672388.lvop)
	c:RegisterEffect(e1)
end
-- 过滤器函数，用于判断目标怪兽是否为表侧表示且等级大于等于0
function c39672388.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(0)
end
-- 设置效果的目标选择函数，用于选择场上表侧表示的怪兽
function c39672388.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c39672388.filter(chkc) end
	-- 判断是否存在满足条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c39672388.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c39672388.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果发动时执行的操作函数，用于处理等级上升效果
function c39672388.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 让玩家选择等级上升1星或2星
		local opt=Duel.SelectOption(tp,aux.Stringid(39672388,1),aux.Stringid(39672388,2))  --"等级上升１星/等级上升２星"
		-- 为选中的怪兽设置等级上升效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(opt+1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
