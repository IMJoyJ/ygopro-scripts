--オメガの裁き
-- 效果：
-- ①：以自己的魔法与陷阱区域1张表侧表示的怪兽卡和对方场上2张卡为对象才能发动。那些卡破坏。
local s,id,o=GetID()
-- 创建并注册一张发动时点为自由时点、具有取对象效果、破坏类别的魔法卡效果
function s.initial_effect(c)
	-- ①：以自己的魔法与陷阱区域1张表侧表示的怪兽卡和对方场上2张卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
-- 定义用于筛选目标的函数，检查对象是否为表侧表示的怪兽卡
function s.filter(c)
	return c:IsFaceup() and c:GetOriginalType()&TYPE_MONSTER>0 and c:GetSequence()<5
end
-- 处理效果的发动条件判断，检查是否满足选择目标的条件
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己魔法与陷阱区域是否存在1张表侧表示的怪兽卡
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_SZONE,0,1,nil)
		-- 检查对方场上是否存在2张卡
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,2,nil) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己魔法与陷阱区域1张表侧表示的怪兽卡作为目标
	local g1=Duel.SelectTarget(tp,s.filter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上2张卡作为目标
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,2,2,nil)
	g1:Merge(g2)
	-- 设置本次连锁的操作信息，包括破坏类别和目标卡组
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,#g1,0,0)
end
-- 处理效果的发动后操作，获取并破坏目标卡
function s.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次连锁中被选为目标的卡，并筛选出与当前效果相关的卡
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 以效果原因破坏目标卡组中的卡
	Duel.Destroy(tg,REASON_EFFECT)
end
