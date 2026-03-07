--音響戦士ピアーノ
-- 效果：
-- 宣言1个种族，选择场上表侧表示存在的1只名字带有「音响战士」的怪兽发动。选择的怪兽变成宣言的种族。这个效果1回合只能使用1次。此外，宣言1个种族，可以把自己墓地存在的这张卡从游戏中除外，自己场上表侧表示存在的1只名字带有「音响战士」的怪兽变成宣言的种族。
function c31826057.initial_effect(c)
	-- 宣言1个种族，选择场上表侧表示存在的1只名字带有「音响战士」的怪兽发动。选择的怪兽变成宣言的种族。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31826057,0))  --"种族变化"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c31826057.target1)
	e1:SetOperation(c31826057.operation)
	c:RegisterEffect(e1)
	-- 此外，宣言1个种族，可以把自己墓地存在的这张卡从游戏中除外，自己场上表侧表示存在的1只名字带有「音响战士」的怪兽变成宣言的种族。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31826057,0))  --"种族变化"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 将此卡从游戏中除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c31826057.target2)
	e2:SetOperation(c31826057.operation)
	c:RegisterEffect(e2)
end
-- 判断目标是否为表侧表示且为音响战士族
function c31826057.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1066)
end
-- 选择场上表侧表示存在的1只名字带有「音响战士」的怪兽作为对象
function c31826057.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c31826057.filter(chkc) end
	-- 检查场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c31826057.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c31826057.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 提示玩家宣言种族
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 宣言一个种族
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL-g:GetFirst():GetRace())
	e:SetLabel(rc)
end
-- 选择自己场上表侧表示存在的1只名字带有「音响战士」的怪兽作为对象
function c31826057.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c31826057.filter(chkc) end
	-- 检查自己场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c31826057.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c31826057.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家宣言种族
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 宣言一个种族
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL-g:GetFirst():GetRace())
	e:SetLabel(rc)
end
-- 将选择的怪兽种族改变为宣言的种族
function c31826057.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 改变目标怪兽的种族
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(e:GetLabel())
		tc:RegisterEffect(e1)
	end
end
