--デコード・エンド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「解码语者」为对象才能发动。那只怪兽所连接区的怪兽数量在这个回合让以下效果适用。
-- ●1只以上：那只怪兽的攻击力上升那些所连接区的怪兽数量×500。
-- ●2只以上：那只怪兽战斗破坏的怪兽在伤害计算后除外。
-- ●3只：那只怪兽战斗破坏对方怪兽的伤害计算后发动。对方场上的卡全部破坏。
function c33062423.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只「解码语者」为对象才能发动。那只怪兽所连接区的怪兽数量在这个回合让以下效果适用。
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
-- 定义对象筛选函数：选择我方场上表侧表示、卡名为「解码语者」且所连接区有怪兽的怪兽。
function c33062423.filter(c)
	return c:IsFaceup() and c:IsCode(1861629) and c:GetLinkedGroupCount()>0
end
-- 效果发动时的取对象处理：确认场上存在符合条件的「解码语者」，提示玩家选择1只表侧表示且所连接区有怪兽的「解码语者」作为对象。
function c33062423.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c33062423.filter(chkc) end
	-- 合法性检查：我方场上是否存在至少1只满足条件的「解码语者」可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c33062423.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择表侧表示怪兽的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从我方场上选择1只满足条件的「解码语者」作为对象，并登记为当前连锁的对象。
	Duel.SelectTarget(tp,c33062423.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：获得对象怪兽所连接区的怪兽数量ct，并据此分档适用效果：1只以上提升攻击力；2只以上追加战斗破坏除外；3只时追加破坏对方全场。
function c33062423.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本效果发动时选择的对象怪兽（「解码语者」）。
	local tc=Duel.GetFirstTarget()
	if not (tc:IsFaceup() and tc:IsRelateToEffect(e)) then return end
	local ct=tc:GetLinkedGroupCount()
	if ct>=1 then
		-- ●1只以上：那只怪兽的攻击力上升那些所连接区的怪兽数量×500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(ct*500)
		tc:RegisterEffect(e1)
	end
	if ct>=2 then
		-- ●2只以上：那只怪兽战斗破坏的怪兽在伤害计算后除外。
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
		-- ●3只：那只怪兽战斗破坏对方怪兽的伤害计算后发动。对方场上的卡全部破坏。
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
		-- 将在「解码语者」战斗破坏对方怪兽后破坏对方全场的诱发效果注册到场上并由我方控制，持续到回合结束。
		Duel.RegisterEffect(e3,tp)
	end
end
-- 除外效果的触发条件：我方「解码语者」与怪兽战斗，且该怪兽已被战斗破坏确定。
function c33062423.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	return tp==e:GetOwnerPlayer() and tc and tc:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 除外效果的操作：将被战斗破坏的怪兽取除。
function c33062423.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	-- 将被战斗破坏的怪兽以表侧表示除外，除外原因为效果。
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
-- 破坏效果的触发条件：对象「解码语者」本回合被记录了3只状态，且与对方怪兽战斗并使其被战斗破坏。
function c33062423.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local bc=tc:GetBattleTarget()
	return tc:GetFlagEffect(33062423)~=0 and bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and tc:IsStatus(STATUS_OPPO_BATTLE)
end
-- 破坏效果的目标设定：不取对象，将对方场上所有卡作为破坏对象，并设置操作信息。
function c33062423.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有卡（包括怪兽和魔法陷阱）作为破坏对象集合。
	local sg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	-- 登记操作信息：本次效果将破坏对方场上所有卡，数量为集合中的卡数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 破坏效果的操作：再次获取对方场上所有卡并将它们全部破坏。
function c33062423.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有卡，用于实际破坏处理。
	local sg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	-- 以效果破坏对方场上所有卡。
	Duel.Destroy(sg,REASON_EFFECT)
end
