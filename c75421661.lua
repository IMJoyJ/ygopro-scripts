--ドドドガッサー
-- 效果：
-- 只要反转召唤的这张卡在场上表侧表示存在，这张卡的攻击力上升3500。此外，这张卡反转时，选择场上表侧表示存在的最多2只怪兽才能发动。选择的怪兽破坏。
function c75421661.initial_effect(c)
	-- 只要反转召唤的这张卡在场上表侧表示存在，这张卡的攻击力上升3500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e1:SetOperation(c75421661.atkop)
	c:RegisterEffect(e1)
	-- 此外，这张卡反转时，选择场上表侧表示存在的最多2只怪兽才能发动。选择的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75421661,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_FLIP)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c75421661.destg)
	e2:SetOperation(c75421661.desop)
	c:RegisterEffect(e2)
end
-- 反转召唤成功时，为自身注册攻击力上升的效果
function c75421661.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 这张卡的攻击力上升3500
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(3500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e:GetHandler():RegisterEffect(e1)
end
-- 破坏效果的对象选择函数，用于验证并选择场上表侧表示的怪兽
function c75421661.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and Card.IsFaceup(chkc) end
	-- 在发动条件检查时，确认场上是否存在至少1只可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上表侧表示存在的1到2只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,2,nil)
	-- 设置当前连锁的操作信息，表明将要破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的效果处理函数，将仍对效果有效的对象怪兽破坏
function c75421661.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡片，并筛选出其中仍对该效果有效的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 因效果将目标怪兽破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
