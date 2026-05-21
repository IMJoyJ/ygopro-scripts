--ホーリー・エルフの祝福
-- 效果：
-- ①：自己回复场上的怪兽数量×300基本分。
function c98299011.initial_effect(c)
	-- ①：自己回复场上的怪兽数量×300基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x1c1)
	e1:SetTarget(c98299011.target)
	e1:SetOperation(c98299011.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的目标确认与准备阶段（检查场上是否有怪兽，并设置回复的玩家和数值参数）
function c98299011.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点检查双方场上是否存在怪兽
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)>0 end
	-- 计算发动时双方场上的怪兽数量乘以300的数值
	local rec=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)*300
	-- 设置回复的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置回复的目标数值
	Duel.SetTargetParam(rec)
	-- 设置操作信息为回复自己指定数值的基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 效果处理阶段（获取目标玩家和当前的回复数值，并执行回复LP的操作）
function c98299011.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算效果处理时双方场上的怪兽数量乘以300的数值
	local rec=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)*300
	-- 执行回复操作，使目标玩家回复计算出的基本分
	Duel.Recover(p,rec,REASON_EFFECT)
end
