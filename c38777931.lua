--リリース・リバース・バースト
-- 效果：
-- 把自己场上1只名字带有「希望皇 霍普」的怪兽解放才能发动。对方场上盖放的魔法·陷阱卡全部破坏。
function c38777931.initial_effect(c)
	-- 把自己场上1只名字带有「希望皇 霍普」的怪兽解放才能发动。对方场上盖放的魔法·陷阱卡全部破坏。
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
-- 发动代价处理：从自己场上选择1只名字带有「希望皇 霍普」的怪兽解放作为发动代价。
function c38777931.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己场上是否存在至少1只名字带有「希望皇 霍普」的可解放怪兽，若不存在则不能发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x107f) end
	-- 从自己场上选择1只名字带有「希望皇 霍普」的可解放怪兽作为发动代价。
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x107f)
	-- 将选择的怪兽以代价（REASON_COST）解放。
	Duel.Release(g,REASON_COST)
end
-- 筛选对方场上里侧表示的魔法·陷阱卡。
function c38777931.filter(c)
	return c:IsFacedown() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动时确定处理对象：检查对方场上是否存在里侧表示的魔法·陷阱卡，并将这些卡全部设定为将被破坏的对象。
function c38777931.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测对方场上是否存在至少1张里侧表示的魔法·陷阱卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c38777931.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上全部里侧表示的魔法·陷阱卡。
	local g=Duel.GetMatchingGroup(c38777931.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：将破坏对象设为全部满足条件的卡，数量为g的卡数，用于系统判定破坏相关效果。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：获取对方场上当前全部里侧表示的魔法·陷阱卡并全部破坏。
function c38777931.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上当前所有里侧表示的魔法·陷阱卡。
	local g=Duel.GetMatchingGroup(c38777931.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 将这些卡以效果（REASON_EFFECT）破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
