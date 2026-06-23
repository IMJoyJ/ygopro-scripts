--トイ・ボックス
-- 效果：
-- ①：1回合1次，可以从以下效果选择1个发动。
-- ●从自己的手卡·卡组·怪兽区域（表侧表示）·墓地选原本卡名包含「玩具」的持有可以把自身当作魔法卡使用从手卡到魔法与陷阱区域盖放效果的最多2只怪兽当作魔法卡使用在自己的魔法与陷阱区域盖放。
-- ●自己的魔法与陷阱区域最多2张卡破坏。
-- ②：1回合1次，对方怪兽的攻击宣言时，把自己场上1张里侧表示卡送去墓地才能发动。那只对方怪兽破坏。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡的发动效果和两个起动效果，以及一个诱发效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果①的第一个选项：从手卡·卡组·怪兽区域·墓地选择最多2只原本卡名包含「玩具」且可以当作魔法卡使用的怪兽，将其当作魔法卡在自己的魔法与陷阱区域盖放
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"盖放怪兽"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetTarget(s.sttg)
	e2:SetOperation(s.stop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,1))  --"破坏自己魔法陷阱区域的卡"
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	-- 效果①的第二个选项：破坏自己魔法与陷阱区域最多2张卡
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.dmcon)
	e4:SetCost(s.dmcost)
	e4:SetTarget(s.dmtg)
	e4:SetOperation(s.dmop)
	c:RegisterEffect(e4)
end
-- 过滤函数：判断怪兽是否为怪兽卡、属于玩具卡组、可以盖放、具有将自身当作魔法卡使用的特殊效果且表侧表示
function s.stfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1a8) and c:IsSSetable()
		and c.set_as_spell and c:IsFaceupEx()
end
-- 效果①的第一个选项的发动条件判断：检查玩家手卡·卡组·怪兽区域·墓地是否存在满足条件的怪兽
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
end
-- 效果①的第一个选项的处理函数：提示玩家选择要盖放的怪兽并执行盖放操作
function s.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 计算玩家魔法与陷阱区域可盖放的最大数量（最多2张）
	local ct=math.min(Duel.GetLocationCount(tp,LOCATION_SZONE),2)
	-- 选择满足条件的怪兽数量（1至最大数量）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.stfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE,0,1,ct,nil)
	-- 将选中的怪兽盖放到魔法与陷阱区域
	Duel.SSet(tp,g)
end
-- 过滤函数：判断卡片是否在魔法与陷阱区域且为自己的魔法与陷阱区域的前5个位置（即非额外区域）
function s.desfilter(c)
	return c:GetSequence()<5
end
-- 效果①的第二个选项的发动条件判断：检查玩家魔法与陷阱区域是否有卡
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取玩家魔法与陷阱区域的所有卡
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_SZONE,0,nil)
	if g:GetCount()>0 then
		-- 设置操作信息：准备破坏魔法与陷阱区域的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果①的第二个选项的处理函数：提示玩家选择要破坏的卡并执行破坏操作
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家魔法与陷阱区域的所有卡
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_SZONE,0,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,2,nil)
		-- 破坏选中的卡
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
-- 攻击宣言时的触发条件：判断当前玩家不是攻击玩家
function s.dmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前玩家不是攻击玩家
	return tp~=Duel.GetTurnPlayer()
end
-- 过滤函数：判断卡片是否为里侧表示且可以送去墓地作为费用
function s.cfilter(c,tp)
	return c:IsFacedown() and c:IsAbleToGraveAsCost()
end
-- 攻击宣言时效果的费用支付处理函数：检查并选择一张里侧表示的卡送去墓地作为费用
function s.dmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否存在满足条件的卡作为费用
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,c,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择一张里侧表示的卡送去墓地作为费用
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,c,tp)
	-- 将选中的卡送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 攻击宣言时效果的目标设定函数：设置攻击怪兽为处理对象
function s.dmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前攻击的怪兽
	local ac=Duel.GetAttacker()
	if chk==0 then return ac:IsOnField() end
	-- 设置当前连锁的目标为攻击怪兽
	Duel.SetTargetCard(ac)
	-- 设置操作信息：准备破坏攻击怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,ac,1,0,0)
end
-- 攻击宣言时效果的处理函数：破坏目标怪兽
function s.dmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local ac=Duel.GetFirstTarget()
	if ac:IsRelateToEffect(e) and ac:IsControler(1-tp) and ac:IsType(TYPE_MONSTER) then
		-- 破坏目标怪兽
		Duel.Destroy(ac,REASON_EFFECT)
	end
end
