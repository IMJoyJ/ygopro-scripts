--魔導書整理
-- 效果：
-- 翻开自己卡组最上面3张卡，将其按喜欢的顺序放回。对方不能确认这些卡。
function c96677818.initial_effect(c)
	-- 翻开自己卡组最上面3张卡，将其按喜欢的顺序放回。对方不能确认这些卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c96677818.target)
	e1:SetOperation(c96677818.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动的目标与条件检查函数
function c96677818.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己卡组的卡片数量是否在3张以上
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
end
-- 定义效果处理的执行函数
function c96677818.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 令己方玩家确认并重新排列自己卡组最上方的3张卡片
	Duel.SortDecktop(tp,tp,3)
end
