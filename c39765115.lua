--スプラッシュ・キャプチャー
-- 效果：
-- 对方超量召唤成功时，把自己墓地2只鱼族怪兽从游戏中除外才能发动。得到那1只超量怪兽的控制权。
function c39765115.initial_effect(c)
	-- 创建效果，设置为发动时改变控制权的效果，触发条件为对方特殊召唤成功，需要取对象
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c39765115.condition)
	e1:SetCost(c39765115.cost)
	e1:SetTarget(c39765115.target)
	e1:SetOperation(c39765115.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：对方超量召唤成功
function c39765115.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsSummonType(SUMMON_TYPE_XYZ) and tc:IsControler(1-tp)
end
-- 费用卡片过滤器：墓地的鱼族怪兽且能作为费用除外
function c39765115.cfilter(c)
	return c:IsRace(RACE_FISH) and c:IsAbleToRemoveAsCost()
end
-- 发动费用：检索满足条件的2只鱼族怪兽从游戏中除外
function c39765115.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动费用条件
	if chk==0 then return Duel.IsExistingMatchingCard(c39765115.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择2只满足条件的鱼族怪兽
	local g=Duel.SelectMatchingCard(tp,c39765115.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的卡从游戏中除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果的目标和操作信息：将对方超量怪兽的控制权转移给自己
function c39765115.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return eg:GetFirst():IsCanBeEffectTarget(e) and eg:GetFirst():IsControlerCanBeChanged() end
	-- 设置连锁对象为对方超量召唤的怪兽
	Duel.SetTargetCard(eg)
	-- 设置操作信息为改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,eg,1,0,0)
end
-- 效果处理：获得目标怪兽的控制权
function c39765115.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽的控制权转移给使用者
		Duel.GetControl(tc,tp)
	end
end
