--スター・ブライト・ドラゴン
-- 效果：
-- 这张卡召唤成功时，可以选择这张卡以外的场上表侧表示存在的1只怪兽，直到结束阶段时等级上升2星。
function c16719802.initial_effect(c)
	-- 诱发选发效果，通常召唤成功时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16719802,0))  --"等级上升"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c16719802.tg)
	e1:SetOperation(c16719802.op)
	c:RegisterEffect(e1)
end
-- 筛选条件：表侧表示且等级大于0的怪兽
function c16719802.filter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 选择目标：场上表侧表示存在的1只怪兽
function c16719802.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c16719802.filter(chkc) and chkc~=e:GetHandler() end
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(c16719802.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的1只怪兽作为目标
	Duel.SelectTarget(tp,c16719802.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
-- 效果处理：使目标怪兽等级上升2星
function c16719802.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 等级上升2星的效果直到结束阶段时重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
