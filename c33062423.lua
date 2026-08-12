--デコード・エンド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「解码语者」为对象才能发动。那只怪兽所连接区的怪兽数量在这个回合让以下效果适用。
-- ●1只以上：那只怪兽的攻击力上升那些所连接区的怪兽数量×500。
-- ●2只以上：那只怪兽战斗破坏的怪兽在伤害计算后除外。
-- ●3只：那只怪兽战斗破坏对方怪兽的伤害计算后发动。对方场上的卡全部破坏。
function c33062423.initial_effect(c)
	-- 创建发动效果，设置为自由连锁、取对象、发动次数限制为1次
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33062423,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,33062423+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c33062423.target)
	e1:SetOperation(c33062423.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择表侧表示的「解码语者」且连接区有怪兽的怪兽
function c33062423.filter(c)
	return c:IsFaceup() and c:IsCode(1861629) and c:GetLinkedGroupCount()>0
end
-- 处理选择对象的函数，检查是否有满足条件的怪兽并选择一个
function c33062423.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c33062423.filter(chkc) end
	-- 检查是否满足发动条件：场上存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c33062423.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c33062423.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 处理效果发动的主函数，根据连接怪兽数量触发不同效果
function c33062423.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if not (tc:IsFaceup() and tc:IsRelateToEffect(e)) then return end
	local ct=tc:GetLinkedGroupCount()
	if ct>=1 then
		-- ●1只以上：那只怪兽的攻击力上升那些所连接区的怪兽数量×500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(ct*500)
		tc:RegisterEffect(e1)
	end
	if ct>=2 then
		-- ●2只以上：那只怪兽战斗破坏的怪兽在伤害计算后除外
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_BATTLED)
		e2:SetOwnerPlayer(tp)
		e2:SetCondition(c33062423.rmcon)
		e2:SetOperation(c33062423.rmop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2,true)
	end
	if ct==3 then
		tc:RegisterFlagEffect(33062423,RESET_EVENT+0x1220000+RESET_PHASE+PHASE_END,0,1)
		-- ●3只：那只怪兽战斗破坏对方怪兽的伤害计算后发动。对方场上的卡全部破坏
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(33062423,1))
		e3:SetCategory(CATEGORY_DESTROY)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e3:SetCode(EVENT_BATTLED)
		e3:SetLabelObject(tc)
		e3:SetCondition(c33062423.descon)
		e3:SetTarget(c33062423.destg)
		e3:SetOperation(c33062423.desop)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册到玩家全局环境
		Duel.RegisterEffect(e3,tp)
	end
end
-- 判断是否为己方怪兽且战斗破坏的怪兽存在
function c33062423.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	return tp==e:GetOwnerPlayer() and tc and tc:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 将战斗破坏的怪兽除外
function c33062423.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	-- 将目标怪兽除外
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
-- 判断是否为己方怪兽且战斗破坏对方怪兽
function c33062423.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local bc=tc:GetBattleTarget()
	return tc:GetFlagEffect(33062423)~=0 and bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and tc:IsStatus(STATUS_OPPO_BATTLE)
end
-- 设置破坏效果的操作信息
function c33062423.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上的所有卡
	local sg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息为破坏效果，目标为所有对方场上的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 处理破坏效果的函数，将对方场上的所有卡破坏
function c33062423.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡
	local sg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	-- 将对方场上的所有卡破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
