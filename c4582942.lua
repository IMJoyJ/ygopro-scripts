--律導のヴァルモニカ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「异响鸣」怪兽卡存在的场合，从以下效果选1个适用。自己场上有「异响鸣」连接怪兽存在的场合，可以选两方适用。
-- ●自己回复500基本分。那之后，可以把场上1张魔法·陷阱卡破坏。
-- ●自己受到500伤害。那之后，可以让场上1只怪兽回到手卡。
local s,id,o=GetID()
-- 定义这张卡的效果初始化函数，创建并注册该卡的①效果：在自由时点发动，1回合1次，满足场上存在「异响鸣」怪兽卡的条件时可发动，效果涉及回复/破坏/伤害/回手牌。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「异响鸣」怪兽卡存在的场合，从以下效果选1个适用。自己场上有「异响鸣」连接怪兽存在的场合，可以选两方适用。
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
-- 卡牌过滤条件：表侧表示、卡名含有「异响鸣」字段、且原本类型为怪兽卡的卡。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a3) and c:GetOriginalType()&TYPE_MONSTER>0
end
-- 发动条件判定函数，检查自己场上（前场/后场）是否存在至少1张满足s.cfilter条件的「异响鸣」怪兽卡。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「异响鸣」怪兽卡，存在则满足发动条件。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 卡牌过滤条件：表侧表示、含有「异响鸣」字段、且为连接怪兽的卡。
function s.afilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a3) and c:IsType(TYPE_LINK)
end
-- 定义效果发动后的处理：若未指定op，先检查「异响鸣」连接怪兽是否存在，再让玩家选择回复500LP、受到500伤害或两方适用；随后按位标记依次结算所选效果，回复成功则可选破坏场上1张魔法·陷阱卡，伤害成功则可选让场上1只怪兽回手牌；若选择两方适用，则在两段效果之间用BreakEffect断开时点。
function s.activate(e,tp,eg,ep,ev,re,r,rp,op)
	if op==nil and not s.condition(e,tp) then return end
	if op==nil then
		-- 检查自己怪兽区域是否存在至少1只表侧表示的「异响鸣」连接怪兽，用于判断能否选择“两方适用”选项。
		local chk=Duel.IsExistingMatchingCard(s.afilter,tp,LOCATION_MZONE,0,1,nil)
		-- 调用多选一选项选择函数，让玩家从“自己回复500基本分”“自己受到500伤害”“选两方适用”中选择要适用的效果，返回值op以位标记表示所选结果。
		op=aux.SelectFromOptions(tp,
			{true,aux.Stringid(id,1)},  --"自己回复500基本分"
			{true,aux.Stringid(id,2)},  --"自己受到500伤害"
			{chk,aux.Stringid(id,3)})  --"选两方适用"
	end
	-- 如果玩家选择了“回复500基本分”（位1被置位），尝试让自己回复500LP；只有实际回复成功才进入后续破坏处理。
	if op&1>0 and Duel.Recover(tp,500,REASON_EFFECT)>0 then
		-- 获取双方场上除这张卡以外的所有魔法·陷阱卡，作为可被破坏的对象集合。
		local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e),TYPE_SPELL+TYPE_TRAP)
		-- 若存在可选择的魔法·陷阱卡，则询问玩家“是否把场上1张魔法·陷阱卡破坏？”；玩家选择“是”才继续。
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否把场上1张魔法·陷阱卡破坏？"
			-- 向玩家发送“请选择要破坏的卡”的选择提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 为选择的对象卡显示选中动画，并记录其成为效果对象。
			Duel.HintSelection(sg)
			-- 中断当前效果处理，使此后的破坏效果视为在不同的时点处理（错开时点）。
			Duel.BreakEffect()
			-- 以效果原因把选择的魔法·陷阱卡破坏。
			Duel.Destroy(sg,REASON_EFFECT)
		end
		-- 如果玩家选择的是“选两方适用”（op等于3），则在回复效果段结束后再次中断时点，使接下来的伤害效果独立处理。
		if op==3 then Duel.BreakEffect() end
	end
	-- 如果玩家选择了“自己受到500伤害”（位2被置位），尝试让自己受到500伤害；只有实际造成伤害才进入后续回手处理。
	if op&2>0 and Duel.Damage(tp,500,REASON_EFFECT)>0 then
		-- 获取双方场上所有可以被返回手卡的怪兽，作为回手对象候选。
		local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 若存在可回手的怪兽，则询问玩家“是否让场上1只怪兽回到手卡？”；玩家选择“是”才继续。
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then  --"是否让场上1只怪兽回到手卡？"
			-- 向玩家发送“请选择要返回手牌的卡”的选择提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 为选择的对象卡显示选中动画，并记录其成为效果对象。
			Duel.HintSelection(sg)
			-- 中断当前效果处理，使此后的回手效果视为在不同的时点处理。
			Duel.BreakEffect()
			-- 以效果原因把选择的怪兽送回持有者手卡。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end
	end
end
