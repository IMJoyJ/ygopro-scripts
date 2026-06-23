--はぐれ者傭兵部隊
-- 效果：
-- 自己场上没有这张卡以外的怪兽存在的场合，把这张卡解放才能发动。选择对方场上1只怪兽直到结束阶段时得到控制权。这个效果发动的回合，自己不能把怪兽特殊召唤，不能进行战斗阶段。
function c12836042.initial_effect(c)
	-- 创建效果，描述为“获得控制权”，分类为改变控制权，具有取对象特性，类型为起动效果，适用区域为主怪兽区，条件为己方场上只有这张卡或没有其他怪兽，费用为支付条件，目标为对方怪兽，效果为发动时处理
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12836042,0))  --"获得控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c12836042.condition)
	e1:SetCost(c12836042.cost)
	e1:SetTarget(c12836042.target)
	e1:SetOperation(c12836042.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件函数，判断己方场上是否只有这张卡或没有其他怪兽
function c12836042.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回己方场上怪兽数量是否小于等于1
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<=1
end
-- 效果费用函数，检查是否可以发动效果
function c12836042.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方是否在本回合未进入过战斗阶段
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0
		-- 检查己方是否在本回合未进行过特殊召唤
		and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0
		and e:GetHandler():IsReleasable() end
	-- 创建并注册不能特殊召唤效果，使己方在结束阶段前不能特殊召唤怪兽，再创建并注册不能进入战斗阶段效果，使己方在结束阶段前不能进入战斗阶段，然后解放自身作为费用
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤效果注册给发动玩家
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BP)
	-- 将不能进入战斗阶段效果注册给发动玩家
	Duel.RegisterEffect(e2,tp)
	-- 将自身解放作为发动费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果目标函数，用于选择对方怪兽作为目标
function c12836042.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	-- 检查己方是否有足够的怪兽区域来发动效果
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler(),tp,LOCATION_REASON_CONTROL)>0
		-- 检查对方场上是否存在可改变控制权的怪兽
		and Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil,true) end
	-- 提示发动玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	-- 选择对方场上一只可改变控制权的怪兽作为目标
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，说明效果将改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理函数，处理效果的发动
function c12836042.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 使目标怪兽直到结束阶段获得发动玩家的控制权
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
