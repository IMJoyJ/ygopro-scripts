--ユニゾン・チューン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己或者对方的墓地1只调整和场上1只表侧表示怪兽为对象才能发动。作为对象的墓地的怪兽除外。那之后，作为对象的场上的怪兽直到回合结束时变成和除外的怪兽相同等级，当作调整使用。
function c12743620.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己或者对方的墓地1只调整和场上1只表侧表示怪兽为对象才能发动。作为对象的墓地的怪兽除外。那之后，作为对象的场上的怪兽直到回合结束时变成和除外的怪兽相同等级，当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,12743620+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c12743620.target)
	e1:SetOperation(c12743620.activate)
	c:RegisterEffect(e1)
end
-- 筛选墓地中可作为对象的调整怪兽：必须等级大于0、是调整、可除外，且场上存在至少1只能以该等级作为另一对象的表侧表示怪兽。
function c12743620.filter1(c,tp)
	local lv=c:GetLevel()
	return lv>0 and c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
		-- 确认场上存在至少1只满足filter2的表侧表示怪兽，保证‘墓地调整+场上怪兽’这一对象组合能够成立。
		and Duel.IsExistingTarget(c12743620.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lv)
end
-- 筛选场上可作为对象的表侧表示怪兽：表侧表示、等级≥1，且排除‘已经是调整且等级等于所选墓地调整等级’的怪兽（即不是完全无变化的目标）。
function c12743620.filter2(c,lv)
	return c:IsFaceup() and c:IsLevelAbove(1) and (not c:IsType(TYPE_TUNER) or not c:IsLevel(lv))
end
-- 发动时的对象选择流程：先检查墓地是否有符合条件的调整；然后让玩家从双方墓地选1只调整存入e的LabelObject，再从场上选1只表侧表示怪兽；最后根据调整所在墓地登记除外操作信息。
function c12743620.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在效果发动的合法性检查中，确认双方墓地合计存在至少1只满足filter1的调整怪兽（含场上存在可配合对象这一前提）。
	if chk==0 then return Duel.IsExistingTarget(c12743620.filter1,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,tp) end
	-- 向操作方发送HINT_SELECTMSG选择提示，引导其选择墓地中的调整怪兽（此处使用了‘请选择要特殊召唤的卡’的提示常量，实际用于选墓地调整）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让操作方从双方墓地选择1只符合filter1的调整怪兽作为第一个对象，并自动与当前连锁建立对象关联。
	local g1=Duel.SelectTarget(tp,c12743620.filter1,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp)
	e:SetLabelObject(g1:GetFirst())
	-- 发送HINT_SELECTMSG选择提示，让操作方选择场上的表侧表示怪兽作为另一个对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让操作方从场上选择1只符合filter2的表侧表示怪兽作为第二个对象，额外传入之前所选调整的等级用于条件判断。
	local g2=Duel.SelectTarget(tp,c12743620.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g1:GetFirst():GetLevel())
	if g1:GetFirst():IsControler(tp) then
		-- 若选中的墓地调整在自己墓地，登记除外操作信息：从自己墓地除外1张卡。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,1,tp,LOCATION_GRAVE)
	else
		-- 若选中的墓地调整在对方墓地，登记除外操作信息：从对方墓地除外1张卡。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,1,1-tp,LOCATION_GRAVE)
	end
end
-- 效果处理：取出LabelObject中保存的墓地调整和连锁对象中的场上怪兽；先确认调整仍与效果关联，将其正面表示除外并确认成功后，用BreakEffect把后续处理分开；然后给场上怪兽先后注册‘等级变为除外怪兽等级’和‘当作调整使用’的效果，持续到结束阶段。
function c12743620.activate(e,tp,eg,ep,ev,re,r,rp)
	local hc=e:GetLabelObject()
	-- 获取当前连锁处理时的全部对象卡组，即发动效果时选择的两张卡，用于从中区分出墓地调整和场上怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==hc then tc=g:GetNext() end
	-- 判断墓地调整卡仍与该效果关联、能够被正面表示除外并实际除外成功且位于除外区；若成立才进行后续的等级变更与调整化处理。
	if hc:IsRelateToEffect(e) and Duel.Remove(hc,POS_FACEUP,REASON_EFFECT)~=0 and hc:IsLocation(LOCATION_REMOVED) then
		-- 中断当前效果处理，使‘除外’与‘那之后’的怪兽能力变更不视为同时处理，以正确安排时点。
		Duel.BreakEffect()
		-- 那之后，作为对象的场上的怪兽直到回合结束时变成和除外的怪兽相同等级。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(hc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e2)
	end
end
