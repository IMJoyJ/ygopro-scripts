--リリース・リバース・バースト
-- 效果：
-- 把自己场上1只名字带有「希望皇 霍普」的怪兽解放才能发动。对方场上盖放的魔法·陷阱卡全部破坏。
function c38777931.initial_effect(c)
	-- 效果原文内容：把自己场上1只名字带有「希望皇 霍普」的怪兽解放才能发动。对方场上盖放的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c38777931.cost)
	e1:SetTarget(c38777931.target)
	e1:SetOperation(c38777931.activate)
	c:RegisterEffect(e1)
end
-- 检查是否满足解放条件并选择1只名字带有「希望皇 霍普」的怪兽进行解放
function c38777931.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张名字带有「希望皇 霍普」的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x107f) end
	-- 选择1张名字带有「希望皇 霍普」的可解放怪兽
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x107f)
	-- 将选中的怪兽解放作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 过滤函数，用于筛选对方场上里侧表示的魔法·陷阱卡
function c38777931.filter(c)
	return c:IsFacedown() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 检查对方场上是否存在至少1张里侧表示的魔法·陷阱卡并设置破坏效果信息
function c38777931.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张里侧表示的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c38777931.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有里侧表示的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c38777931.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁处理信息，指定将要破坏的卡组及数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行效果，破坏对方场上所有里侧表示的魔法·陷阱卡
function c38777931.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有里侧表示的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c38777931.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 将对方场上所有里侧表示的魔法·陷阱卡破坏
	Duel.Destroy(g,REASON_EFFECT)
end
