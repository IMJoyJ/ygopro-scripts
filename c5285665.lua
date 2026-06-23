--E・HERO バブルマン・ネオ
-- 效果：
-- 这张卡不能通常召唤。把自己场上存在的「元素英雄 水泡侠」和手卡的「突然变异」送去墓地的场合才能特殊召唤。只要这张卡在场上表侧表示存在，卡名当作「元素英雄 水泡侠」使用。和这张卡进行战斗的怪兽在伤害步骤结束时破坏。
function c5285665.initial_effect(c)
	-- 记录该卡具有「元素英雄 水泡侠」和「突然变异」的卡号
	aux.AddCodeList(c,79979666,46411259)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上存在的「元素英雄 水泡侠」和手卡的「突然变异」送去墓地的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c5285665.spcon)
	e2:SetTarget(c5285665.sptg)
	e2:SetOperation(c5285665.spop)
	c:RegisterEffect(e2)
	-- 使该卡在场上表侧表示存在时，其卡名视为「元素英雄 水泡侠」
	aux.EnableChangeCode(c,79979666)
	-- 和这张卡进行战斗的怪兽在伤害步骤结束时破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(5285665,0))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	-- 判断该效果是否因参与战斗而触发
	e4:SetCondition(aux.dsercon)
	e4:SetTarget(c5285665.destg)
	e4:SetOperation(c5285665.desop)
	c:RegisterEffect(e4)
end
-- 过滤手牌或场上的卡，筛选出卡号为「元素英雄 水泡侠」或「突然变异」且能送入墓地的卡
function c5285665.spfilter(c)
	return c:IsCode(79979666,46411259) and c:IsAbleToGraveAsCost()
end
-- 筛选场上的「元素英雄 水泡侠」，要求其正面表示且位于怪兽区且有可用怪兽区
function c5285665.spfilter1(c,tp)
	-- 判断该卡是否为「元素英雄 水泡侠」且正面表示且在怪兽区且当前玩家有可用怪兽区
	return c:IsCode(79979666) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and Duel.GetMZoneCount(tp,c)>0
end
-- 筛选手牌中的「突然变异」，要求其在手牌中
function c5285665.spfilter2(c)
	return c:IsCode(46411259) and c:IsLocation(LOCATION_HAND)
end
-- 判断特殊召唤条件是否满足：即场上有至少一张「元素英雄 水泡侠」和一张「突然变异」
function c5285665.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取当前玩家手牌与场上的所有卡
	local g=Duel.GetMatchingGroup(c5285665.spfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	-- 检查是否有恰好两张卡，分别满足「元素英雄 水泡侠」和「突然变异」的条件
	return g:CheckSubGroup(aux.gffcheck,2,2,c5285665.spfilter1,tp,c5285665.spfilter2,nil)
end
-- 选择满足条件的两张卡并设置为特殊召唤的代价
function c5285665.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家手牌与场上的所有卡
	local g=Duel.GetMatchingGroup(c5285665.spfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从符合条件的卡中选出一张「元素英雄 水泡侠」和一张「突然变异」
	local sg=g:SelectSubGroup(tp,aux.gffcheck,true,2,2,c5285665.spfilter1,tp,c5285665.spfilter2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤的处理，将选中的卡送入墓地
function c5285665.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡以特殊召唤理由送入墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 设置破坏效果的目标为该卡战斗中的对方怪兽
function c5285665.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc and bc:IsRelateToBattle() end
	-- 设置连锁操作信息，表示将要破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- 执行破坏效果，将战斗中的对方怪兽破坏
function c5285665.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 以效果原因破坏目标怪兽
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
