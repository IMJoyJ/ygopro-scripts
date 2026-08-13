--エレメンタル・チャージ
-- 效果：
-- 自己场上表侧表示存在的名字带有「元素英雄」的怪兽每有1只，自己回复1000基本分。
function c36586443.initial_effect(c)
	-- 自己场上表侧表示存在的名字带有「元素英雄」的怪兽每有1只，自己回复1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c36586443.target)
	e1:SetOperation(c36586443.operation)
	c:RegisterEffect(e1)
end
-- 发动时判定与信息设置：检查自己场上是否存在表侧表示的「元素英雄」怪兽，若存在则将自己设为对象玩家，计算并记录回复量，并设置回复效果的操作信息。
function c36586443.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：在效果发动确认时（chk==0），若自己场上不存在表侧表示且含「元素英雄」字段的怪兽，则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c36586443.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 将当前连锁的对象玩家设置为自己（tp），使后续回复作用于该玩家。
	Duel.SetTargetPlayer(tp)
	-- 统计自己场上表侧表示且含「元素英雄」字段的怪兽数量，乘以1000，得到预计回复的基本分数值。
	local rec=Duel.GetMatchingGroupCount(c36586443.filter,tp,LOCATION_MZONE,0,nil)*1000
	-- 将计算出的回复量设为连锁对象参数，供效果处理时取出。
	Duel.SetTargetParam(rec)
	-- 设置操作信息：声明此连锁包含回复效果，目标玩家为自己，预计回复量为rec，用于环境检测与记录。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 定义筛选条件：怪兽需为表侧表示，且卡名包含「元素英雄」字段（0x3008）。
function c36586443.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x3008)
end
-- 效果处理时的实际回复操作：重新统计自己场上当前符合条件的怪兽数量，获取之前保存的对象玩家，并使其回复相应的基本分。
function c36586443.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时统计当前自己场上表侧表示且含「元素英雄」字段的怪兽数量，乘以1000得到实际回复量。
	local rec=Duel.GetMatchingGroupCount(c36586443.filter,tp,LOCATION_MZONE,0,nil)*1000
	-- 从当前连锁信息中取出之前保存的对象玩家（即发动者tp）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 让对象玩家p回复rec点基本分，回复原因为效果，完成基本分回复。
	Duel.Recover(p,rec,REASON_EFFECT)
end
