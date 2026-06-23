--コザッキーの研究成果
-- 效果：
-- 自己卡组最上面3张卡确认，并且把那些卡按照自己的意愿交换顺序放回卡组最上面。
function c49998907.initial_effect(c)
	-- 卡片效果初始化，设置为发动时点的魔法卡效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c49998907.target)
	e1:SetOperation(c49998907.activate)
	c:RegisterEffect(e1)
end
-- 效果的发动条件判断函数
function c49998907.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己卡组最上面是否有至少3张卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
end
-- 效果发动时执行的处理函数
function c49998907.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家将自己卡组最上方3张卡进行重新排序
	Duel.SortDecktop(tp,tp,3)
end
