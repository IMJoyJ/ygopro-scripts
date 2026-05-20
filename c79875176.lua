--トゥーン・キャノン・ソルジャー
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤的回合不能攻击。自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。场上的「卡通世界」被破坏时这张卡也破坏。可以把自己场上存在的1只怪兽解放，给与对方基本分500分伤害。
function c79875176.initial_effect(c)
	-- 注册卡片记有「卡通世界」卡名（卡号15259703）的信息
	aux.AddCodeList(c,15259703)
	-- 这张卡召唤·反转召唤·特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c79875176.atklimit)
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
	e4:SetCondition(c79875176.sdescon)
	e4:SetOperation(c79875176.sdesop)
	c:RegisterEffect(e4)
	-- 自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_DIRECT_ATTACK)
	e5:SetCondition(c79875176.dircon)
	c:RegisterEffect(e5)
	-- 可以把自己场上存在的1只怪兽解放，给与对方基本分500分伤害。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(79875176,0))  --"伤害"
	e6:SetCategory(CATEGORY_DAMAGE)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCost(c79875176.damcost)
	e6:SetTarget(c79875176.damtg)
	e6:SetOperation(c79875176.damop)
	c:RegisterEffect(e6)
end
-- 召唤、特殊召唤、反转召唤成功时，为自身添加不能攻击状态的效果函数
function c79875176.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- 不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤在场上以表侧表示存在并被破坏的「卡通世界」
function c79875176.sfilter(c)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousCodeOnField()==15259703 and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 检查离场的卡片中是否存在被破坏的表侧表示的「卡通世界」
function c79875176.sdescon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c79875176.sfilter,1,nil)
end
-- 破坏这张卡自身的效果函数
function c79875176.sdesop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自身破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 过滤场上表侧表示存在的「卡通世界」
function c79875176.dirfilter1(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 过滤对方场上表侧表示存在的卡通怪兽
function c79875176.dirfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 直接攻击效果的允许条件：自己场上有「卡通世界」且对方场上没有卡通怪兽
function c79875176.dircon(e)
	-- 检查自己场上是否存在表侧表示的「卡通世界」
	return Duel.IsExistingMatchingCard(c79875176.dirfilter1,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
		-- 且检查对方场上不存在表侧表示的卡通怪兽
		and not Duel.IsExistingMatchingCard(c79875176.dirfilter2,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 伤害效果的发动代价：解放自己场上的1只怪兽
function c79875176.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 选择自己场上1只可解放的怪兽
	local sg=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(sg,REASON_COST)
end
-- 伤害效果的目标确认：设定对方玩家为效果对象，并设置造成500点伤害的操作信息
function c79875176.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将对方玩家设为效果的目标玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将伤害数值500设为效果的目标参数
	Duel.SetTargetParam(500)
	-- 注册给对方造成500点伤害的效果分类和操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 伤害效果的执行：获取目标玩家和伤害数值，并给与对方伤害
function c79875176.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家对应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
