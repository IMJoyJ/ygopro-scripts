--アマゾネスの賢者
-- 效果：
-- 这张卡攻击的场合，那次伤害步骤结束时选择对方场上存在的1张魔法·陷阱卡破坏。
function c53162898.initial_effect(c)
	-- ①：这张卡攻击的伤害步骤结束时，若这张卡在怪兽区域存在，以对方场上1张魔法·陷阱卡为对象发动。那张对方的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53162898,0))  --"魔陷破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(c53162898.condition)
	e1:SetTarget(c53162898.target)
	e1:SetOperation(c53162898.operation)
	c:RegisterEffect(e1)
end
-- 发动条件判定：效果持有者必须为进行攻击的那张怪兽，且与本次战斗相关联（伤害步骤结束时仍未离场），以此对应“这张卡攻击的伤害步骤结束时，若这张卡在怪兽区域存在”。
function c53162898.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回 true 当且仅当效果持有者是攻击怪兽且与战斗相关，即确认“这张卡攻击”且该卡仍关联本次战斗。
	return e:GetHandler()==Duel.GetAttacker() and e:GetHandler():IsRelateToBattle()
end
-- 候选对象过滤器：判定卡片为魔法卡或陷阱卡，用于选择对方场上的魔法·陷阱卡。
function c53162898.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动时的取对象处理：若为连锁中对象合法性确认（chkc）则校验该卡在对方场上且为魔陷；若为发动时点（chk==0）则允许发动；之后提示玩家选择对方场上1张魔法·陷阱卡作为对象，并登记此次破坏的操作信息。
function c53162898.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c53162898.filter(chkc) end
	if chk==0 then return true end
	-- 向当前玩家发出“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让当前玩家从对方场上选择1张魔法·陷阱卡作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c53162898.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 将本次连锁的操作信息登记为破坏效果：对象为已选中的卡，数量为其张数，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：取得选中的对象，若对象仍与效果相关联（没有因其它处理离场或失去联系），则将其破坏。
function c53162898.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次连锁中记录的第一个效果对象。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以这张卡的效果为原因破坏该对象。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
