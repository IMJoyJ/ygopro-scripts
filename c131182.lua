--ミラクル・フリッパー
-- 效果：
-- 「奇迹反转士」在自己场上存在的场合，这张卡不能召唤·反转召唤·特殊召唤。只要这张卡在场上表侧表示存在，对方不能选择其他的表侧表示的怪兽作为攻击对象。这张卡被战斗破坏的场合，这张卡在对方场上特殊召唤。这张卡被魔法·陷阱的效果破坏的场合，把对方场上1只怪兽破坏。
function c131182.initial_effect(c)
	-- 「奇迹反转士」在自己场上存在的场合，这张卡不能召唤·反转召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c131182.excon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上表侧表示存在，对方不能选择其他的表侧表示的怪兽作为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(c131182.splimit)
	c:RegisterEffect(e3)
	-- 这张卡被战斗破坏的场合，这张卡在对方场上特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetValue(c131182.atlimit)
	c:RegisterEffect(e4)
	-- 这张卡被魔法·陷阱的效果破坏的场合，把对方场上1只怪兽破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_BATTLE_DESTROYED)
	e5:SetOperation(c131182.battleop)
	c:RegisterEffect(e5)
	-- 效果作用
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(131182,0))  --"特殊召唤"
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetRange(0xff)
	e6:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e6:SetCountLimit(1)
	e6:SetCondition(c131182.spcon)
	e6:SetTarget(c131182.sptg)
	e6:SetOperation(c131182.spop)
	c:RegisterEffect(e6)
	-- 效果原文内容
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(131182,1))  --"对方场上1只怪兽破坏"
	e7:SetCategory(CATEGORY_DESTROY)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e7:SetCode(EVENT_DESTROYED)
	e7:SetCondition(c131182.descon)
	e7:SetTarget(c131182.destg)
	e7:SetOperation(c131182.desop)
	c:RegisterEffect(e7)
end
-- 过滤函数，用于判断是否为场上表侧表示的奇迹反转士
function c131182.exfilter(c)
	return c:IsFaceup() and c:IsCode(131182)
end
-- 判断奇迹反转士是否在自己场上存在
function c131182.excon(e)
	local c=e:GetHandler()
	-- 检查以自己为玩家，在场上是否存在至少1张奇迹反转士
	return Duel.IsExistingMatchingCard(c131182.exfilter,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end
-- 特殊召唤限制函数，用于判断是否可以特殊召唤
function c131182.splimit(e,se,sp,st,spos,tgp)
	-- 如果目标玩家场上不存在奇迹反转士，则可以特殊召唤
	return not Duel.IsExistingMatchingCard(c131182.exfilter,tgp,LOCATION_ONFIELD,0,1,nil)
end
-- 攻击对象限制函数，用于判断是否能被选为攻击对象
function c131182.atlimit(e,c)
	return c:IsFaceup() and c~=e:GetHandler()
end
-- 战斗破坏时注册标志位，用于后续特殊召唤效果触发
function c131182.battleop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(131182,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
-- 特殊召唤触发条件函数，判断是否满足特殊召唤条件
function c131182.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(131182)~=0
end
-- 特殊召唤效果的目标设定函数
function c131182.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤操作信息，指定要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数
function c131182.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身特殊召唤到对方场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,1-tp,false,false,POS_FACEUP)
	end
end
-- 破坏效果触发条件函数，判断是否为魔法或陷阱效果破坏
function c131182.descon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的目标设定函数
function c131182.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	-- 提示选择破坏对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择对方场上的1只怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置破坏操作信息，指定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的处理函数
function c131182.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
