--音響戦士ドラムス
-- 效果：
-- 宣言1个属性，选择场上表侧表示存在的1只名字带有「音响战士」的怪兽发动。选择的怪兽变成宣言的属性。这个效果1回合只能使用1次。此外，宣言1个属性，可以把自己墓地存在的这张卡从游戏中除外，自己场上表侧表示存在的1只名字带有「音响战士」的怪兽变成宣言的属性。
function c94331452.initial_effect(c)
	-- 宣言1个属性，选择场上表侧表示存在的1只名字带有「音响战士」的怪兽发动。选择的怪兽变成宣言的属性。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94331452,0))  --"属性变化"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c94331452.target1)
	e1:SetOperation(c94331452.operation)
	c:RegisterEffect(e1)
	-- 此外，宣言1个属性，可以把自己墓地存在的这张卡从游戏中除外，自己场上表侧表示存在的1只名字带有「音响战士」的怪兽变成宣言的属性。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94331452,0))  --"属性变化"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 将墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c94331452.target2)
	e2:SetOperation(c94331452.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的名字带有「音响战士」的怪兽
function c94331452.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1066)
end
-- 效果1的发动准备：选择场上1只表侧表示的「音响战士」怪兽作为对象，并宣言1个与其当前属性不同的属性
function c94331452.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c94331452.filter(chkc) end
	-- 在发动时，检查场上是否存在可以作为对象的表侧表示「音响战士」怪兽
	if chk==0 then return Duel.IsExistingTarget(c94331452.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的「音响战士」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c94331452.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 提示玩家选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家宣言1个与所选怪兽当前属性不同的属性，并将宣言的属性保存在效果的Label中
	local rc=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~g:GetFirst():GetAttribute())
	e:SetLabel(rc)
end
-- 效果2的发动准备：选择自己场上1只表侧表示的「音响战士」怪兽作为对象，并宣言1个与其当前属性不同的属性
function c94331452.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c94331452.filter(chkc) end
	-- 在发动时，检查自己场上是否存在可以作为对象的表侧表示「音响战士」怪兽
	if chk==0 then return Duel.IsExistingTarget(c94331452.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「音响战士」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c94331452.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家宣言1个与所选怪兽当前属性不同的属性，并将宣言的属性保存在效果的Label中
	local rc=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~g:GetFirst():GetAttribute())
	e:SetLabel(rc)
end
-- 效果处理：使作为对象的怪兽变成宣言的属性
function c94331452.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的怪兽变成宣言的属性
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(e:GetLabel())
		tc:RegisterEffect(e1)
	end
end
