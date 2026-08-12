--ドラスティック・ドロー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是电子界族怪兽不能召唤·特殊召唤。
-- ①：把2只以上的自己场上的怪兽全部除外才能发动。自己抽3张。
local s,id,o=GetID()
-- 注册卡片效果，并设置召唤、特殊召唤电子界族怪兽的自定义计数器
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 添加自定义计数器，用于记录本回合是否召唤过非电子界族怪兽
	Duel.AddCustomActivityCounter(id,ACTIVITY_SUMMON,aux.FilterBoolFunction(Card.IsRace,RACE_CYBERSE))
	-- 添加自定义计数器，用于记录本回合是否特殊召唤过非电子界族怪兽
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,aux.FilterBoolFunction(Card.IsRace,RACE_CYBERSE))
end
-- 发动代价过滤与检测函数，判断是否满足除外怪兽和召唤限制的条件
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上的所有怪兽
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 在发动时，确认自己场上是否存在2只以上的怪兽，且这些怪兽全部可以作为代价除外
	if chk==0 then return #g>1 and not g:IsExists(aux.NOT(Card.IsAbleToRemoveAsCost),1,nil)
		-- 确认本回合至今为止没有召唤过非电子界族怪兽
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SUMMON)==0
		-- 确认本回合至今为止没有特殊召唤过非电子界族怪兽
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 将自己场上的怪兽全部表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 这张卡发动的回合，自己不是电子界族怪兽不能召唤·特殊召唤。①：把2只以上的自己场上的怪兽全部除外才能发动。自己抽3张。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	-- 设置限制效果的对象为非电子界族怪兽
	e1:SetTarget(aux.TargetBoolFunction(aux.NOT(Card.IsRace),RACE_CYBERSE))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册不能召唤非电子界族怪兽的限制
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- 给玩家注册不能特殊召唤非电子界族怪兽的限制
	Duel.RegisterEffect(e2,tp)
end
-- 效果发动目标检测与处理函数，设置抽卡相关的参数和操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，确认自己是否可以从卡组抽3张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,3) end
	-- 设置连锁的对象参数为3（抽卡数量）
	Duel.SetTargetParam(3)
	-- 设置连锁的对象玩家为当前发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的操作信息为玩家抽3张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
-- 效果发动时的具体处理函数，执行抽卡操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
