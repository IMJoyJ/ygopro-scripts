--エンシェント・フェアリー・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡把1只4星以下的怪兽特殊召唤。这个效果发动的回合，自己不能进行战斗阶段。
-- ②：自己主要阶段才能发动。场地区域的卡全部破坏，自己回复1000基本分。那之后，可以把和破坏的卡卡名不同的1张场地魔法卡从卡组加入手卡。
function c25862681.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：自己主要阶段才能发动。从手卡把1只4星以下的怪兽特殊召唤。这个效果发动的回合，自己不能进行战斗阶段。
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
	-- ②：自己主要阶段才能发动。场地区域的卡全部破坏，自己回复1000基本分。那之后，可以把和破坏的卡卡名不同的1张场地魔法卡从卡组加入手卡。
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
-- 效果处理时的费用函数，用于提示对方玩家该效果已被发动
function c25862681.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示该效果已被发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 判断是否处于主要阶段1
function c25862681.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于主要阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 过滤满足条件的怪兽：等级不超过4星且可以特殊召唤
function c25862681.sumfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤的条件：手牌中有满足条件的怪兽且场上存在空位
function c25862681.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c25862681.sumfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_HAND)
	-- 创建并注册一个使对方不能进入战斗阶段的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤效果的处理函数
function c25862681.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c25862681.sumfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 设置场地破坏效果的目标信息
function c25862681.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场地区域的卡组
	local g=Duel.GetFieldGroup(tp,LOCATION_FZONE,LOCATION_FZONE)
	if chk==0 then return g:GetCount()>0 end
	-- 设置破坏操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置回复LP操作信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 过滤满足条件的场地魔法卡：类型为场地魔法且可以加入手牌
function c25862681.ffilter(c,g)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand() and not g:IsExists(Card.IsCode,1,nil,c:GetCode())
end
-- 场地破坏效果的处理函数
function c25862681.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场地区域的卡组
	local g=Duel.GetFieldGroup(tp,LOCATION_FZONE,LOCATION_FZONE)
	if g:GetCount()>0 then
		-- 将场地区域的卡全部破坏
		Duel.Destroy(g,REASON_EFFECT)
		-- 获取实际被破坏的卡组
		local og=Duel.GetOperatedGroup()
		if og:GetCount()>0 then
			-- 回复玩家LP
			Duel.Recover(tp,1000,REASON_EFFECT)
			-- 获取满足条件的场地魔法卡组
			local fg=Duel.GetMatchingGroup(c25862681.ffilter,tp,LOCATION_DECK,0,nil,og)
			-- 判断是否有满足条件的场地魔法卡且玩家选择是否发动
			if fg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(25862681,2)) then  --"是否要选一张场地魔法加入手卡？"
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 提示玩家选择要加入手牌的场地魔法卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				local sg=fg:Select(tp,1,1,nil)
				-- 将选中的场地魔法卡加入手牌
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				-- 确认对方玩家看到选中的场地魔法卡
				Duel.ConfirmCards(1-tp,sg)
			end
		end
	end
end
