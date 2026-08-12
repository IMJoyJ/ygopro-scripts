--サイコ・ヒーリング
-- 效果：
-- 自己场上表侧表示存在的念动力族怪兽每有1只，自己回复1000基本分。
function c21488686.initial_effect(c)
	-- 效果发动时点设置为自由时点，可随时发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c21488686.target)
	e1:SetOperation(c21488686.operation)
	c:RegisterEffect(e1)
end
-- 效果处理目标设定函数
function c21488686.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的念动力族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c21488686.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置效果的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 计算自己场上表侧表示的念动力族怪兽数量并乘以1000得到回复基本分
	local rec=Duel.GetMatchingGroupCount(c21488686.filter,tp,LOCATION_MZONE,0,nil)*1000
	-- 设置效果的对象参数为计算出的回复基本分
	Duel.SetTargetParam(rec)
	-- 设置效果操作信息为回复基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 过滤函数，用于判断怪兽是否为表侧表示且属于念动力族
function c21488686.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO)
end
-- 效果处理函数
function c21488686.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 计算自己场上表侧表示的念动力族怪兽数量并乘以1000得到回复基本分
	local rec=Duel.GetMatchingGroupCount(c21488686.filter,tp,LOCATION_MZONE,0,nil)*1000
	-- 获取当前连锁的效果对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 使对象玩家回复对应基本分
	Duel.Recover(p,rec,REASON_EFFECT)
end
