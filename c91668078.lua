--雪沓の 跡追うひとつ またひとつ
-- 效果：
-- ①：「踩着雪鞋印 顺着足迹追呀追 一个接一个」以外的卡被送去墓地的场合才能发动。自己墓地最多5张卡里侧除外。那之后，自己的除外状态的里侧的卡7张以上存在的场合，对方尽可能选自身墓地最多5张卡里侧除外。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- ①：「踩着雪鞋印 顺着足迹追呀追 一个接一个」以外的卡被送去墓地的场合才能发动。自己墓地最多5张卡里侧除外。那之后，自己的除外状态的里侧的卡7张以上存在的场合，对方尽可能选自身墓地最多5张卡里侧除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：非同名卡。
function s.cfilter(c)
	return not c:IsCode(id)
end
-- 检查是否有非同名卡被送去墓地，作为效果发动条件。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
-- 效果发动时的目标选择与检测函数。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己墓地是否存在至少1张可以里侧除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,nil,tp,POS_FACEDOWN) end
	-- 获取自己墓地中所有可以里侧除外的卡片组。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,nil,tp,POS_FACEDOWN)
	-- 设置操作信息为除外自己墓地的卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理函数，执行除外自己墓地的卡，并根据条件让对方里侧除外其墓地的卡。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地1到5张可以里侧除外的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,5,nil,tp,POS_FACEDOWN)
	if g:GetCount()>0 then
		-- 为选中的卡片显示被选择的动画效果。
		Duel.HintSelection(g)
		-- 将选中的卡里侧除外，并判断是否成功除外。
		if Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)~=0
			-- 判断自己除外状态的里侧卡片是否在7张以上。
			and Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_REMOVED,0,nil)>=7
			-- 判断对方墓地是否存在可以里侧除外的卡。
			and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil,tp,POS_FACEDOWN) then
			-- 中断当前效果，使后续处理不与前面的除外同时进行。
			Duel.BreakEffect()
			-- 获取对方墓地中可以里侧除外的卡片数量。
			local ct=Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil,POS_FACEDOWN)
			if ct>5 then ct=5 end
			-- 提示对方玩家选择要除外的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			-- 让对方玩家选择自身墓地中尽可能多的卡（最多5张）里侧除外。
			local rg=Duel.SelectMatchingCard(1-tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,ct,ct,nil,POS_FACEDOWN)
			if rg:GetCount()>0 then
				-- 为对方选中的卡片显示被选择的动画效果。
				Duel.HintSelection(rg)
				-- 将对方选中的卡里侧除外。
				Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
			end
		end
	end
end
