--運命の囚人
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：连接4怪兽连接召唤的场合才能发动1次。给这张卡放置1个指示物（最多3个）。那之后，可以让这张卡的指示物数量的以下效果适用。
-- ●1个：宣言1个卡名。这个回合，原本卡名和宣言的卡相同的卡的效果无效化。
-- ●2个：从自己墓地选1只4星以下的怪兽特殊召唤。
-- ●3个：这张卡送去墓地，从额外卡组把1只连接4怪兽特殊召唤。
function c27104921.initial_effect(c)
	c:EnableCounterPermit(0x61)
	c:SetCounterLimit(0x61,3)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,27104921+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	-- ①：连接4怪兽连接召唤的场合才能发动1次。给这张卡放置1个指示物（最多3个）。那之后，可以让这张卡的指示物数量的以下效果适用。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c27104921.condition)
	e2:SetTarget(c27104921.target)
	e2:SetOperation(c27104921.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：连接4的怪兽，以连接召唤方式出场，且表侧表示
function c27104921.cfilter(c,tp)
	return c:IsLink(4) and c:IsSummonType(SUMMON_TYPE_LINK) and c:IsFaceup()
end
-- 连锁触发条件：有连接4的怪兽以连接召唤方式出场
function c27104921.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c27104921.cfilter,1,nil,tp)
end
-- 效果发动时的处理：检查是否可以放置1个指示物
function c27104921.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以放置1个指示物
	if chk==0 then return Duel.IsCanAddCounter(tp,0x61,1,e:GetHandler()) end
	-- 设置操作信息：放置1个指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x61)
end
-- 效果处理：根据指示物数量执行不同效果
function c27104921.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x61,1)
		local ct=c:GetCounter(0x61)
		-- 判断是否为1个指示物且玩家选择宣言卡名无效化
		if ct==1 and Duel.SelectYesNo(tp,aux.Stringid(27104921,0)) then  --"是否宣言卡名无效化？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 提示玩家选择宣言一个卡名
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
			-- 让玩家宣言一个卡牌卡号
			local ac=Duel.AnnounceCard(tp)
			-- 创建一个字段效果，使指定卡号的魔法陷阱效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
			e1:SetTarget(c27104921.distg1)
			e1:SetLabel(ac)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 注册效果e1给玩家tp
			Duel.RegisterEffect(e1,tp)
			-- 创建一个字段持续效果，当连锁处理时使指定卡号的效果无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_CHAIN_SOLVING)
			e2:SetCondition(c27104921.discon)
			e2:SetOperation(c27104921.disop)
			e2:SetLabel(ac)
			e2:SetReset(RESET_PHASE+PHASE_END)
			-- 注册效果e2给玩家tp
			Duel.RegisterEffect(e2,tp)
			-- 创建一个字段效果，使指定卡号的陷阱怪兽效果无效
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_FIELD)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e3:SetTarget(c27104921.distg2)
			e3:SetLabel(ac)
			e3:SetReset(RESET_PHASE+PHASE_END)
			-- 注册效果e3给玩家tp
			Duel.RegisterEffect(e3,tp)
		end
		-- 获取玩家tp墓地满足条件的怪兽组
		local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(c27104921.spfilter1),tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 判断是否为2个指示物且玩家选择从墓地特殊召唤
		if ct==2 and g1:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(27104921,1)) then  --"是否从墓地特殊召唤？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg1=g1:Select(tp,1,1,nil)
			-- 将选定的怪兽特殊召唤
			Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 获取玩家tp额外卡组满足条件的怪兽组
		local g2=Duel.GetMatchingGroup(c27104921.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp)
		-- 判断是否为3个指示物且玩家选择从额外卡组特殊召唤
		if ct==3 and g2:GetCount()>0 and c:IsAbleToGrave() and Duel.SelectYesNo(tp,aux.Stringid(27104921,2)) then  --"是否从额外卡组特殊召唤？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将此卡送去墓地
			if Duel.SendtoGrave(c,REASON_EFFECT)>0 and c:IsLocation(LOCATION_GRAVE) then
				-- 提示玩家选择要特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local sg2=g2:Select(tp,1,1,nil)
				-- 将选定的怪兽特殊召唤
				Duel.SpecialSummon(sg2,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 效果目标过滤函数：判断卡牌是否为指定卡号的原卡名（魔法陷阱）
function c27104921.distg1(e,c)
	local ac=e:GetLabel()
	if c:IsType(TYPE_SPELL+TYPE_TRAP) then
		return c:IsOriginalCodeRule(ac)
	else
		return c:IsOriginalCodeRule(ac) and (c:IsType(TYPE_EFFECT) or c:GetOriginalType()&TYPE_EFFECT~=0)
	end
end
-- 效果目标过滤函数：判断卡牌是否为指定卡号的原卡名（陷阱怪兽）
function c27104921.distg2(e,c)
	local ac=e:GetLabel()
	return c:IsOriginalCodeRule(ac)
end
-- 连锁处理时的条件函数：判断当前处理的连锁是否为指定卡号的原卡名
function c27104921.discon(e,tp,eg,ep,ev,re,r,rp)
	local ac=e:GetLabel()
	return re:GetHandler():IsOriginalCodeRule(ac)
end
-- 连锁处理时的操作函数：使指定连锁的效果无效
function c27104921.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使指定连锁的效果无效
	Duel.NegateEffect(ev)
end
-- 特殊召唤过滤函数：等级4以下且可特殊召唤的怪兽
function c27104921.spfilter1(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤过滤函数：连接4且可特殊召唤的怪兽
function c27104921.spfilter2(c,e,tp)
	return c:IsLink(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
