--暗黒のミミック LV3
-- 效果：
-- 这张卡因为战斗送去墓地的场合，这张卡的控制者从卡组抽1张卡。这张卡因为「暗黑之宝箱怪 LV1」的效果特殊召唤的场合改成抽2张卡。
function c1102515.initial_effect(c)
	-- 这张卡因为战斗送去墓地的场合，这张卡的控制者从卡组抽1张卡。这张卡因为「暗黑之宝箱怪 LV1」的效果特殊召唤的场合改成抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1102515,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c1102515.condition)
	e1:SetTarget(c1102515.target)
	e1:SetOperation(c1102515.operation)
	c:RegisterEffect(e1)
end
c1102515.lvup={74713516}
c1102515.lvdn={74713516}
-- 判断此卡是否因特殊召唤（LV）被特殊召唤
function c1102515.condition(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_LV then e:SetLabel(2)
	else e:SetLabel(1) end
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 设置效果处理时的参数，包括抽卡数量
function c1102515.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的对象玩家为当前处理的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的对象参数为抽卡数量
	Duel.SetTargetParam(e:GetLabel())
	-- 设置效果操作信息为抽卡效果，并指定抽卡数量
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,e:GetLabel())
end
-- 执行抽卡效果
function c1102515.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 根据设定的玩家和数量进行抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
