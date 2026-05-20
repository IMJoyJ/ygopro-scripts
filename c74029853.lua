--黄金色の竹光
-- 效果：
-- ①：自己场上有「竹光」装备魔法卡存在的场合才能发动。自己从卡组抽2张。
function c74029853.initial_effect(c)
	-- ①：自己场上有「竹光」装备魔法卡存在的场合才能发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c74029853.condition)
	e1:SetTarget(c74029853.target)
	e1:SetOperation(c74029853.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：过滤出自己场上表侧表示的「竹光」装备魔法卡
function c74029853.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x60) and c:IsType(TYPE_EQUIP)
end
-- 发动条件：自己场上有「竹光」装备魔法卡存在
function c74029853.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「竹光」装备魔法卡
	return Duel.IsExistingMatchingCard(c74029853.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果发动：验证是否能抽卡，并设置抽卡对象玩家、抽卡数量及抽卡操作信息
function c74029853.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查自己是否具有抽2张卡的能力
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置当前连锁的对象玩家为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为2（抽卡张数）
	Duel.SetTargetParam(2)
	-- 设置当前连锁的操作信息为：由发动玩家抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：获取设定的玩家和抽卡张数，执行抽卡
function c74029853.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家因效果从卡组抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
