--コザッキーの研究成果
-- 效果：
-- 自己卡组最上面3张卡确认，并且把那些卡按照自己的意愿交换顺序放回卡组最上面。
function c49998907.initial_effect(c)
	-- 自己卡组最上面3张卡确认，并且把那些卡按照自己的意愿交换顺序放回卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c49998907.target)
	e1:SetOperation(c49998907.activate)
	c:RegisterEffect(e1)
end
-- 效果发动前的条件检测：确认自己卡组是否存在至少3张卡，以决定效果是否满足发动条件。
function c49998907.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动条件检查阶段（chk==0）返回自己卡组最上面的卡数量是否大于2（即至少有3张），作为效果可否发动的判定。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
end
-- 效果处理阶段的操作：对自己卡组最上方3张卡进行确认并按自己的意愿重新排列顺序后放回。
function c49998907.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家tp对自己卡组最上方3张卡进行排序（最先选中的卡放在最上面），从而完成确认并交换顺序放回卡组最上面的操作。
	Duel.SortDecktop(tp,tp,3)
end
