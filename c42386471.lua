--トゥーン・ヂェミナイ・エルフ
-- 效果：
-- ①：这张卡在召唤·反转召唤·特殊召唤的回合不能攻击。
-- ②：自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
-- ③：这张卡给与对方战斗伤害时才能发动。对方手卡随机选1张丢弃。
-- ④：场上的「卡通世界」被破坏时这张卡破坏。
function c42386471.initial_effect(c)
	-- 记录此卡与「卡通世界」的关联
	aux.AddCodeList(c,15259703)
	-- ①：这张卡在召唤·反转召唤·特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c42386471.atklimit)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ④：场上的「卡通世界」被破坏时这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c42386471.sdescon)
	e4:SetOperation(c42386471.sdesop)
	c:RegisterEffect(e4)
	-- ②：自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_DIRECT_ATTACK)
	e5:SetCondition(c42386471.dircon)
	c:RegisterEffect(e5)
	-- ③：这张卡给与对方战斗伤害时才能发动。对方手卡随机选1张丢弃。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(42386471,0))  --"丢弃手牌"
	e6:SetCategory(CATEGORY_HANDES)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_BATTLE_DAMAGE)
	e6:SetCondition(c42386471.condition)
	e6:SetTarget(c42386471.target)
	e6:SetOperation(c42386471.operation)
	c:RegisterEffect(e6)
end
-- 效果作用：使此卡在召唤·反转召唤·特殊召唤的回合不能攻击
function c42386471.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：此卡在召唤·反转召唤·特殊召唤的回合不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤函数：判断离场卡是否为正面表示的「卡通世界」
function c42386471.sfilter(c)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousCodeOnField()==15259703 and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果作用：判断是否有「卡通世界」被破坏
function c42386471.sdescon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c42386471.sfilter,1,nil)
end
-- 效果作用：将此卡破坏
function c42386471.sdesop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 过滤函数：判断自己场上是否存在「卡通世界」
function c42386471.dirfilter1(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 过滤函数：判断对方场上是否存在卡通怪兽
function c42386471.dirfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 效果作用：判断是否满足直接攻击条件
function c42386471.dircon(e)
	-- 判断自己场上是否存在「卡通世界」
	return Duel.IsExistingMatchingCard(c42386471.dirfilter1,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
		-- 判断对方场上是否存在卡通怪兽
		and not Duel.IsExistingMatchingCard(c42386471.dirfilter2,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 效果作用：判断造成战斗伤害的玩家是否为对方
function c42386471.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果作用：设置丢弃手牌的连锁操作信息
function c42386471.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方手牌数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(ep,LOCATION_HAND,0)>0 end
	-- 设置丢弃手牌的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
-- 效果作用：随机丢弃对方1张手牌
function c42386471.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌组
	local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	-- 将选中的手牌送去墓地
	Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
end
