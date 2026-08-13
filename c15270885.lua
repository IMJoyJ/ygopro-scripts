--トゥーン・ゴブリン突撃部隊
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤的回合不能攻击。场上的「卡通世界」被破坏时这张卡也破坏。自己场上有「卡通世界」且对方不控制卡通的场合，这张卡可以直接攻击对方玩家。这张卡攻击的场合在战斗阶段结束时守备表示，在下次的自己的回合结束前不能改变这张卡的表示形式。
function c15270885.initial_effect(c)
	-- 将卡通世界（15259703）的卡号加入此卡的卡名关联列表，用于在规则和文本上标明效果提及的卡名。
	aux.AddCodeList(c,15259703)
	-- 这张卡召唤·反转召唤·特殊召唤的回合不能攻击。
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
	-- 场上的「卡通世界」被破坏时这张卡也破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c15270885.sdescon)
	e4:SetOperation(c15270885.sdesop)
	c:RegisterEffect(e4)
	-- 自己场上有「卡通世界」且对方不控制卡通的场合，这张卡可以直接攻击对方玩家。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_DIRECT_ATTACK)
	e5:SetCondition(c15270885.dircon)
	c:RegisterEffect(e5)
	-- 这张卡攻击的场合在战斗阶段结束时守备表示，在下次的自己的回合结束前不能改变这张卡的表示形式。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(c15270885.poscon)
	e6:SetOperation(c15270885.posop)
	c:RegisterEffect(e6)
end
-- 在召唤/特殊召唤/反转召唤成功时，给这张卡附加一个持续到回合结束的“不能攻击”效果，限制其当回合不能进行攻击。
function c15270885.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- 这张卡召唤·反转召唤·特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤条件：检查离场卡片是否为“表侧表示且在被破坏后离场、离场前位于场上且卡名为卡通世界（15259703）”的卡，即判断是否有卡通世界被破坏。
function c15270885.sfilter(c)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousCodeOnField()==15259703 and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果发动条件：场上发生的离场事件中存在至少1张满足sfilter的卡（即「卡通世界」被破坏），满足时触发后续破坏效果。
function c15270885.sdescon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c15270885.sfilter,1,nil)
end
-- 效果处理：将通过e:GetHandler()取得的这张卡通哥布林突击部队破坏。
function c15270885.sdesop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果破坏这张卡通哥布林突击部队。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 过滤条件：卡片为表侧表示且卡号是15259703（卡通世界），用于检查自己场上是否有卡通世界。
function c15270885.dirfilter1(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 过滤条件：卡片为表侧表示且类型包含卡通（TYPE_TOON），用于检查对方场上是否有卡通怪兽。
function c15270885.dirfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 直接攻击的判定条件：自己场上有表侧表示的「卡通世界」，且对方场上不存在表侧表示的卡通怪兽。
function c15270885.dircon(e)
	-- 检查自己场上（LOCATION_ONFIELD）是否存在至少1张表侧表示的「卡通世界」（15259703）。
	return Duel.IsExistingMatchingCard(c15270885.dirfilter1,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
		-- 同时检查对方场上（LOCATION_MZONE）不存在表侧表示的卡通怪兽（TYPE_TOON）。
		and not Duel.IsExistingMatchingCard(c15270885.dirfilter2,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 战斗阶段结束时的触发条件：这张卡在本回合进行过攻击（攻击次数大于0）。
function c15270885.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
end
-- 处理攻击后的变形：若此卡仍为攻击表示则改为表侧守备表示，并给它附加一个不可被无效的“不能改变表示形式”效果，持续到第3个结束阶段（即直到下次自己的回合结束前）。
function c15270885.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将这张卡的表示形式从攻击表示改为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
	-- 在下次的自己的回合结束前不能改变这张卡的表示形式。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,3)
	c:RegisterEffect(e1)
end
