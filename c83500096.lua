--A・ジェネクス・ソリッド
-- 效果：
-- ①：1回合1次，把自己场上1只表侧表示的水属性「次世代」怪兽送去墓地才能发动。自己抽2张。
function c83500096.initial_effect(c)
	-- ①：1回合1次，把自己场上1只表侧表示的水属性「次世代」怪兽送去墓地才能发动。自己抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83500096,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c83500096.drcost)
	e1:SetTarget(c83500096.drtg)
	e1:SetOperation(c83500096.drop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示、水属性且可以作为代价送去墓地的「次世代」怪兽
function c83500096.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToGraveAsCost()
end
-- 发动代价（Cost）处理：将自己场上1只表侧表示的水属性「次世代」怪兽送去墓地
function c83500096.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查自己场上是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c83500096.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己场上1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c83500096.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选择的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果目标（Target）处理：设置抽卡玩家、抽卡数量及操作信息
function c83500096.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查当前玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置效果的对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的对象参数为2（抽卡数量）
	Duel.SetTargetParam(2)
	-- 设置操作信息为：玩家抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果运行（Operation）处理：执行抽卡
function c83500096.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的对象玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
