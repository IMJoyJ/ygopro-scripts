--音響戦士ベーシス
-- 效果：
-- ①：1回合1次，以场上1只「音响战士」怪兽为对象才能发动。直到回合结束时，那只怪兽的等级上升手卡数量的数值。
-- ②：把墓地的这张卡除外，以自己场上1只「音响战士」怪兽为对象才能发动。直到回合结束时，那只自己的「音响战士」怪兽的等级上升手卡数量的数值。
function c68933343.initial_effect(c)
	-- ①：1回合1次，以场上1只「音响战士」怪兽为对象才能发动。直到回合结束时，那只怪兽的等级上升手卡数量的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68933343,0))  --"等级上升"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c68933343.target1)
	e1:SetOperation(c68933343.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「音响战士」怪兽为对象才能发动。直到回合结束时，那只自己的「音响战士」怪兽的等级上升手卡数量的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68933343,0))  --"等级上升"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 将墓地的这张卡除外作为发动的Cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c68933343.target2)
	e2:SetOperation(c68933343.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示、等级1以上且属于「音响战士」系列的怪兽
function c68933343.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1066) and c:IsLevelAbove(1)
end
-- 效果1的Target函数：检查发动条件并选择场上1只「音响战士」怪兽作为对象
function c68933343.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c68933343.filter(chkc) end
	-- 在发动阶段（chk==0）时，检查自己手牌数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		-- 并且场上存在至少1只符合条件的「音响战士」怪兽可以作为对象
		and Duel.IsExistingTarget(c68933343.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的「音响战士」怪兽作为效果对象
	Duel.SelectTarget(tp,c68933343.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果2的Target函数：检查发动条件并选择自己场上1只「音响战士」怪兽作为对象
function c68933343.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c68933343.filter(chkc) end
	-- 在发动阶段（chk==0）时，检查自己手牌数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		-- 并且自己场上存在至少1只符合条件的「音响战士」怪兽可以作为对象
		and Duel.IsExistingTarget(c68933343.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「音响战士」怪兽作为效果对象
	Duel.SelectTarget(tp,c68933343.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果1和效果2通用的Operation函数：使作为对象的怪兽等级上升自己手牌数量的数值，直到回合结束
function c68933343.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果锁定的第一个对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 获取自己手牌的数量
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	if ct>0 and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 直到回合结束时，那只怪兽的等级上升手卡数量的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(ct)
		tc:RegisterEffect(e1)
	end
end
