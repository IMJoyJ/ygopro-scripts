--星遺物の対焉
-- 效果：
-- ①：连接怪兽之间进行战斗的攻击宣言时才能发动。双方的场上·墓地的怪兽全部回到持有者卡组。这张卡发动过的回合，双方不能连接召唤。
function c73192600.initial_effect(c)
	-- ①：连接怪兽之间进行战斗的攻击宣言时才能发动。双方的场上·墓地的怪兽全部回到持有者卡组。这张卡发动过的回合，双方不能连接召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c73192600.condition)
	e1:SetTarget(c73192600.target)
	e1:SetOperation(c73192600.activate)
	c:RegisterEffect(e1)
end
-- 判断是否为连接怪兽之间进行战斗的攻击宣言时
function c73192600.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行攻击的怪兽
	local a=Duel.GetAttacker()
	-- 获取作为攻击目标的怪兽
	local d=Duel.GetAttackTarget()
	return a and d and a:IsFaceup() and a:IsType(TYPE_LINK) and d:IsFaceup() and d:IsType(TYPE_LINK)
end
-- 过滤可以回到卡组的怪兽卡
function c73192600.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 检查是否存在可回到卡组的怪兽，并设置回卡组的操作信息
function c73192600.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场上及双方墓地的所有可以回到卡组的怪兽
	local g=Duel.GetMatchingGroup(c73192600.tdfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置将这些怪兽送回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理：将双方场上·墓地的怪兽全部回到持有者卡组，并限制双方本回合不能连接召唤
function c73192600.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前双方场上及双方墓地的所有可以回到卡组的怪兽
	local g=Duel.GetMatchingGroup(c73192600.tdfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil)
	if g:GetCount()>0 then
		-- 将这些怪兽全部送回持有者卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡发动过的回合，双方不能连接召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,1)
	e1:SetTarget(c73192600.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局注册限制双方玩家特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的类型为连接召唤
function c73192600.splimit(e,c,tp,sumtp,sumpos)
	return bit.band(sumtp,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
