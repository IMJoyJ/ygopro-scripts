--アースクエイク・ジャイアント
-- 效果：
-- 这张卡的表示形式变更时，可以选择对方场上存在的1只怪兽，把表示形式变更。这个效果1回合只能使用1次。
function c61864793.initial_effect(c)
	-- 这张卡的表示形式变更时，可以选择对方场上存在的1只怪兽，把表示形式变更。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61864793,0))  --"表示形式变更"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetCondition(c61864793.poscon)
	e1:SetTarget(c61864793.postg)
	e1:SetOperation(c61864793.posop)
	c:RegisterEffect(e1)
end
-- 判定此卡是否发生了表示形式的变更（在攻击表示与守备表示之间切换），且不处于持续改变表示形式的状态
function c61864793.poscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local np=c:GetPosition()
	local pp=c:GetPreviousPosition()
	return not c:IsStatus(STATUS_CONTINUOUS_POS) and ((np<3 and pp>3) or (pp<3 and np>3))
end
-- 过滤可以改变表示形式的怪兽
function c61864793.filter(c)
	return c:IsCanChangePosition()
end
-- 效果发动的目标选择与合法性检测，选择对方场上1只可以改变表示形式的怪兽作为对象
function c61864793.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c61864793.filter(chkc) end
	-- 在效果发动准备阶段，检查对方场上是否存在至少1只可以改变表示形式的怪兽
	if chk==0 then return Duel.IsExistingTarget(c61864793.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 给发动效果的玩家发送提示信息，提示选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择对方场上1只可以改变表示形式的怪兽作为效果的对象
	Duel.SelectTarget(tp,c61864793.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理阶段，将作为对象的那只怪兽的表示形式变更
function c61864793.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽的表示形式进行变更（根据其当前状态，将其变为对应的表侧守备、里侧守备或表侧攻击表示）
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
