--見えざる導き手
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把自己场上1只「不可见之手」怪兽或者原本持有者是对方的怪兽解放才能发动。得到对方场上1只怪兽的控制权。
-- ②：自己结束阶段发动。自己场上1张卡送去墓地。
local s,id,o=GetID()
-- 注册场地魔法卡的发动效果和两个连锁效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：把自己场上1只「不可见之手」怪兽或者原本持有者是对方的怪兽解放才能发动。得到对方场上1只怪兽的控制权。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"获取控制权"
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.ctcost)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	-- ②：自己结束阶段发动。自己场上1张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
-- 判断解放的怪兽是否满足条件：是「不可见之手」卡组或原本持有者是对方，且有可用怪兽区，且对方场上存在可控制的怪兽
function s.cfilter(c,tp)
	return (c:IsSetCard(0x1d3) or c:GetOwner()==1-tp)
		-- 判断当前玩家场上是否有可用怪兽区
		and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
		-- 判断对方场上是否存在可控制的怪兽
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,0,LOCATION_MZONE,1,c,true)
end
-- 支付解放费用：选择满足条件的怪兽进行解放
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以支付解放费用
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,tp) end
	-- 选择要解放的怪兽
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,tp)
	-- 执行解放操作
	Duel.Release(g,REASON_COST)
end
-- 筛选可控制的怪兽
function s.tgfilter(c,ignore)
	return c:IsControlerCanBeChanged(ignore)
end
-- 设置控制权效果的目标
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足控制权效果的发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,0,LOCATION_MZONE,1,nil,true) end
	-- 设置控制权效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
-- 执行控制权效果：选择对方怪兽并获得其控制权
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上可控制的怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil,false)
	local tc=g:GetFirst()
	if tc then
		-- 显示选中的怪兽被选为对象
		Duel.HintSelection(g)
		-- 获得选中怪兽的控制权
		Duel.GetControl(tc,tp)
	end
end
-- 判断是否为自己的结束阶段
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 设置送去墓地效果的目标
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置送去墓地效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_ONFIELD)
end
-- 执行送去墓地效果：选择场上一张卡送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上可送去墓地的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,0,1,1,nil)
	if g:GetCount()>0 then
		-- 显示选中的卡被选为对象
		Duel.HintSelection(g)
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
