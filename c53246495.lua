--インフェルニティ・クイーン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在墓地存在，自己手卡是0张的场合，从自己墓地把1只暗属性怪兽除外，以自己场上1只暗属性怪兽为对象才能发动。这个回合，那只怪兽可以直接攻击。
local s,id,o=GetID()
-- 注册永火王后的起动效果，该效果为暗属性怪兽直接攻击效果
function s.initial_effect(c)
	-- ①：这张卡在墓地存在，自己手卡是0张的场合，从自己墓地把1只暗属性怪兽除外，以自己场上1只暗属性怪兽为对象才能发动。这个回合，那只怪兽可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"直接攻击"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 判断是否满足效果发动条件：自己手牌数量为0且当前回合玩家可以进入战斗阶段
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 自己手牌数量为0且当前回合玩家可以进入战斗阶段
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 and Duel.IsAbleToEnterBP()
end
-- 过滤函数，用于筛选墓地中的暗属性可除外怪兽
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 处理效果的费用：从墓地选择1只暗属性怪兽除外作为代价
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足费用条件：墓地中存在至少1只暗属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地选择1只暗属性怪兽作为除外对象
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽从游戏中除外，作为效果发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数，用于筛选场上正面表示的暗属性且未获得直接攻击效果的怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:GetEffectCount(EFFECT_DIRECT_ATTACK)==0
end
-- 设置效果的对象选择：选择自己场上的1只符合条件的暗属性怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 检查是否满足选择对象条件：自己场上存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示选择要攻击的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只符合条件的暗属性怪兽作为效果对象
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 执行效果：使目标怪兽获得直接攻击效果
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽可以直接攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
