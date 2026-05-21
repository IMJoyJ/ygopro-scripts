--グランドタスク・ドラゴン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，以这张卡以外的场上最多2张卡为对象才能发动。那些卡破坏，这张卡的攻击力上升破坏数量×600。
function c98898163.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡召唤·特殊召唤成功的场合，以这张卡以外的场上最多2张卡为对象才能发动。那些卡破坏，这张卡的攻击力上升破坏数量×600。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,98898163)
	e1:SetTarget(c98898163.destg)
	e1:SetOperation(c98898163.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 效果①的Target函数：验证发动条件，并让玩家选择场上除自身以外的最多2张卡作为破坏对象
function c98898163.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	-- 在发动效果的检查阶段，判断场上是否存在至少1张除自身以外的卡可以作为对象
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 向发动效果的玩家发送提示信息，要求选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上除自身以外的1到2张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,c)
	-- 设置效果处理信息，表明此效果包含破坏操作，涉及卡片为选择的对象，数量为选择的数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果①的Operation函数：执行破坏操作，并根据实际破坏的数量提升自身的攻击力
function c98898163.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时被选为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将仍存在于场上的对象卡片因效果破坏，并记录实际被破坏的卡片数量
		local ct=Duel.Destroy(tg,REASON_EFFECT)
		if c:IsRelateToEffect(e) and c:IsFaceup() and not c:IsImmuneToEffect(e) then
			-- 这张卡的攻击力上升破坏数量×600
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(ct*600)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
