--幻角獣フュプノコーン
-- 效果：
-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合这张卡召唤成功时，可以选择场上盖放的1张魔法·陷阱卡破坏。
function c20351153.initial_effect(c)
	-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合这张卡召唤成功时，可以选择场上盖放的1张魔法·陷阱卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20351153,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(c20351153.descon)
	e3:SetTarget(c20351153.destg)
	e3:SetOperation(c20351153.desop)
	c:RegisterEffect(e3)
end
-- 发动条件函数：判断当前状况是否满足“对方场上有怪兽存在，自己场上没有怪兽存在”这一召唤成功时的发动条件（此处用自己场上怪兽区数量≤1来表示除这张召唤成功的怪兽外没有其他怪兽）。
function c20351153.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 统计自己场上怪兽区数量≤1（即除这张召唤成功的怪兽外没有其他怪兽），且对方场上怪兽区数量>0，两者同时满足才可发动。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<=1 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 选择对象用过滤函数：选择里侧表示存在的魔法·陷阱卡，即场上的盖牌。
function c20351153.filter(c)
	return c:IsFacedown()
end
-- 发动目标函数：检查能否选择对象；若能，则提示玩家从双方魔陷区选择1张里侧表示的魔法·陷阱卡，并登记破坏信息。
function c20351153.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c20351153.filter(chkc) end
	-- 在发动时检查：场上是否存在至少1张符合条件的里侧表示魔法·陷阱卡可作为效果对象，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c20351153.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	-- 向玩家显示选择提示，提示内容是“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方魔陷区选择1张里侧表示的魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c20351153.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	-- 登记本次连锁的处理信息：本次效果将破坏1张卡，供连锁处理时点及效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数：取得对象卡，若该卡仍在场上且为里侧表示、且与效果保持关联，则将其破坏。
function c20351153.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果发动时选择的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 将该目标卡以效果（REASON_EFFECT）的原因破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
