--サン・アンド・ムーン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己以及对方场上的怪兽各1只为对象才能发动。那些怪兽各受那表示形式的以下效果适用。
-- ●表侧表示：变成里侧守备表示。
-- ●里侧表示：变成表侧守备表示。
local s,id,o=GetID()
-- 效果初始化，创建效果对象并注册到卡片上
function s.initial_effect(c)
	-- ①：以自己以及对方场上的怪兽各1只为对象才能发动。那些怪兽各受那表示形式的以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(TIMING_BATTLE_PHASE,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选可以改变表示形式的怪兽
function s.filter(c)
	return (c:IsFaceup() and c:IsCanTurnSet()) or c:IsFacedown()
end
-- 效果目标选择函数，选择双方场上的怪兽作为对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断是否满足发动条件，即双方场上各存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择己方场上的1只怪兽作为对象
	local g1=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择对方场上的1只怪兽作为对象
	local g2=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，指定将要改变表示形式的怪兽数量和类型
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g1+g2,2,0,0)
end
-- 效果发动处理函数，根据怪兽的表示形式改变其位置
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的目标卡片组，并筛选出与当前效果相关的卡片
	local gs=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 遍历目标卡片组中的每张卡片
	for c in aux.Next(gs) do
		-- 根据卡片当前表示形式改变其为相反的表示形式
		Duel.ChangePosition(c,c:IsFaceup() and POS_FACEDOWN_DEFENSE or POS_FACEUP_DEFENSE)
	end
end
