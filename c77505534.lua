--堕ち影の蠢き
-- 效果：
-- ①：从卡组把1张「影依」卡送去墓地。那之后，可以选自己场上的里侧守备表示的「影依」怪兽任意数量变成表侧守备表示。
function c77505534.initial_effect(c)
	-- ①：从卡组把1张「影依」卡送去墓地。那之后，可以选自己场上的里侧守备表示的「影依」怪兽任意数量变成表侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x11e8)
	e1:SetTarget(c77505534.target)
	e1:SetOperation(c77505534.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡组中可送去墓地的「影依」卡
function c77505534.filter(c)
	return c:IsSetCard(0x9d) and c:IsAbleToGrave()
end
-- 效果发动的准备与操作信息注册
function c77505534.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在至少1张可以送去墓地的「影依」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c77505534.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：自己场上里侧表示的「影依」怪兽
function c77505534.posfilter(c)
	return c:IsFacedown() and c:IsSetCard(0x9d)
end
-- 效果处理的核心逻辑
function c77505534.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张「影依」卡
	local g=Duel.SelectMatchingCard(tp,c77505534.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 若成功将选中的卡送去墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
		-- 获取自己场上所有里侧守备表示的「影依」怪兽
		local tg=Duel.GetMatchingGroup(c77505534.posfilter,tp,LOCATION_MZONE,0,nil)
		-- 若存在符合条件的怪兽，询问玩家是否要改变其表示形式
		if tg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(77505534,0)) then  --"是否要选择里侧守备表示的「影依」怪兽变成表侧守备表示？"
			-- 中断当前效果，使后续的改变表示形式处理不与送去墓地同时进行（会造成错时点）
			Duel.BreakEffect()
			-- 提示玩家选择要改变表示形式的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
			local sg=tg:Select(tp,1,7,nil)
			-- 将选中的怪兽变成表侧守备表示
			Duel.ChangePosition(sg,POS_FACEUP_DEFENSE)
		end
	end
end
