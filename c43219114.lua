--白き龍の威光
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：选自己的手卡·场上（表侧表示）·墓地最多3只「青眼白龙」，给双方确认。那之后，确认数量的对方场上的卡破坏。
-- ②：把墓地的这张卡除外才能发动。等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上的「青眼白龙」解放，从手卡把1只仪式怪兽仪式召唤。
local s,id,o=GetID()
-- 注册卡片效果，包括①破坏效果和②仪式召唤效果
function s.initial_effect(c)
	-- 记录此卡与「青眼白龙」的关联
	aux.AddCodeList(c,89631139)
	-- ①：选自己的手卡·场上（表侧表示）·墓地最多3只「青眼白龙」，给双方确认。那之后，确认数量的对方场上的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 为卡片添加仪式召唤效果，要求素材等级合计等于仪式怪兽等级
	local e2=aux.AddRitualProcEqual2(c,nil,nil,nil,s.mfilter,true)
	e2:SetDescription(aux.Stringid(id,1))  --"仪式召唤"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置仪式召唤效果的发动费用为将此卡除外
	e2:SetCost(aux.bfgcost)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否为表侧表示的「青眼白龙」
function s.chkfilter(c)
	return c:IsFaceupEx() and c:IsCode(89631139)
end
-- 效果发动时的检查函数，判断是否满足发动条件
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡·墓地·场上的「青眼白龙」是否存在
	if chk==0 then return Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,1,nil)
		-- 检查对方场上的卡是否存在
		and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息，指定破坏效果的目标为对方场上的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果发动时的处理函数，执行破坏效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡
	local dg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	-- 获取自己手卡·墓地·场上的「青眼白龙」
	local g=Duel.GetMatchingGroup(s.chkfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,nil)
	local ct=math.min(3,math.min(dg:GetCount(),g:GetCount()))
	if ct==0 then return end
	-- 提示玩家选择要确认的「青眼白龙」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local rg=g:Select(tp,1,ct,nil)
	if rg:GetCount()>0 then
		local hg=rg:Filter(Card.IsLocation,nil,LOCATION_HAND)
		local og=rg-hg
		-- 向对方确认玩家选择的「青眼白龙」
		Duel.ConfirmCards(1-tp,hg)
		-- 显示被选为对象的「青眼白龙」
		Duel.HintSelection(og)
		if hg:GetCount()>=1 then
			-- 洗切自己的手牌
			Duel.ShuffleHand(tp)
		end
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=dg:Select(tp,rg:GetCount(),rg:GetCount(),nil)
		-- 显示被选为对象的卡
		Duel.HintSelection(sg)
		-- 将选中的卡破坏
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
-- 仪式召唤时的过滤函数，用于判断是否为「青眼白龙」
function s.mfilter(c,e,tp,chk)
	return (not chk or c~=e:GetHandler()) and c:IsCode(89631139)
end
