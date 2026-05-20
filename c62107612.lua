--ディメンション・ワンダラー
-- 效果：
-- 「银河眼光子龙」的效果让怪兽从游戏中除外时，把这张卡从手卡送去墓地才能发动。给与对方基本分3000分伤害。「次元流浪士」的效果1回合只能使用1次。
function c62107612.initial_effect(c)
	-- 「银河眼光子龙」的效果让怪兽从游戏中除外时，把这张卡从手卡送去墓地才能发动。给与对方基本分3000分伤害。「次元流浪士」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62107612,0))  --"伤害"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_REMOVE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,62107612)
	e1:SetCondition(c62107612.condition)
	e1:SetCost(c62107612.cost)
	e1:SetTarget(c62107612.target)
	e1:SetOperation(c62107612.operation)
	c:RegisterEffect(e1)
end
-- 判定除外事件是否由「银河眼光子龙」的效果引起
function c62107612.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and re and re:GetHandler():IsCode(93717133)
end
-- 判定是否能将自身送去墓地，并执行送去墓地的发动代价
function c62107612.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为发动代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 设定伤害的对象玩家和数值，并注册伤害操作信息
function c62107612.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定效果的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设定效果的参数（伤害值）为3000
	Duel.SetTargetParam(3000)
	-- 注册给与对方3000分伤害的效果分类操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,3000)
end
-- 获取设定的玩家和伤害值，并执行伤害处理
function c62107612.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
