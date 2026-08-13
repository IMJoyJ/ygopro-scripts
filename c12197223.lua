--天雷ノ双風神 シーナ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上有风属性怪兽存在，对方把魔法·陷阱·怪兽的效果发动时才能发动。这张卡从手卡特殊召唤。那之后，那个对方的效果种类的以下效果适用。
-- ●怪兽：「天雷之双风神 息那」以外的场上的表侧表示怪兽全部回到手卡。
-- ●魔法·陷阱：场上的魔法·陷阱卡全部回到手卡。
-- ②：这张卡1回合只有1次不会被战斗破坏。
local s,id,o=GetID()
-- 为这张卡注册两个效果：e1为①的诱发即时效果（满足条件时从手牌特殊召唤并处理回手牌），e2为②的一回合一次不被战斗破坏的效果。
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己场上有风属性怪兽存在，对方把魔法·陷阱·怪兽的效果发动时才能发动。这张卡从手卡特殊召唤。那之后，那个对方的效果种类的以下效果适用。●怪兽：「天雷之双风神 息那」以外的场上的表侧表示怪兽全部回到手卡。●魔法·陷阱：场上的魔法·陷阱卡全部回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡1回合只有1次不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(1)
	e2:SetValue(s.valcon)
	c:RegisterEffect(e2)
end
-- 过滤条件：该卡为表侧表示且属性为风，用于检查自己场上是否存在风属性怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND)
end
-- ①的发动条件：对方发动效果且发动者是对方（rp==1-tp），同时自己场上有至少1只表侧表示的风属性怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
		-- 检查自己场上是否存在至少1只表侧表示的风属性怪兽，作为①效果能否发动的条件之一。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 回手牌的过滤：若卡是这张卡自身且在怪兽区则排除；当res为true（对方发动的是怪兽效果）时选择场上的表侧表示怪兽，当res为false（魔法·陷阱效果）时选择场上的魔法·陷阱卡，并且这些卡必须能加入手牌。
function s.thfilter(c,res)
	if c:IsCode(id) and c:IsLocation(LOCATION_MZONE) then return false end
	return (res and c:IsFaceup() and c:IsType(TYPE_MONSTER)
		or not res and c:IsType(TYPE_SPELL+TYPE_TRAP)) and c:IsAbleToHand()
end
-- ①的发动时处理：先判定自己怪兽区有空位、这张卡能特殊召唤、且场上存在可回手牌的卡；然后按对方发动效果种类（怪兽/魔法·陷阱）设置Label，并将对应回手牌组和特殊召唤信息写入操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local res=re:IsActiveType(TYPE_MONSTER)
	if chk==0 then
		-- 检查自己主要怪兽区是否有可用空格，作为能否从手牌特殊召唤这张卡的前提。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 检查场上是否存在至少1张符合当前对方效果种类回手牌条件的卡，确保发动的效果不是空发。
			and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,res)
	end
	-- 按当前对方效果种类获取场上所有将要回手牌的卡并组成组g，用于后续操作信息和数量计算。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,res)
	if res then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	-- 设置操作信息：本次效果包含回手牌（CATEGORY_TOHAND），目标为组g，数量为g的数量，使相关卡能正确连锁对应。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
	-- 设置操作信息：本次效果包含特殊召唤（CATEGORY_SPECIAL_SUMMON），对象为这张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①的效果处理：先确认这张卡仍与连锁相关并尝试特殊召唤；成功后按之前Label判断对方效果种类，重新获取应回手牌的卡并全部返回手牌，同时用BreakEffect将回手牌处理分隔开。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与发动时的连锁有联系，并尝试将其从手牌以表侧表示特殊召唤；只有特殊召唤成功（返回非0）时才继续后面的回手牌处理。
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local res=false
		if e:GetLabel()==1 then res=true end
		-- 效果处理时重新获取当前场上应回手牌的卡组（以处理时实际场上满足条件的卡为准，避免因中间变化导致对象错误）。
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,res)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使后续回手牌处理与特殊召唤处理不在同一时点进行，避免错失时点并使对方/相关卡能正确对应。
			Duel.BreakEffect()
			-- 将所有符合条件的卡片返回持有者手牌，返回原因记为效果（REASON_EFFECT）。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end
-- ②的破坏耐性判定：仅当破坏原因中包含战斗破坏（REASON_BATTLE）时返回true，即此卡1回合1次不会被战斗破坏。
function s.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
