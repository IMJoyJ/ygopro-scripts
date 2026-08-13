--スター・ブライト・ドラゴン
-- 效果：
-- 这张卡召唤成功时，可以选择这张卡以外的场上表侧表示存在的1只怪兽，直到结束阶段时等级上升2星。
function c16719802.initial_effect(c)
	-- 这张卡召唤成功时，可以选择这张卡以外的场上表侧表示存在的1只怪兽，直到结束阶段时等级上升2星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16719802,0))  --"等级上升"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c16719802.tg)
	e1:SetOperation(c16719802.op)
	c:RegisterEffect(e1)
end
-- 过滤函数，判断怪兽是否表侧表示且等级大于0，用于选择可等级上升的对象。
function c16719802.filter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 效果发动时的目标选择处理：若在连锁处理中指定对象，则验证该对象是否合法（场上表侧表示、等级大于0、不是本卡）；在发动时检查是否存在合法对象，并让玩家选择1只作为对象。
function c16719802.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c16719802.filter(chkc) and chkc~=e:GetHandler() end
	-- 发动条件判定：若处于效果发动前确认阶段（chk==0），则检查场上是否存在符合条件的对象（本卡以外的表侧表示且等级大于0的怪兽），有才能发动。
	if chk==0 then return Duel.IsExistingTarget(c16719802.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 显示选择提示信息，提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从场上选择1只表侧表示且等级大于0的怪兽（不能选择本卡）作为效果对象。
	Duel.SelectTarget(tp,c16719802.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
-- 效果处理：获取对象怪兽，若其仍表侧表示且与效果有关联，则给它附加等级上升2星的效果，该效果持续到结束阶段。
function c16719802.op(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 直到结束阶段时等级上升2星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
