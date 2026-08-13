--デッド・ガードナー
-- 效果：
-- 自己场上表侧表示存在的怪兽被选择作为攻击对象时，可以让攻击对象改变为这张卡。这张卡被破坏送去墓地时，对方场上表侧表示存在的1只怪兽的攻击力直到结束阶段时下降1000。
function c59965151.initial_effect(c)
	-- 自己场上表侧表示存在的怪兽被选择作为攻击对象时，可以让攻击对象改变为这张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59965151,0))  --"攻击对象变更"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c59965151.cbcon)
	e1:SetTarget(c59965151.cbtg)
	e1:SetOperation(c59965151.cbop)
	c:RegisterEffect(e1)
	-- 这张卡被破坏送去墓地时，对方场上表侧表示存在的1只怪兽的攻击力直到结束阶段时下降1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59965151,1))  --"攻击下降"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c59965151.atkcon)
	e2:SetTarget(c59965151.atktg)
	e2:SetOperation(c59965151.atkop)
	c:RegisterEffect(e2)
end
-- 该条件函数判定：本卡不是被选为攻击对象的怪兽，且被选对象为表侧表示、控制权与本卡相同，即只有自己场上其他表侧怪兽成为攻击对象时才能发动。
function c59965151.cbcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bt=eg:GetFirst()
	return c~=bt and bt:IsFaceup() and bt:GetControler()==c:GetControler()
end
-- 该目标函数用于确认发动合法：在效果发动时检查攻击怪兽当前可攻击的目标列表中是否包含这张卡，以保证能够将攻击对象合法变更为本卡。
function c59965151.cbtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动确认阶段，判断攻击怪兽的可攻击对象中是否包含本卡，若包含则允许发动。
	if chk==0 then return Duel.GetAttacker():GetAttackableTarget():IsContains(e:GetHandler()) end
end
-- 该操作函数处理转移攻击对象：若本卡仍与效果相关且攻击怪兽不免疫此效果，则将攻击对象变更为这张卡。
function c59965151.cbop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断本卡是否仍在场上且效果处理有效，同时攻击怪兽没有对此效果的免疫能力，满足条件才执行转移。
	if c:IsRelateToEffect(e) and not Duel.GetAttacker():IsImmuneToEffect(e) then
		-- 通过调用Duel.ChangeAttackTarget将当前战斗的攻击对象强制变更为这张卡。
		Duel.ChangeAttackTarget(c)
	end
end
-- 该条件函数判定：只有这张卡是被破坏而送去墓地时，后续下降攻击力的效果才会触发。
function c59965151.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 该目标函数负责选择对象：若已指定对象则检查其是否为对方场上表侧怪兽；若无对象则返回可以发动，然后提示玩家选择并选定1只对方场上表侧表示怪兽。
function c59965151.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return true end
	-- 向操作玩家发送选择提示，提示内容为“请选择表侧表示的卡”，用于选择界面显示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从对方场上的表侧表示怪兽中选择1只作为效果对象，并将该卡设置为当前连锁的处理对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 该操作函数执行下降攻击力的处理：取得选定的对象怪兽，若其仍表侧表示且与效果相关，则给予其攻击力下降1000的永续效果，该效果在结束阶段重置。
function c59965151.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中选择的对象怪兽，即对方场上表侧表示怪兽中的被选择者。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 对方场上表侧表示存在的1只怪兽的攻击力直到结束阶段时下降1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
