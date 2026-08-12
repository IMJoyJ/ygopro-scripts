--百機夜工
-- 效果：
-- 自己墓地存在的名字带有「变形斗士」的怪兽全部从游戏中除外。自己场上表侧表示存在的1只机械族怪兽的攻击力直到这个回合的结束阶段时这个效果每除外1只怪兽上升200。
function c7030340.initial_effect(c)
	-- 自己墓地存在的名字带有「变形斗士」的怪兽全部从游戏中除外。自己场上表侧表示存在的1只机械族怪兽的攻击力直到这个回合的结束阶段时这个效果每除外1只怪兽上升200。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c7030340.target)
	e1:SetOperation(c7030340.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中可以除外的「变形斗士」怪兽
function c7030340.filter1(c)
	return c:IsSetCard(0x26) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 过滤场上表侧表示的机械族怪兽
function c7030340.filter2(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
-- 效果发动时的对象选择与效果处理准备
function c7030340.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c7030340.filter2(chkc) end
	if chk==0 then
		-- 检查自己墓地是否存在至少1张可以除外的「变形斗士」怪兽
		return Duel.IsExistingMatchingCard(c7030340.filter1,tp,LOCATION_GRAVE,0,1,nil)
			-- 检查自己场上是否存在至少1只可以作为效果对象的表侧表示机械族怪兽
			and Duel.IsExistingTarget(c7030340.filter2,tp,LOCATION_MZONE,0,1,nil)
	end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的机械族怪兽作为效果对象
	Duel.SelectTarget(tp,c7030340.filter2,tp,LOCATION_MZONE,0,1,1,nil)
	-- 获取自己墓地中所有满足条件的「变形斗士」怪兽
	local rg=Duel.GetMatchingGroup(c7030340.filter1,tp,LOCATION_GRAVE,0,nil)
	-- 设置效果处理信息，为将自己墓地中所有的「变形斗士」怪兽除外作准备
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,rg:GetCount(),0,0)
end
-- 效果处理的核心逻辑，执行除外并提升攻击力
function c7030340.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己墓地中所有满足条件的「变形斗士」怪兽
	local g=Duel.GetMatchingGroup(c7030340.filter1,tp,LOCATION_GRAVE,0,nil)
	-- 将获取到的「变形斗士」怪兽全部表侧表示除外，并记录实际除外的数量
	local ct=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	-- 获取在发动时选择的作为效果对象的机械族怪兽
	local tc=Duel.GetFirstTarget()
	if ct>0 and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 攻击力直到这个回合的结束阶段时这个效果每除外1只怪兽上升200
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
