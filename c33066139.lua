--カードを狩る死神
-- 效果：
-- 反转：选择场上存在的1张陷阱卡破坏。选择的卡是盖放的场合，把那张卡翻开确认，是陷阱卡则破坏。魔法卡的场合回到原状。
function c33066139.initial_effect(c)
	-- 反转：选择场上存在的1张陷阱卡破坏。选择的卡是盖放的场合，把那张卡翻开确认，是陷阱卡则破坏。魔法卡的场合回到原状。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33066139,0))  --"陷阱破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c33066139.target)
	e1:SetOperation(c33066139.operation)
	c:RegisterEffect(e1)
end
-- 对象过滤条件：可选择里侧表示的卡或表侧表示的陷阱卡（即位于魔陷区的里侧卡或陷阱卡）。
function c33066139.filter(c)
	return c:IsFacedown() or c:IsType(TYPE_TRAP)
end
-- 反转效果发动时的取对象处理：先进行对象合法性判断；发动时玩家从双方魔陷区选择1张满足过滤条件的卡作为对象；若选择到表侧表示的卡，则预设置破坏该卡的操作信息。
function c33066139.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c33066139.filter(chkc) end
	if chk==0 then return true end
	-- 向操作玩家显示选择提示，提示内容为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让操作玩家从双方魔陷区选择1张满足filter条件且不是效果怪兽自身的卡作为效果对象，并将其登记为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,c33066139.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,e:GetHandler())
	if g:GetCount()>0 and g:GetFirst():IsFaceup() then
		-- 当选择的对象是表侧表示时，预设置本次连锁将破坏1张卡的操作信息（用于后续星尘龙等卡的对应判定；里侧对象因最终是否破坏不确定，故不设置）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果处理阶段：取得发动时选择的对象；若对象仍与效果关联，则先处理里侧确认，再根据确认后的种类决定是否破坏。
function c33066139.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的那1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 若对象是里侧表示，则将其翻开给操作玩家确认（不改变表示形式，仅确认）。
		if tc:IsFacedown() then Duel.ConfirmCards(tp,tc) end
		-- 确认后若对象是陷阱卡，则将其以效果原因破坏；若是魔法卡则什么也不做，即维持原状。
		if tc:IsType(TYPE_TRAP) then Duel.Destroy(tc,REASON_EFFECT) end
	end
end
