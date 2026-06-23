--律導のヴァルモニカ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「异响鸣」怪兽卡存在的场合，从以下效果选1个适用。自己场上有「异响鸣」连接怪兽存在的场合，可以选两方适用。
-- ●自己回复500基本分。那之后，可以把场上1张魔法·陷阱卡破坏。
-- ●自己受到500伤害。那之后，可以让场上1只怪兽回到手卡。
local s,id,o=GetID()
-- 注册卡牌效果，设置为自由时点发动，限制1回合1次发动，条件为己方场上存在异响鸣怪兽，效果为激活状态
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断场上是否存在「异响鸣」怪兽（包括怪兽卡类型）
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a3) and c:GetOriginalType()&TYPE_MONSTER>0
end
-- 判断条件函数，检查己方场上是否存在「异响鸣」怪兽
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在满足cfilter条件的卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤函数，用于判断场上是否存在「异响鸣」连接怪兽
function s.afilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a3) and c:IsType(TYPE_LINK)
end
-- 效果发动函数，处理选择效果和执行效果内容
function s.activate(e,tp,eg,ep,ev,re,r,rp,op)
	if op==nil and not s.condition(e,tp) then return end
	if op==nil then
		-- 检查己方场上是否存在「异响鸣」连接怪兽
		local chk=Duel.IsExistingMatchingCard(s.afilter,tp,LOCATION_MZONE,0,1,nil)
		-- 让玩家从选项中选择一个效果
		op=aux.SelectFromOptions(tp,
			{true,aux.Stringid(id,1)},  --"自己回复500基本分"
			{true,aux.Stringid(id,2)},  --"自己受到500伤害"
			{chk,aux.Stringid(id,3)})  --"选两方适用"
	end
	-- 如果选择效果1（回复500LP）且成功回复，则执行后续破坏魔法陷阱卡操作
	if op&1>0 and Duel.Recover(tp,500,REASON_EFFECT)>0 then
		-- 获取场上所有魔法陷阱卡的Group
		local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e),TYPE_SPELL+TYPE_TRAP)
		-- 如果存在魔法陷阱卡且玩家选择破坏，则执行破坏操作
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否把场上1张魔法·陷阱卡破坏？"
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 显示被选中的卡
			Duel.HintSelection(sg)
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 以效果原因破坏选中的卡
			Duel.Destroy(sg,REASON_EFFECT)
		end
		-- 如果选择效果3（两方适用），则中断当前效果处理
		if op==3 then Duel.BreakEffect() end
	end
	-- 如果选择效果2（受到500伤害）且成功造成伤害，则执行后续返回手卡操作
	if op&2>0 and Duel.Damage(tp,500,REASON_EFFECT)>0 then
		-- 获取场上所有可送回手卡的怪兽Group
		local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 如果存在可送回手卡的怪兽且玩家选择返回，则执行送回手卡操作
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then  --"是否让场上1只怪兽回到手卡？"
			-- 提示玩家选择要返回手卡的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 显示被选中的卡
			Duel.HintSelection(sg)
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 以效果原因将选中的卡送回手卡
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end
	end
end
