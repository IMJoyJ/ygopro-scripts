--ラビュリンス・バラージュ
-- 效果：
-- ①：「拉比林斯迷宫连环阵」以外的盖放的通常陷阱卡由自己发动时才能发动。这张卡的效果变成和那张通常陷阱卡发动时的效果相同。这张卡的发动后，直到下个对方回合的结束时自己的效果发生的对对方的效果伤害变成0。
function c68779682.initial_effect(c)
	-- ①：「拉比林斯迷宫连环阵」以外的盖放的通常陷阱卡由自己发动时才能发动。这张卡的效果变成和那张通常陷阱卡发动时的效果相同。这张卡的发动后，直到下个对方回合的结束时自己的效果发生的对对方的效果伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c68779682.condition)
	e1:SetTarget(c68779682.target)
	e1:SetOperation(c68779682.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：自己发动了「拉比林斯迷宫连环阵」以外的、从场上盖放状态发动的通常陷阱卡的效果
function c68779682.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中发动卡片的卡名
	local code1,code2=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
	local rc=re:GetHandler()
	return rp==tp and not rc:IsStatus(STATUS_ACT_FROM_HAND) and rc:GetType()==TYPE_TRAP and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and code1~=68779682 and code2~=68779682
end
-- 复制被模仿的通常陷阱卡的效果发动时的Target（对象选择等处理），并保存该效果
function c68779682.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():CheckActivateEffect(false,true,false)~=nil end
	local te,ceg,cep,cev,cre,cr,crp=re:GetHandler():CheckActivateEffect(false,true,true)
	local tg=te:GetTarget()
	e:SetProperty(te:GetProperty())
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息，防止其他卡片对被复制的效果进行不合规的响应
	Duel.ClearOperationInfo(0)
end
-- 执行复制的通常陷阱卡的效果，并注册“直到下个对方回合结束时，自己对对方造成的伤害变成0”的效果
function c68779682.activate(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if te then
		e:SetLabelObject(te:GetLabelObject())
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local ct=1
		-- 这张卡的发动后，直到下个对方回合的结束时自己的效果发生的对对方的效果伤害变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetValue(c68779682.damval)
		-- 判断当前是否为对方回合，以此决定效果持续的回合数（如果是对方回合则持续2个回合，即直到下个对方回合结束）
		if Duel.GetTurnPlayer()==1-tp then
			ct=2
		end
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,ct)
		-- 注册使对方受到的效果伤害变成0的全局效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		-- 注册免伤标记效果（用于系统检测）
		Duel.RegisterEffect(e2,tp)
	end
end
-- 伤害计算过滤：如果是自己发动的效果造成的伤害，则将该伤害变成0
function c68779682.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 and rp==e:GetOwnerPlayer() then return 0
	else return val end
end
