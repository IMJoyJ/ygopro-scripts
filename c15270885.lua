--トゥーン・ゴブリン突撃部隊
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤的回合不能攻击。场上的「卡通世界」被破坏时这张卡也破坏。自己场上有「卡通世界」且对方不控制卡通的场合，这张卡可以直接攻击对方玩家。这张卡攻击的场合在战斗阶段结束时守备表示，在下次的自己的回合结束前不能改变这张卡的表示形式。
function c15270885.initial_effect(c)
	-- 为卡片注册关联卡片代码15259703（卡通世界）
	aux.AddCodeList(c,15259703)
	-- 这张卡召唤·反转召唤·特殊召唤的回合不能攻击
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c15270885.atklimit)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 场上的「卡通世界」被破坏时这张卡也破坏
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c15270885.sdescon)
	e4:SetOperation(c15270885.sdesop)
	c:RegisterEffect(e4)
	-- 自己场上有「卡通世界」且对方不控制卡通的场合，这张卡可以直接攻击对方玩家
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_DIRECT_ATTACK)
	e5:SetCondition(c15270885.dircon)
	c:RegisterEffect(e5)
	-- 这张卡攻击的场合在战斗阶段结束时守备表示，在下次的自己的回合结束前不能改变这张卡的表示形式
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(c15270885.poscon)
	e6:SetOperation(c15270885.posop)
	c:RegisterEffect(e6)
end
-- 创建一个永续效果，使该卡在召唤·反转召唤·特殊召唤的回合不能攻击
function c15270885.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- 设置该效果为不能攻击效果，并在回合结束时重置
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤函数，用于判断离开场上的卡是否为「卡通世界」且被破坏
function c15270885.sfilter(c)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousCodeOnField()==15259703 and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 判断是否有满足条件的「卡通世界」被破坏
function c15270885.sdescon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c15270885.sfilter,1,nil)
end
-- 当满足条件时，将该卡破坏
function c15270885.sdesop(e,tp,eg,ep,ev,re,r,rp)
	-- 将该卡以效果原因破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 过滤函数，用于判断自己场上是否存在「卡通世界」
function c15270885.dirfilter1(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 过滤函数，用于判断对方场上是否存在卡通怪兽
function c15270885.dirfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 判断是否满足直接攻击条件：自己场上有「卡通世界」且对方没有卡通怪兽
function c15270885.dircon(e)
	-- 判断自己场上是否存在「卡通世界」
	return Duel.IsExistingMatchingCard(c15270885.dirfilter1,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
		-- 判断对方场上是否存在卡通怪兽
		and not Duel.IsExistingMatchingCard(c15270885.dirfilter2,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 判断该卡是否参与过攻击
function c15270885.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
end
-- 当满足条件时，将该卡变为守备表示并设置不能改变表示形式的效果
function c15270885.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将该卡变为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
	-- 创建一个永续效果，使该卡在下次自己的回合结束前不能改变表示形式
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,3)
	c:RegisterEffect(e1)
end
