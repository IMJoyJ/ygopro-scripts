--エレメンタル・チャージ
-- 效果：
-- 自己场上表侧表示存在的名字带有「元素英雄」的怪兽每有1只，自己回复1000基本分。
function c36586443.initial_effect(c)
	-- 卡片效果初始化，设置为发动时点、回复效果、玩家为目标、自由连锁，并注册目标和效果处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c36586443.target)
	e1:SetOperation(c36586443.operation)
	c:RegisterEffect(e1)
end
-- 效果处理目标函数，检查自己场上是否存在名字带有「元素英雄」的表侧表示怪兽，若存在则设置目标玩家为自身，计算满足条件的怪兽数量乘以1000作为回复基本分，设置操作信息为回复效果
function c36586443.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，检查自己场上是否存在至少1只名字带有「元素英雄」的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c36586443.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置当前连锁的目标玩家为效果发动者
	Duel.SetTargetPlayer(tp)
	-- 计算自己场上名字带有「元素英雄」的表侧表示怪兽数量，并乘以1000作为回复的基本分
	local rec=Duel.GetMatchingGroupCount(c36586443.filter,tp,LOCATION_MZONE,0,nil)*1000
	-- 设置当前连锁的目标参数为计算出的回复基本分
	Duel.SetTargetParam(rec)
	-- 设置当前连锁的操作信息，包含回复效果、目标玩家和回复基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 过滤函数，用于判断怪兽是否为表侧表示且名字带有「元素英雄」
function c36586443.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x3008)
end
-- 效果处理函数，计算满足条件的怪兽数量乘以1000作为回复基本分，并以效果发动者为对象进行回复
function c36586443.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 计算自己场上名字带有「元素英雄」的表侧表示怪兽数量，并乘以1000作为回复的基本分
	local rec=Duel.GetMatchingGroupCount(c36586443.filter,tp,LOCATION_MZONE,0,nil)*1000
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 以目标玩家为对象，根据计算出的基本分进行回复
	Duel.Recover(p,rec,REASON_EFFECT)
end
