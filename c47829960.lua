--カオスライダー グスタフ
-- 效果：
-- 从自己墓地里除外至多2张魔法卡。以此效果每除外1张卡，这张卡的攻击力就上升300点直到对方回合结束。此效果1回合只能使用1次。
function c47829960.initial_effect(c)
	-- 从自己墓地里除外至多2张魔法卡。以此效果每除外1张卡，这张卡的攻击力就上升300点直到对方回合结束。此效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47829960,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c47829960.target)
	e1:SetOperation(c47829960.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：用于选择自己墓地中“是魔法卡且能够被除外”的卡片。
function c47829960.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemove()
end
-- 发动阶段的目标判定：检查自己墓地是否存在至少1张满足过滤条件的魔法卡，若存在则允许发动，并登记效果信息（除外分类，对象为自己墓地，预计1张）。实际除外数量由效果处理时的选择决定（1~2张）。
function c47829960.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点判定：若自己墓地不存在至少1张可除外的魔法卡，则效果不能发动（chk==0时返回false）。
	if chk==0 then return Duel.IsExistingMatchingCard(c47829960.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 将本次连锁的操作信息登记为“除外”分类，目标为自己墓地的卡，登记数量为1，供其他卡牌效果（如星尘龙等）的发动判定使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理：从自己墓地选择1~2张不受王家长眠之谷影响的魔法卡并除外；若除外成功且此卡仍表侧表示且与效果关联，则此卡的攻击力上升除外数量×300点，持续到对方回合结束。
function c47829960.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家tp显示选择卡片的提示消息，内容为“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1~2张满足过滤条件（魔法卡、可除外、且不受王家长眠之谷影响）的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c47829960.filter),tp,LOCATION_GRAVE,0,1,2,nil)
	if #g>0 then
		-- 将选中的卡以表侧表示除外（因为效果除外），返回实际被除外的数量，用于计算攻击力上升值。
		local count=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		local c=e:GetHandler()
		if count>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
			-- 以此效果每除外1张卡，这张卡的攻击力就上升300点直到对方回合结束。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(count*300)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
			c:RegisterEffect(e1)
		end
	end
end
