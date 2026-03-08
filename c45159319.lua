--モアイ迎撃砲
-- 效果：
-- 这张卡1个回合1次可以变成里侧守备表示。
function c45159319.initial_effect(c)
	-- 这张卡1个回合1次可以变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45159319,0))  --"变成里侧守备表示"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c45159319.target)
	e1:SetOperation(c45159319.operation)
	c:RegisterEffect(e1)
end
-- 检查效果是否可以发动，条件为该卡可以转为里侧表示且本回合未发动过此效果
function c45159319.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(45159319)==0 end
	c:RegisterFlagEffect(45159319,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置连锁操作信息，表示该效果会改变场上1张卡的表示形式为里侧守备表示
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 效果处理函数，判断效果是否有效且该卡是否为表侧表示，若是则将其变为里侧守备表示
function c45159319.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将目标怪兽变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
