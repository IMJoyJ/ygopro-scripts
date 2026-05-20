--エレメンタルバースト
-- 效果：
-- 自己场上存在的风·水·炎·地属性的怪兽各1只作为祭品才能发动。对方场上存在的卡全部破坏。
function c61411502.initial_effect(c)
	-- 自己场上存在的风·水·炎·地属性的怪兽各1只作为祭品才能发动。对方场上存在的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCost(c61411502.cost)
	e1:SetTarget(c61411502.target)
	e1:SetOperation(c61411502.activate)
	c:RegisterEffect(e1)
end
-- 创建用于检查风、水、炎、地属性的条件检查函数数组
c61411502.rchecks=aux.CreateChecks(Card.IsAttribute,{ATTRIBUTE_WIND,ATTRIBUTE_WATER,ATTRIBUTE_FIRE,ATTRIBUTE_EARTH})
-- 定义解放怪兽组的选择目标条件函数，确保解放后对方场上仍有卡片可以破坏
function c61411502.rgoal(g,tp)
	-- 检查对方场上是否存在至少1张卡（排除当前选作解放的卡）
	return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,g)
end
-- 发动代价（Cost）函数：解放自己场上风、水、炎、地属性怪兽各1只
function c61411502.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上可解放的卡片组
	local g=Duel.GetReleaseGroup(tp)
	if chk==0 then return g:CheckSubGroupEach(c61411502.rchecks,c61411502.rgoal,tp) end
	-- 给玩家发送“请选择要解放的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local rg=g:SelectSubGroupEach(tp,c61411502.rchecks,false,c61411502.rgoal,tp)
	-- 应用代替解放效果的次数限制（如暗影敌托邦等）
	aux.UseExtraReleaseCount(rg,tp)
	-- 将选定的怪兽作为发动代价解放
	Duel.Release(rg,REASON_COST)
end
-- 效果的目标（Target）函数：确认对方场上有卡存在，并设置破坏的操作信息
function c61411502.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认对方场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁的操作信息，表示该效果将破坏对方场上的所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理（Operation）函数：破坏对方场上的所有卡
function c61411502.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 破坏获取到的对方场上的所有卡片
	Duel.Destroy(g,REASON_EFFECT)
end
