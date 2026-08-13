--スプラッシュ・キャプチャー
-- 效果：
-- 对方超量召唤成功时，把自己墓地2只鱼族怪兽从游戏中除外才能发动。得到那1只超量怪兽的控制权。
function c39765115.initial_effect(c)
	-- 对方超量召唤成功时，把自己墓地2只鱼族怪兽从游戏中除外才能发动。得到那1只超量怪兽的控制权。
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
-- 效果发动条件：判断触发特殊召唤成功的怪兽是否为对方的超量召唤怪兽（召唤类型为超量且控制者为对方），满足时可发动。
function c39765115.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsSummonType(SUMMON_TYPE_XYZ) and tc:IsControler(1-tp)
end
-- 代价筛选函数：过滤自己墓地中满足鱼族种族且可以作为代价除外的怪兽卡。
function c39765115.cfilter(c)
	return c:IsRace(RACE_FISH) and c:IsAbleToRemoveAsCost()
end
-- 支付代价：从自己墓地中选择2张鱼族怪兽除外，作为效果发动的代价。
function c39765115.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 费用检测：确认自己墓地中存在至少2张满足条件的鱼族怪兽，若存在则代价可支付，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c39765115.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 弹出“请选择要除外的卡”的提示，引导玩家选择要作为代价除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地的鱼族怪兽中选择2张卡作为除外的对象。
	local g=Duel.SelectMatchingCard(tp,c39765115.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的2张鱼族怪兽以表侧表示除外，完成代价支付。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果发动时的目标设定与合法性检查：确认触发超量召唤的怪兽可以成为效果对象且控制权可被转移，然后将该怪兽设为对象。
function c39765115.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return eg:GetFirst():IsCanBeEffectTarget(e) and eg:GetFirst():IsControlerCanBeChanged() end
	-- 将这次超量召唤成功的那只怪兽指定为效果处理的对象。
	Duel.SetTargetCard(eg)
	-- 设置操作信息：本次连锁的效果是夺取1只怪兽的控制权，用于相关效果判定。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,eg,1,0,0)
end
-- 效果处理：获取对象怪兽，若其仍在场上且与效果关联，则将其控制权转移给自己。
function c39765115.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽（即超量召唤成功的那只怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽的控制权转移给当前效果发动者（自己）。
		Duel.GetControl(tc,tp)
	end
end
