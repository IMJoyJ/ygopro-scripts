--プリベント・スター
-- 效果：
-- 自己场上表侧攻击表示存在的怪兽的表示形式改变为表侧守备表示的回合，那只怪兽才能装备。选择对方场上存在的1只怪兽。那只怪兽不能作攻击和表示形式的改变。装备怪兽被破坏让这张卡送去墓地时，选择的对方怪兽从游戏中除外。
function c94303232.initial_effect(c)
	-- 自己场上表侧攻击表示存在的怪兽的表示形式改变为表侧守备表示的回合，那只怪兽才能装备。选择对方场上存在的1只怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c94303232.target)
	e1:SetOperation(c94303232.operation)
	c:RegisterEffect(e1)
	-- 自己场上表侧攻击表示存在的怪兽的表示形式改变为表侧守备表示的回合，那只怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c94303232.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽被破坏让这张卡送去墓地时，选择的对方怪兽从游戏中除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(94303232,0))  --"除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c94303232.rmcon)
	e3:SetTarget(c94303232.rmtg)
	e3:SetOperation(c94303232.rmop)
	e3:SetLabelObject(e1)
	c:RegisterEffect(e3)
	-- 那只怪兽不能作攻击和表示形式的改变。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_TARGET)
	e4:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTarget(c94303232.efftg)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e5)
	if not c94303232.global_check then
		c94303232.global_check=true
		-- 自己场上表侧攻击表示存在的怪兽的表示形式改变为表侧守备表示的回合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHANGE_POS)
		ge1:SetOperation(c94303232.checkop)
		-- 注册全局效果，用于记录本回合内表示形式发生改变的怪兽
		Duel.RegisterEffect(ge1,0)
	end
end
-- 检查并记录从表侧攻击表示变为表侧守备表示的怪兽，给其添加Flag
function c94303232.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsPreviousPosition(POS_FACEUP_ATTACK) and tc:IsPosition(POS_FACEUP_DEFENSE) then
			tc:RegisterFlagEffect(94303232,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
		tc=eg:GetNext()
	end
end
-- 装备限制：只能装备给本回合改变过表示形式的怪兽，或者已经装备了此卡的怪兽
function c94303232.eqlimit(e,c)
	return c:GetFlagEffect(94303232)~=0 or c:GetFlagEffect(94303233)~=0
end
-- 过滤出本回合内从表侧攻击表示变为表侧守备表示的表侧表示怪兽
function c94303232.filter(c)
	return c:IsFaceup() and c:GetFlagEffect(94303232)~=0
end
-- 效果发动时的对象选择：选择1只符合条件的自己怪兽作为装备对象，以及1只对方场上的怪兽作为效果对象
function c94303232.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在符合装备条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c94303232.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在可以作为对象的怪兽
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只符合条件的怪兽作为装备对象
	Duel.SelectTarget(tp,c94303232.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择对方场上的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 选择对方场上1只怪兽作为效果对象，并将其保存在LabelObject中
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	e:SetLabelObject(g:GetFirst())
end
-- 效果处理：将此卡装备给选择的自己怪兽，并建立与选择的对方怪兽的联系
function c94303232.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dc=e:GetLabelObject()
	-- 获取当前连锁中选择的所有对象卡片（包括装备对象和对方怪兽）
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if dc==tc then tc=g:GetNext() end
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 如果成功将此卡装备给目标怪兽，且选择的对方怪兽仍合法存在
		if Duel.Equip(tp,c,tc) and dc:IsRelateToEffect(e) then
			tc:RegisterFlagEffect(94303233,RESET_EVENT+RESETS_STANDARD,0,1)
			c:SetCardTarget(dc)
		end
	end
end
-- 过滤出非装备怪兽（即选择的对方怪兽），使其受到不能攻击和改变表示形式的效果影响
function c94303232.efftg(e,c)
	return c~=e:GetHandler():GetEquipTarget()
end
-- 检查除外效果的发动条件：此卡因装备怪兽被破坏而送去墓地，且存在被选择的对方怪兽
function c94303232.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_LOST_TARGET) and c:GetPreviousEquipTarget():IsReason(REASON_DESTROY)
		and c:IsHasCardTarget(e:GetLabelObject():GetLabelObject())
end
-- 除外效果的Target函数：将之前选择的对方怪兽设为效果处理对象，并设置除外操作信息
function c94303232.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetLabelObject():GetLabelObject()
	-- 将选择的对方怪兽设置为当前连锁的效果处理对象
	Duel.SetTargetCard(tc)
	-- 设置效果处理信息为：将1张目标卡片除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,0,0)
end
-- 除外效果的Operation函数：将作为对象的对方怪兽除外
function c94303232.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取要除外的目标对方怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
