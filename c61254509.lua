--トライポッド・フィッシュ
-- 效果：
-- 这张卡从墓地的特殊召唤成功时，选择场上1只鱼族·海龙族·水族怪兽才能发动。选择的怪兽的等级上升1星。
function c61254509.initial_effect(c)
	-- 这张卡从墓地的特殊召唤成功时，选择场上1只鱼族·海龙族·水族怪兽才能发动。选择的怪兽的等级上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61254509,0))  --"等级上升"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c61254509.condition)
	e1:SetTarget(c61254509.target)
	e1:SetOperation(c61254509.operation)
	c:RegisterEffect(e1)
end
-- 判定效果发动条件：特殊召唤成功的这张卡在特殊召唤前位于墓地。
function c61254509.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 筛选可选择的怪兽：场上表侧表示、种族为鱼族或海龙族或水族、且等级在1星以上的怪兽。
function c61254509.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA) and c:IsLevelAbove(1)
end
-- 效果目标设定处理：先确认指定的对象合法，再检查是否存在可选择的怪兽，然后让玩家选择1只符合条件的表侧表示怪兽并将其设为效果对象。
function c61254509.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c61254509.filter(chkc) end
	-- 发动合法性检查：若场上不存在满足条件的怪兽，则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c61254509.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择提示，提示内容为“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从场上选择1只符合条件的表侧表示怪兽作为效果对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,c61254509.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：获取对象怪兽，若其仍表侧表示且与效果相关，则使其等级上升1星。
function c61254509.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动效果时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的怪兽的等级上升1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
