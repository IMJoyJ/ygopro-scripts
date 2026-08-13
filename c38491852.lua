--ヴァルモニカ・インヴィターレ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从以下效果选1个适用。
-- ●从卡组把1只「异响鸣」怪兽特殊召唤。这张卡的发动后，直到回合结束时自己不能把「异响鸣」怪兽以外的场上的怪兽的效果发动。
-- ●自己场上有灵摆怪兽以外的「异响鸣」怪兽存在的场合，从卡组选2只卡名不同的「异响鸣」灵摆怪兽，那之内的1只加入手卡，另1只表侧加入额外卡组。
local s,id,o=GetID()
-- 创建并注册这张卡的发动效果：效果类型为魔法卡发动（EFFECT_TYPE_ACTIVATE），可在自由时点发动；设定效果类别包含特殊召唤、加入额外卡组、检索、加入手牌；限定每回合只能发动1次（誓约次数），并指定发动时的目标判断函数与效果处理函数。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从以下效果选1个适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOEXTRA+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 判断卡组中的怪兽是否为「异响鸣」且可以被我方效果特殊召唤，用于筛选特殊召唤分支的目标。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1a3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 筛选卡组中满足“异响鸣灵摆怪兽且能够加入手牌或能够加入额外卡组”的卡片，作为检索分支的候选集合。
function s.thfilter(c,tp)
	return c:IsSetCard(0x1a3) and c:IsType(TYPE_PENDULUM)
		and (c:IsAbleToExtra() or c:IsAbleToHand())
end
-- 检查自己场上的怪兽是否为表侧表示且不是灵摆的「异响鸣」怪兽，用于判断检索分支的发动条件。
function s.cfilter(c)
	return not c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x1a3) and c:IsFaceup()
end
-- 发动条件判定：检查两个分支的可行性——分支一需要我方主要怪兽区有空位且卡组存在可特殊召唤的「异响鸣」怪兽；分支二需要卡组存在2张卡名不同且可按要求分配的「异响鸣」灵摆怪兽，且自己场上有表侧非灵摆的「异响鸣」怪兽；满足任一即可发动。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组中所有符合检索分支条件的「异响鸣」灵摆怪兽卡，用于后续判断能否选出2张。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 检查我方主要怪兽区域是否有空闲格子，以确定能否进行特殊召唤。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查卡组中是否存在至少1只可被我方特殊召唤的「异响鸣」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	local b2=g:CheckSubGroup(s.Group,2,2)
		-- 同时检查自己场上是否存在表侧表示且非灵摆的「异响鸣」怪兽，以满足检索分支的发动条件。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
end
-- 对每组候选卡判断：当前卡片能否加入额外卡组，且该组内除它之外还有1张能加入手牌的卡，用于确保两张卡能分别去额外和手牌。
function s.thfilter2(c,g)
	return c:IsAbleToExtra() and g:FilterCount(Card.IsAbleToHand,c)==1
end
-- 验证候选的2张卡是否卡名不同，且存在一张可去额外、另一张可去手牌的分配方式。
function s.Group(g)
	-- 返回是否同时满足：2张卡卡名不同，且其中至少1张可加入额外卡组、组内另有1张可加入手牌。
	return aux.dncheck(g) and g:FilterCount(s.thfilter2,nil,g)~=0
end
-- 效果处理：重新确认两个分支的可行性，让玩家选择要适用的效果。若选特殊召唤分支，从卡组特召1只「异响鸣」怪兽，并给玩家附加到回合结束不能发动场上非「异响鸣」怪兽效果的封印；若选检索分支，从卡组选择2张卡名不同的「异响鸣」灵摆怪兽，将其中1只加入手牌、另1只表侧加入额外卡组。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理阶段再次获取卡组中可作为检索对象的「异响鸣」灵摆怪兽集合，用于判断可选分支和后续选择。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 再次判断我方主要怪兽区是否有空位。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且卡组中仍有至少1只可特殊召唤的「异响鸣」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	local b2=g:CheckSubGroup(s.Group,2,2)
		-- 且自己场上仍有表侧非灵摆「异响鸣」怪兽存在。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
	local op=0
	if b1 and b2 then
		-- 两个分支都可行时，弹出选项让玩家选择“特殊召唤”或“加入手卡”，并将选择结果转换为op数值（1或2）。
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))+1  --"特殊召唤/加入手卡"
	elseif b1 then
		-- 只有特殊召唤分支可行时，让玩家确认选择该效果，op设为1。
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1  --"特殊召唤"
	elseif b2 then
		-- 只有检索分支可行时，让玩家确认选择该效果，op设为2。
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+2  --"加入手卡"
	end
	if op==1 then
		-- 发送选择提示，要求玩家选择要特殊召唤的「异响鸣」怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只满足条件的「异响鸣」怪兽作为特殊召唤对象。
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到我方场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 这张卡的发动后，直到回合结束时自己不能把「异响鸣」怪兽以外的场上的怪兽的效果发动。自己场上有灵摆怪兽以外的「异响鸣」怪兽存在的场合，从卡组选2只卡名不同的「异响鸣」灵摆怪兽，那之内的1只加入手卡，另1只表侧加入额外卡组。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将自肃效果注册到该玩家身上，使其在该效果适用期间受到“不能发动”的限制。
		Duel.RegisterEffect(e1,tp)
	elseif op==2 then
		-- 在选择2张卡之前给玩家发送提示信息，告知需要进行卡牌选择。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:SelectSubGroup(tp,s.Group,false,2,2)
		-- 在最终选择加入手牌的那1张之前，再次发送提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tc=sg:FilterSelect(tp,Card.IsAbleToHand,1,1,nil):GetFirst()
		-- 将选中的1只「异响鸣」灵摆怪兽加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认展示这张加入手牌的卡。
		Duel.ConfirmCards(1-tp,tc)
		sg:RemoveCard(tc)
		-- 将剩下的1只「异响鸣」灵摆怪兽表侧加入其持有者的额外卡组。
		Duel.SendtoExtraP(sg,nil,REASON_EFFECT)
	end
end
-- 定义自肃限制的判定条件：若发动效果的卡是位于场上的怪兽，且该怪兽不是「异响鸣」，则该玩家不能发动此效果。
function s.aclimit(e,re,tp)
	local c=re:GetHandler()
	return not c:IsSetCard(0x1a3) and re:IsActiveType(TYPE_MONSTER) and c:IsLocation(LOCATION_MZONE)
end
