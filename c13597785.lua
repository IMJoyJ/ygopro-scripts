--耀聖の花詩ルキナ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②③的效果1回合各能使用1次。
-- ①：这张卡可以从手卡往自己的中央的主要怪兽区域特殊召唤。
-- ②：自己主要阶段才能发动。从卡组把「耀圣之花诗 卢西娜」以外的1只「耀圣」怪兽加入手卡。
-- ③：对方回合才能发动。自己的主要怪兽区域的这张卡和中央的怪兽的位置交换。那之后，可以让对方场上1只6星以下的怪兽回到手卡。
local s,id,o=GetID()
-- 为这张卡注册三个效果：①以规则特殊召唤效果（EFFECT_SPSUMMON_PROC）使此卡可从手卡特殊召唤到己方中央主要怪兽区，并设置该召唤1回合仅1次；②起动效果，在己方主要阶段从卡组检索1只「耀圣」怪兽加入手卡；③诱发即时效果，在对方回合可与己方中央主要怪兽区的怪兽交换位置，并可选对方场上1只6星以下怪兽回手。各效果分别设置了发动次数限制。
function s.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②③的效果1回合各能使用1次。①：这张卡可以从手卡往自己的中央的主要怪兽区域特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetValue(s.spval)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从卡组把「耀圣之花诗 卢西娜」以外的1只「耀圣」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"检索怪兽"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：对方回合才能发动。自己的主要怪兽区域的这张卡和中央的怪兽的位置交换。那之后，可以让对方场上1只6星以下的怪兽回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"交换位置"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e3:SetCondition(s.chcon)
	e3:SetTarget(s.chtg)
	e3:SetOperation(s.chop)
	c:RegisterEffect(e3)
end
-- s.spcon：特殊召唤规则效果的条件判断。若c为nil则返回true表示允许规则召唤；否则检查控制者tp的主要怪兽区域中是否存在可用的中央格子（zone掩码0x4）用于此卡特殊召唤。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查tp的主要怪兽区域是否有空余的中央区域（zone掩码0x4），只有存在空位时才能发动①的规则特殊召唤。
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,0x4)>0
end
-- s.spval：设定规则特殊召唤的附加参数，返回0,0x4，说明召唤到中央主要怪兽区（0x4），表示形式使用默认值（0）。
function s.spval(e,c)
	return 0,0x4
end
-- s.thfilter：检索过滤条件——不是本卡（id），属于「耀圣」系列（0x1d8），是怪兽卡，且能够加入手卡。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1d8) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- s.thtg：②效果的发动条件与操作信息设置。chk==0时检查卡组是否存在符合条件的「耀圣」怪兽；通过后将本次操作信息登记为从卡组将1张卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查：卡组中存在至少1张满足s.thfilter条件的「耀圣」怪兽，否则②效果无法发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：本效果会从卡组把1张卡加入手卡（目标不取对象，数量1，检索来源为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- s.thop：②效果的处理。提示玩家选择要加入手卡的卡，从卡组选出1张符合条件的「耀圣」怪兽，加入持有者手卡，并向对方展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示文字为“请选择要加入手卡的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足s.thfilter条件的「耀圣」怪兽（不能选择本卡）。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入其持有者的手卡，原因记为REASON_EFFECT。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡，确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- s.chcon：③效果的发动条件判定——此卡位于己方主要怪兽区域（sequence<5），且当前为对方回合（Duel.GetTurnPlayer()==1-tp）。
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断此卡在主要怪兽区（sequence<5）且现在是对方回合，满足③的发动条件。
	return e:GetHandler():GetSequence()<5 and Duel.GetTurnPlayer()==1-tp
end
-- s.chfilter：筛选位于中央主要怪兽区（sequence==2）的怪兽，用于确定交换对象。
function s.chfilter(c)
	return c:GetSequence()==2
end
-- s.chtg：③效果的发动合法性检查。chk==0时确认己方主要怪兽区域存在位于中央区域的怪兽（排除此卡自身），有则可发动。
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查己方场上是否存在位于中央主要怪兽区（sequence==2）的怪兽（不能是此卡自身），作为位置交换的对象。
	if chk==0 then return Duel.IsExistingMatchingCard(s.chfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
end
-- s.rthfilter：回手过滤条件——对方场上的表侧表示怪兽、6星以下、且能够加入手卡。
function s.rthfilter(c)
	return c:IsFaceup() and c:IsAbleToHand() and c:IsLevelBelow(6)
end
-- s.chop：③效果的处理。首先确认此卡仍与连锁相关且控制权未变，且位于主要怪兽区且不在中央区；然后获取中央区的怪兽，若存在则交换位置；若交换成功，则询问是否追加回手效果；选择是则中断连锁，选择对方1只符合条件的怪兽送回手卡。
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cs=c:GetSequence()
	if not c:IsRelateToChain() or not c:IsControler(tp) or cs>4 or cs==2 then return end
	-- 获取己方主要怪兽区域中位于中央区的怪兽（通常为1只）。
	local g=Duel.GetMatchingGroup(s.chfilter,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()==1 then
		local tc=g:GetFirst()
		-- 将此卡与中央区的怪兽交换区域位置。
		Duel.SwapSequence(c,tc)
		if c:GetSequence()==cs then return end
		-- 检查对方场上是否存在满足s.rthfilter的怪兽（表侧·6星以下·可回手）。
		if Duel.IsExistingMatchingCard(s.rthfilter,tp,0,LOCATION_MZONE,1,nil)
			-- 询问玩家是否发动“那之后”的效果，选择是则进行回手处理。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否让怪兽回到手卡？"
			-- Duel.BreakEffect()：中断当前效果，使后续回手处理与之前的交换位置不在同一时点处理，避免时点被占用/联动。
			Duel.BreakEffect()
			-- 提示玩家选择要返回手牌的怪兽，显示文字“请选择要返回手牌的卡”。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
			-- 选择对方场上1只满足s.rthfilter条件的怪兽作为回手对象。
			local rg=Duel.SelectMatchingCard(tp,s.rthfilter,tp,0,LOCATION_MZONE,1,1,nil)
			-- 为选中的怪兽显示选中动画，并将其记录为效果处理的对象。
			Duel.HintSelection(rg)
			-- 将选中的对方怪兽加入其持有者手卡，原因记为REASON_EFFECT。
			Duel.SendtoHand(rg,nil,REASON_EFFECT)
		end
	end
end
