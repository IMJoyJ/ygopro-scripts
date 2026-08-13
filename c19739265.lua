--サン・アンド・ムーン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己以及对方场上的怪兽各1只为对象才能发动。那些怪兽各受那表示形式的以下效果适用。
-- ●表侧表示：变成里侧守备表示。
-- ●里侧表示：变成表侧守备表示。
local s,id,o=GetID()
-- 创建并注册「太阳与月亮」的①效果：作为魔法卡在自由时点发动，选择双方场上怪兽各1只，改变其表示形式，并设定同名卡1回合只能发动1次。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己以及对方场上的怪兽各1只为对象才能发动。那些怪兽各受那表示形式的以下效果适用。●表侧表示：变成里侧守备表示。●里侧表示：变成表侧守备表示。
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
-- 筛选可作为对象的怪兽：表侧表示且能变为里侧守备表示，或里侧表示的怪兽。
function s.filter(c)
	return (c:IsFaceup() and c:IsCanTurnSet()) or c:IsFacedown()
end
-- 效果发动目标的筛选与选择函数：确认存在符合条件的对象后，分别选择自己场上和对方场上的怪兽各1只作为对象，并设置操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 效果发动时检查：自己场上和对方场上是否各自存在至少1只满足s.filter条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示，消息为“请选择要改变表示形式的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择自己场上的1只符合条件的怪兽作为效果对象。
	local g1=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 再次显示选择提示，为选择对方怪兽做准备。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择对方场上的1只符合条件的怪兽作为效果对象。
	local g2=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，声明将处理2只怪兽的表示形式变更（CATEGORY_POSITION）。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g1+g2,2,0,0)
end
-- 效果处理函数：获取仍与效果关联的对象，逐只改变其表示形式。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中获取效果发动时选择的对象，并过滤出仍与效果e相关的卡（处理中离场的卡除外）。
	local gs=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 遍历所有仍关联的对象卡。
	for c in aux.Next(gs) do
		-- 将每张对象怪兽的表示形式反转：表侧表示变为里侧守备表示，里侧表示变为表侧守备表示。
		Duel.ChangePosition(c,c:IsFaceup() and POS_FACEDOWN_DEFENSE or POS_FACEUP_DEFENSE)
	end
end
