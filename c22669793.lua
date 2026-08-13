--貴き黄金郷のエルドリクシル
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：可以支付800基本分，从以下效果选择1个发动。
-- ●这张卡变成通常怪兽（不死族·光·10星·攻1500/守2800）在怪兽区域特殊召唤（也当作陷阱卡使用）。自己场上有「黄金卿 黄金国巫妖」存在的场合，可以再让场上1只怪兽回到手卡。
-- ●自己的除外状态的1张「黄金乡」魔法·陷阱卡或「黄金国永生药」魔法·陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 注册卡片效果：e1为使这张魔陷能够发动的空效果（永续/场地通用）；e2为①效果，支付800LP并选择两个分支之一发动，且1回合1次。
function s.initial_effect(c)
	-- 将「黄金卿 黄金国巫妖」的卡号记载到这张卡上，使其被视为记载有该卡名，以便触发相关联动效果。
	aux.AddCodeList(c,95440946)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 该行对应效果原文：“这个卡名的①的效果1回合只能使用1次。①：可以支付800基本分，从以下效果选择1个发动。”
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
-- cost函数：效果发动前检查并支付800基本分作为代价，若不能支付则不能发动。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在合法性判定阶段，检查玩家是否能支付800基本分。
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 实际支付800基本分。
	Duel.PayLPCost(tp,800)
end
-- 定义可盖放的卡牌筛选条件：除外区表侧表示、属于「黄金乡」或「黄金国永生药」系列、为魔法·陷阱卡且可以被盖放。
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x143,0x2142) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- target函数：效果发动时检测两个选项是否可行：①主怪兽区有空位且可特殊召唤本卡作为陷阱怪兽；②除外区存在可盖放的「黄金乡」/「黄金国永生药」魔陷。然后让玩家选择要执行的分支，并记录到label，同时按分支设置类别和操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空位，用于判定能否特殊召唤怪兽。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己能否以陷阱怪兽形式特殊召唤参数对应的怪兽（光/不死/10星/攻1500/守2800）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_NORMAL_TRAP_MONSTER,1500,2800,10,RACE_ZOMBIE,ATTRIBUTE_LIGHT)
	-- 检查除外区是否存在满足thfilter条件的卡牌，用于判定能否选择盖放分支。
	local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil)
	if chk==0 then return b1 or b2 end
	-- 让玩家在可选分支中进行选择（特殊召唤或盖放），对应原效果“从以下效果选择1个发动”。
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1)},  --"特殊召唤"
		{b2,aux.Stringid(id,2)})  --"盖放"
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
		-- 设置操作信息，将本次处理类型标记为特殊召唤本卡1张，供其他卡参照（如星尘龙等）。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_SSET)
	end
end
-- 定义筛选条件：场上表侧表示且卡名为「黄金卿 黄金国巫妖」的怪兽。
function s.filter(c)
	return c:IsFaceup() and c:IsCode(95440946)
end
-- operation函数：根据玩家选择执行效果。若选择①：将本卡变为通常陷阱怪兽并特殊召唤；成功后若自己场上有「黄金卿 黄金国巫妖」且场上存在可回手怪兽，询问玩家是否让1只怪兽返回手卡，并处理回手。若选择②：从除外区选择1张满足条件的「黄金乡」/「黄金国永生药」魔法陷阱卡在自己场上盖放。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==1 then
		c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP)
		-- 本卡特殊召唤成功，且自己场上有表侧表示的「黄金卿 黄金国巫妖」存在。
		if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil)
			-- 双方主要怪兽区存在至少1只能够加入手卡的怪兽。
			and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
			-- 询问玩家是否要让自己场上的怪兽返回手卡。
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否让怪兽回到手卡？"
			-- 中断当前效果处理，使后续回手处理作为新的连锁处理，避免错时点。
			Duel.BreakEffect()
			-- 提示玩家选择要返回手牌的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
			-- 从双方主要怪兽区选择1只可以加入手卡的怪兽。
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
			-- 显示所选择卡作为对象的动画并记录对象。
			Duel.HintSelection(g)
			local tc=g:GetFirst()
			if tc then
				-- 将选择的怪兽返回持有者手卡。
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
			end
		end
	elseif op==2 then
		-- 提示玩家选择要盖放的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从除外区选择1张满足thfilter条件的卡。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
		if #g>0 then
			-- 将选择的卡盖放到自己场上。
			Duel.SSet(tp,g)
		end
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	end
end
