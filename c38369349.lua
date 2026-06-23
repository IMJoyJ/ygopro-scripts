--トゥーン・ドラゴン・エッガー
-- 效果：
-- 这张卡不能通常召唤。自己场上有「卡通世界」存在，把自己场上2只怪兽解放的场合可以特殊召唤。
-- ①：这张卡在特殊召唤的回合不能攻击。
-- ②：这张卡的攻击宣言之际，自己必须支付500基本分。
-- ③：对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。存在的场合，必须把卡通怪兽作为攻击对象。
-- ④：场上的「卡通世界」被破坏时这张卡破坏。
function c38369349.initial_effect(c)
	-- 记录该卡具有「卡通世界」的效果
	aux.AddCodeList(c,15259703)
	c:EnableReviveLimit()
	-- 自己场上有「卡通世界」存在，把自己场上2只怪兽解放的场合可以特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c38369349.spcon)
	e2:SetTarget(c38369349.sptg)
	e2:SetOperation(c38369349.spop)
	c:RegisterEffect(e2)
	-- 场上的「卡通世界」被破坏时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c38369349.sdescon)
	e3:SetOperation(c38369349.sdesop)
	c:RegisterEffect(e3)
	-- 对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetCondition(c38369349.dircon)
	c:RegisterEffect(e4)
	-- 对方场上存在卡通怪兽的场合，必须把卡通怪兽作为攻击对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e5:SetCondition(c38369349.atcon)
	e5:SetValue(c38369349.atlimit)
	c:RegisterEffect(e5)
	-- 不能直接攻击。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e6:SetCondition(c38369349.atcon)
	c:RegisterEffect(e6)
	-- 这张卡在特殊召唤的回合不能攻击。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	e7:SetOperation(c38369349.atklimit)
	c:RegisterEffect(e7)
	-- 这张卡的攻击宣言之际，自己必须支付500基本分。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_ATTACK_COST)
	e8:SetCost(c38369349.atcost)
	e8:SetOperation(c38369349.atop)
	c:RegisterEffect(e8)
end
-- 过滤函数，用于判断场上是否存在「卡通世界」
function c38369349.cfilter(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 判断是否满足特殊召唤条件：己方场上存在「卡通世界」且可解放2只怪兽
function c38369349.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取己方可解放的怪兽组
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 检查己方场上是否存在「卡通世界」
	return Duel.IsExistingMatchingCard(c38369349.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查是否可解放2只怪兽
		and rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp,REASON_SPSUMMON)
end
-- 选择要解放的2只怪兽
function c38369349.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取己方可解放的怪兽组
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从可解放怪兽组中选择2只满足条件的怪兽
	local sg=rg:SelectSubGroup(tp,aux.mzctcheckrel,true,2,2,tp,REASON_SPSUMMON)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤时的解放操作
function c38369349.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定怪兽组解放
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤函数，用于判断是否为「卡通世界」被破坏
function c38369349.sfilter(c)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousCodeOnField()==15259703 and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 判断是否有「卡通世界」被破坏
function c38369349.sdescon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c38369349.sfilter,1,nil)
end
-- 当「卡通世界」被破坏时，将该卡破坏
function c38369349.sdesop(e,tp,eg,ep,ev,re,r,rp)
	-- 将该卡破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 过滤函数，用于判断是否为卡通怪兽
function c38369349.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 当己方场上不存在卡通怪兽时，该卡可直接攻击
function c38369349.dircon(e)
	-- 己方场上不存在卡通怪兽
	return not Duel.IsExistingMatchingCard(c38369349.atkfilter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 判断己方场上是否存在卡通怪兽
function c38369349.atcon(e)
	-- 己方场上存在卡通怪兽
	return Duel.IsExistingMatchingCard(c38369349.atkfilter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 限制非卡通怪兽不能成为攻击对象
function c38369349.atlimit(e,c)
	return not c:IsType(TYPE_TOON) or c:IsFacedown()
end
-- 特殊召唤成功后，该卡在本回合不能攻击
function c38369349.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- 设置该卡在本回合不能攻击的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 判断是否能支付500基本分作为攻击代价
function c38369349.atcost(e,c,tp)
	-- 检查玩家是否能支付500基本分
	return Duel.CheckLPCost(tp,500)
end
-- 支付500基本分作为攻击代价
function c38369349.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 扣除玩家500基本分
	Duel.PayLPCost(tp,500)
end
