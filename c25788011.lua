--調星師ライズベルト
-- 效果：
-- ①：这张卡特殊召唤成功时，以场上1只表侧表示怪兽为对象才能发动。直到回合结束时，那只怪兽的等级上升最多3星。
function c25788011.initial_effect(c)
	-- ①：这张卡特殊召唤成功时，以场上1只表侧表示怪兽为对象才能发动。直到回合结束时，那只怪兽的等级上升最多3星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25788011,0))  --"等级上升"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c25788011.target)
	e1:SetOperation(c25788011.operation)
	c:RegisterEffect(e1)
end
-- 筛选条件：场上表侧表示且等级在1星以上的怪兽（即可作为对象的表侧表示怪兽）。
function c25788011.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
-- 发动时的目标选择处理：若为选择对象时点，则校验对象是否在主要怪兽区且满足筛选条件；若为发动合法性检查，则确认场上是否存在至少1只符合条件的表侧表示怪兽；然后提示玩家选择表侧表示的卡并选定1只作为对象。
function c25788011.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c25788011.filter(chkc) end
	-- 发动合法性检查：确认场上是否存在至少1只满足筛选条件的表侧表示怪兽（且可作为效果对象）。
	if chk==0 then return Duel.IsExistingTarget(c25788011.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择消息提示，将提示内容设置为“请选择表侧表示的卡”，用于后续选择卡片时的显示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从双方主要怪兽区选择1只满足筛选条件的表侧表示怪兽，并将其设置为该效果的对象。
	Duel.SelectTarget(tp,c25788011.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理时的操作：获取效果持有者和对象怪兽，若对象怪兽仍表侧表示且与效果有关联，则让玩家选择上升1/2/3星，然后对对象怪兽赋予对应星数上升的永续效果（持续到回合结束）。
function c25788011.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取该连锁处理中选定的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 让玩家选择等级上升的数量（1星/2星/3星），返回所选选项的序号（0/1/2）。
		local lv=Duel.SelectOption(tp,aux.Stringid(25788011,1),aux.Stringid(25788011,2),aux.Stringid(25788011,3))  --"等级上升1/等级上升2/等级上升3"
		-- 直到回合结束时，那只怪兽的等级上升最多3星。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(lv+1)
		tc:RegisterEffect(e1)
	end
end
