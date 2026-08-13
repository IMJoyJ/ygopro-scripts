--エンシェント・フェアリー・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡把1只4星以下的怪兽特殊召唤。这个效果发动的回合，自己不能进行战斗阶段。
-- ②：自己主要阶段才能发动。场地区域的卡全部破坏，自己回复1000基本分。那之后，可以把和破坏的卡卡名不同的1张场地魔法卡从卡组加入手卡。
function c25862681.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整（任意）+ 调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 对应效果原文：这个卡名的①②的效果1回合各能使用1次。①：自己主要阶段才能发动。从手卡把1只4星以下的怪兽特殊召唤。这个效果发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25862681,0))  --"从手卡把1只4星以下的怪兽特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,25862681)
	e1:SetCondition(c25862681.sumcon)
	e1:SetCost(c25862681.cost)
	e1:SetTarget(c25862681.sumtg)
	e1:SetOperation(c25862681.sumop)
	c:RegisterEffect(e1)
	-- 对应效果原文：这个卡名的①②的效果1回合各能使用1次。②：自己主要阶段才能发动。场地区域的卡全部破坏，自己回复1000基本分。那之后，可以把和破坏的卡卡名不同的1张场地魔法卡从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25862681,1))  --"把场地全部破坏"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,25862682)
	e2:SetCost(c25862681.cost)
	e2:SetTarget(c25862681.destg)
	e2:SetOperation(c25862681.desop)
	c:RegisterEffect(e2)
end
-- 这是两个效果共用的cost处理函数：没有实际发动代价，在发动确认后向对方玩家提示自己发动了哪个效果。
function c25862681.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家（1-tp）发送提示，显示当前发动效果的描述文字，便于对方确认。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果①的发动条件判定函数：当前必须处于自己回合的主要阶段1（PHASE_MAIN1）。
function c25862681.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1（PHASE_MAIN1）。
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 特殊召唤的过滤函数：要求怪兽等级在4星以下，并且可以被玩家tp通过效果e特殊召唤。
function c25862681.sumfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①发动时的目标确认：检查自己场上是否有可用的怪兽区，以及手卡中是否有满足特殊召唤条件的怪兽；若chk==0（合法性检查）则返回这些条件是否成立。
function c25862681.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果合法性检查阶段，要求自己场上存在可用的怪兽区域（空格数大于0）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且要求手卡中存在至少1只满足sumfilter条件的4星以下可特殊召唤的怪兽，才能发动。
		and Duel.IsExistingMatchingCard(c25862681.sumfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 将本连锁的操作信息登记为“特殊召唤”：预定从手卡特殊召唤1只怪兽，用于给时点检测（如星尘龙等）提供信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_HAND)
	-- 对应效果原文：这个卡名的①②的效果1回合各能使用1次。①：自己主要阶段才能发动。从手卡把1只4星以下的怪兽特殊召唤。这个效果发动的回合，自己不能进行战斗阶段。②：自己主要阶段才能发动。场地区域的卡全部破坏，自己回复1000基本分。那之后，可以把和破坏的卡卡名不同的1张场地魔法卡从卡组加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将刚创建的“不能进入战斗阶段”的誓约效果注册到场上，使其作用于tp玩家，并在回合结束时自动重置。
	Duel.RegisterEffect(e1,tp)
end
-- 效果①的特殊召唤处理：如果仍有空余怪兽区，则从手卡选择1只满足条件的怪兽，以表侧表示特殊召唤到自己的怪兽区。
function c25862681.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上存在可用怪兽区；若没有则直接结束本次特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家tp显示“请选择要特殊召唤的卡”的提示信息，作为选择卡片时的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只满足sumfilter（4星以下且可特殊召唤）的怪兽。
	local g=Duel.SelectMatchingCard(tp,c25862681.sumfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上（使用通常的特殊召唤规则检查召唤条件和苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动目标判定：获取双方场地区域的全部卡，若场上存在场地卡则可发动；并登记操作信息：破坏这些卡、回复1000LP。
function c25862681.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场地区域中的所有卡片（作为可能被破坏的对象）。
	local g=Duel.GetFieldGroup(tp,LOCATION_FZONE,LOCATION_FZONE)
	if chk==0 then return g:GetCount()>0 end
	-- 将本连锁的操作信息登记为“破坏”：对象为双方场地区域的全部卡，数量为这些卡的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 登记“回复”操作信息：玩家tp回复1000基本分。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 场地魔法检索的过滤函数：必须是场地魔法卡、可以加入手卡，且卡名与任意一张已破坏卡的卡名不同。
function c25862681.ffilter(c,g)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand() and not g:IsExists(Card.IsCode,1,nil,c:GetCode())
end
-- 效果②的处理：破坏双方场地区域的全部卡；若有卡被破坏则回复1000LP；然后可选择把1张卡名与破坏的卡不同的场地魔法卡从卡组加入手卡并向对方确认。
function c25862681.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时重新获取双方场地区域的全部卡（因为效果处理时场地区域可能发生变化）。
	local g=Duel.GetFieldGroup(tp,LOCATION_FZONE,LOCATION_FZONE)
	if g:GetCount()>0 then
		-- 以效果破坏双方场地区域的全部卡。
		Duel.Destroy(g,REASON_EFFECT)
		-- 获取刚才破坏操作实际被破坏的卡片组，供后续判断是否满足“那之后”的条件。
		local og=Duel.GetOperatedGroup()
		if og:GetCount()>0 then
			-- 自己回复1000点基本分。
			Duel.Recover(tp,1000,REASON_EFFECT)
			-- 从卡组中筛选满足ffilter的场地魔法卡：卡名与任意一张被破坏的卡不同，且可以加入手卡。
			local fg=Duel.GetMatchingGroup(c25862681.ffilter,tp,LOCATION_DECK,0,nil,og)
			-- 如果存在符合条件的场地魔法卡，则询问玩家是否要将其中1张加入手卡；只有选择“是”才继续。
			if fg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(25862681,2)) then  --"是否要选一张场地魔法加入手卡？"
				-- 中断当前效果处理，使后续“加入手卡”的处理与前面的破坏/回复处理分开结算，避免错过时点。
				Duel.BreakEffect()
				-- 向玩家显示“请选择要加入手牌的卡”的提示信息。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				local sg=fg:Select(tp,1,1,nil)
				-- 将选择的场地魔法卡加入其持有者的手卡（原因：效果）。
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				-- 让对方玩家确认刚刚加入手卡的那张场地魔法卡。
				Duel.ConfirmCards(1-tp,sg)
			end
		end
	end
end
