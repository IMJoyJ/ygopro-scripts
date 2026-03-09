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
-- 过滤函数，用于筛选可被除外的魔法卡
function c47829960.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemove()
end
-- 效果的发动条件判断，检查自己墓地是否存在至少1张魔法卡
function c47829960.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1张魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c47829960.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁操作信息，表示将要除外魔法卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理函数，执行除外魔法卡并提升攻击力的操作
function c47829960.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1至2张满足条件的魔法卡进行除外
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c47829960.filter),tp,LOCATION_GRAVE,0,1,2,nil)
	if #g>0 then
		-- 将选中的魔法卡从墓地除外
		local count=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		local c=e:GetHandler()
		if count>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
			-- 每除外1张卡，这张卡的攻击力就上升300点直到对方回合结束
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(count*300)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
			c:RegisterEffect(e1)
		end
	end
end
