--ギルフォード・ザ・レジェンド
-- 效果：
-- 这张卡不能特殊召唤。这张卡召唤成功时，可以把自己墓地存在的装备卡尽可能装备到自己场上的战士族怪兽上。
function c69933858.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡召唤成功时，可以把自己墓地存在的装备卡尽可能装备到自己场上的战士族怪兽上。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69933858,0))  --"装备"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c69933858.target)
	e2:SetOperation(c69933858.operation)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的战士族怪兽
function c69933858.efilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 过滤墓地中可以装备给场上战士族怪兽的装备卡
function c69933858.eqfilter(c,g)
	return c:IsType(TYPE_EQUIP) and g:IsExists(c69933858.eqcheck,1,nil,c)
end
-- 检查装备卡是否可以装备给目标怪兽
function c69933858.eqcheck(c,ec)
	return ec:CheckEquipTarget(c)
end
-- 效果发动的可行性检查与操作信息设置
function c69933858.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己场上是否有可用的魔法与陷阱区域
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return false end
		-- 获取自己场上所有表侧表示的战士族怪兽
		local g=Duel.GetMatchingGroup(c69933858.efilter,tp,LOCATION_MZONE,0,nil)
		-- 检查自己墓地是否存在至少1张可以装备给场上战士族怪兽的装备卡
		return Duel.IsExistingMatchingCard(c69933858.eqfilter,tp,LOCATION_GRAVE,0,1,nil,g)
	end
	-- 设置操作信息，表示有卡片将离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
-- 效果处理，将墓地的装备卡尽可能装备给场上的战士族怪兽
function c69933858.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的魔法与陷阱区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	-- 获取自己场上所有表侧表示的战士族怪兽
	local g=Duel.GetMatchingGroup(c69933858.efilter,tp,LOCATION_MZONE,0,nil)
	-- 获取自己墓地中所有可以装备给场上战士族怪兽的装备卡
	local eq=Duel.GetMatchingGroup(c69933858.eqfilter,tp,LOCATION_GRAVE,0,nil,g)
	if ft>eq:GetCount() then ft=eq:GetCount() end
	if ft==0 then return end
	for i=1,ft do
		-- 提示玩家选择要装备的装备卡
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(69933858,1))  --"请选择装备魔法卡"
		local ec=eq:Select(tp,1,1,nil):GetFirst()
		eq:RemoveCard(ec)
		local tc=g:FilterSelect(tp,c69933858.eqcheck,1,1,nil,ec):GetFirst()
		-- 将选中的装备卡装备给选中的战士族怪兽（分步进行）
		Duel.Equip(tp,ec,tc,true,true)
	end
	-- 结束装备卡装备流程，触发相关时点
	Duel.EquipComplete()
end
