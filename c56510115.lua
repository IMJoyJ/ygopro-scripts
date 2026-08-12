--ドレミコード・シンフォニア
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己的额外卡组的表侧表示的「七音服」灵摆怪兽种类的以下效果适用。
-- ●3种类以上：这个回合，自己场上的「七音服」灵摆怪兽的攻击力上升自身的灵摆刻度×300。
-- ●5种类以上：可以选对方场上1张卡破坏。自己的灵摆区域有奇数的灵摆刻度存在的场合，再让自己从卡组抽1张。
-- ●7种类以上：可以从额外卡组把1只「大钢琴之七音服」怪兽特殊召唤。
function c56510115.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己的额外卡组的表侧表示的「七音服」灵摆怪兽种类的以下效果适用。●3种类以上：这个回合，自己场上的「七音服」灵摆怪兽的攻击力上升自身的灵摆刻度×300。●5种类以上：可以选对方场上1张卡破坏。自己的灵摆区域有奇数的灵摆刻度存在的场合，再让自己从卡组抽1张。●7种类以上：可以从额外卡组把1只「大钢琴之七音服」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,56510115+EFFECT_COUNT_CODE_OATH)
	-- 设置效果发动的条件为不在伤害计算后（配合伤害步骤发动限制）
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c56510115.target)
	e1:SetOperation(c56510115.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己额外卡组表侧表示的「七音服」灵摆怪兽
function c56510115.cfilter(c)
	return c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM) and c:IsFaceup()
end
-- 过滤条件：灵摆刻度为奇数且大于0的卡
function c56510115.slfilter(c)
	local scal=c:GetCurrentScale()
	return scal>0 and scal%2==1
end
-- 过滤条件：额外卡组中可以特殊召唤的「大钢琴之七音服」怪兽，且额外怪兽区域有空位
function c56510115.spfilter(c,e,tp)
	-- 检查卡片是否为「大钢琴之七音服」怪兽、是否可以特殊召唤，以及额外卡组特殊召唤的空间是否足够
	return c:IsSetCard(0x1162) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果发动的靶向/可行性检查：检查额外卡组表侧表示的「七音服」灵摆怪兽是否在3种类以上
function c56510115.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己额外卡组表侧表示的所有「七音服」灵摆怪兽
		local g=Duel.GetMatchingGroup(c56510115.cfilter,tp,LOCATION_EXTRA,0,nil)
		local ct=g:GetClassCount(Card.GetCode)
		return ct>=3
	end
end
-- 效果处理：根据自己额外卡组表侧表示的「七音服」灵摆怪兽种类数量，依次适用对应的效果
function c56510115.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己额外卡组表侧表示的所有「七音服」灵摆怪兽
	local g=Duel.GetMatchingGroup(c56510115.cfilter,tp,LOCATION_EXTRA,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	-- 检查自己的灵摆区域是否存在奇数灵摆刻度的卡，且自己是否可以抽卡
	local draw=Duel.IsExistingMatchingCard(c56510115.slfilter,tp,LOCATION_PZONE,0,1,nil) and Duel.IsPlayerCanDraw(tp,1)
	local b1=ct>=3
	-- 检查种类是否在5种以上，且对方场上是否存在可以破坏的卡
	local b2=ct>=5 and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil)
	-- 检查种类是否在7种以上，且自己额外卡组是否存在可以特殊召唤的「大钢琴之七音服」怪兽
	local b3=ct>=7 and Duel.IsExistingMatchingCard(c56510115.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	if b1 then
		-- ●3种类以上：这个回合，自己场上的「七音服」灵摆怪兽的攻击力上升自身的灵摆刻度×300。●5种类以上：可以选对方场上1张卡破坏。自己的灵摆区域有奇数的灵摆刻度存在的场合，再让自己从卡组抽1张。●7种类以上：可以从额外卡组把1只「大钢琴之七音服」怪兽特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(c56510115.atktg)
		e1:SetValue(c56510115.atkval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册使自己场上怪兽攻击力上升的全局效果
		Duel.RegisterEffect(e1,tp)
	end
	-- 若满足5种类以上的条件，询问玩家是否发动破坏对方场上卡片的效果
	if b2 and Duel.SelectYesNo(tp,aux.Stringid(56510115,1)) then  --"是否选对方场上1张卡破坏？"
		-- 中断当前效果，使后续的破坏处理与前面的攻击力上升不视为同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 玩家选择对方场上的1张卡
		local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		-- 选中卡片并向双方玩家展示
		Duel.HintSelection(dg)
		-- 成功破坏选中的卡片后，若满足抽卡条件，则继续处理抽卡效果
		if #dg>0 and Duel.Destroy(dg,REASON_EFFECT)>0 and draw then
			-- 中断当前效果，使抽卡与破坏不视为同时处理
			Duel.BreakEffect()
			-- 玩家从卡组抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
	-- 若满足7种类以上的条件，询问玩家是否从额外卡组特殊召唤怪兽
	if b3 and Duel.SelectYesNo(tp,aux.Stringid(56510115,2)) then  --"是否从额外卡组特殊召唤？"
		-- 中断当前效果，使特殊召唤与前面的处理不视为同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从额外卡组选择1只满足条件的「大钢琴之七音服」怪兽
		local sg=Duel.SelectMatchingCard(tp,c56510115.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if #sg==0 then return end
		-- 将选中的怪兽以表侧表示特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 攻击力上升效果的适用对象过滤：自己场上的「七音服」灵摆怪兽
function c56510115.atktg(e,c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x162)
end
-- 攻击力上升数值计算：自身的灵摆刻度×300
function c56510115.atkval(e,c)
	return c:GetCurrentScale()*300
end
