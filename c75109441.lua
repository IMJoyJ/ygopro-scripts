--半蛇人サクズィー
-- 效果：
-- 这张卡1回合只有1次可以变成里侧守备表示。这张卡反转时，对方场上盖放的魔法·陷阱卡全部翻开，确认后回复原状。
function c75109441.initial_effect(c)
	-- 这张卡1回合只有1次可以变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75109441,0))  --"变成里侧守备"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c75109441.target)
	e1:SetOperation(c75109441.operation)
	c:RegisterEffect(e1)
	-- 这张卡反转时，对方场上盖放的魔法·陷阱卡全部翻开，确认后回复原状。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75109441,1))  --"确认盖卡"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_FLIP)
	e2:SetOperation(c75109441.cfop)
	c:RegisterEffect(e2)
end
-- 检查自身是否能转为里侧守备表示且本回合未发动过该效果，注册回合内限一次的标识，并设置改变表示形式的操作信息
function c75109441.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(75109441)==0 end
	c:RegisterFlagEffect(75109441,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置当前连锁的操作信息为将1张自身卡片改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 若自身在场且为表侧表示，则将自身转为里侧守备表示
function c75109441.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身改变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 获取对方场上盖放的魔法·陷阱卡，若存在则翻开给自身玩家确认
function c75109441.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 过滤获取对方场上魔法与陷阱区域所有里侧表示的卡片
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_SZONE,nil)
	if g:GetCount()>0 then
		-- 将指定的卡片组翻开给自身玩家确认，确认后回复原状
		Duel.ConfirmCards(tp,g)
	end
end
