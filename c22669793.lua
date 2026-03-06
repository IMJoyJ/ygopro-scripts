--貴き黄金郷のエルドリクシル
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：可以支付800基本分，从以下效果选择1个发动。
-- ●这张卡变成通常怪兽（不死族·光·10星·攻1500/守2800）在怪兽区域特殊召唤（也当作陷阱卡使用）。自己场上有「黄金卿 黄金国巫妖」存在的场合，可以再让场上1只怪兽回到手卡。
-- ●自己的除外状态的1张「黄金乡」魔法·陷阱卡或「黄金国永生药」魔法·陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 注册卡片效果，包括发动条件和处理函数
function s.initial_effect(c)
	-- 记录该卡与「黄金卿 黄金国巫妖」的卡名关联
	aux.AddCodeList(c,95440946)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 发动时选择1个效果发动
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"发动"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
-- 支付800基本分作为发动cost
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付800基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 支付800基本分
	Duel.PayLPCost(tp,800)
end
-- 定义过滤函数，用于检索场上的「黄金乡」魔法·陷阱卡
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x143,0x2142) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 设置效果的发动条件，判断是否可以发动
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有空位可以特殊召唤怪兽
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家是否可以特殊召唤该卡为通常怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_NORMAL_TRAP_MONSTER,1500,2800,10,RACE_ZOMBIE,ATTRIBUTE_LIGHT)
	-- 判断玩家的除外区是否有符合条件的魔法·陷阱卡
	local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil)
	if chk==0 then return b1 or b2 end
	-- 让玩家选择发动效果的选项
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1)},  --"特殊召唤"
		{b2,aux.Stringid(id,2)})  --"盖放"
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
		-- 设置操作信息，确定特殊召唤的卡
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_SSET)
	end
end
-- 定义过滤函数，用于检索场上的「黄金卿 黄金国巫妖」
function s.filter(c)
	return c:IsFaceup() and c:IsCode(95440946)
end
-- 处理效果的发动，根据选择的选项执行不同操作
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==1 then
		c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP)
		-- 特殊召唤该卡为通常怪兽
		if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil)
			-- 判断玩家场上是否有怪兽可以送回手牌
			and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
			-- 询问玩家是否让怪兽回到手牌
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否让怪兽回到手卡？"
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
			-- 提示玩家选择要送回手牌的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
			-- 选择场上1只可以送回手牌的怪兽
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
			-- 显示选中的怪兽被选为对象的动画效果
			Duel.HintSelection(g)
			local tc=g:GetFirst()
			if tc then
				-- 将选中的怪兽送回手牌
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
			end
		end
	elseif op==2 then
		-- 提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 选择除外区1张符合条件的魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
		if #g>0 then
			-- 将选中的卡在自己场上盖放
			Duel.SSet(tp,g)
		end
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	end
end
