--ブルーアイズ・トゥーン・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。自己场上有「卡通世界」存在的状态，把自己场上2只怪兽解放的场合可以特殊召唤。
-- ①：这张卡在特殊召唤的回合不能攻击。
-- ②：这张卡的攻击宣言之际，自己必须支付500基本分。
-- ③：这张卡在对方场上没有卡通怪兽存在的场合，可以直接攻击。存在的场合，只能选择卡通怪兽作为攻击对象。
-- ④：场上的「卡通世界」被破坏时这张卡破坏。
function c53183600.initial_effect(c)
	-- 记录该卡具有「卡通世界」的卡片密码
	aux.AddCodeList(c,15259703)
	c:EnableReviveLimit()
	-- 自己场上有「卡通世界」存在的状态，把自己场上2只怪兽解放的场合可以特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c53183600.spcon)
	e2:SetTarget(c53183600.sptg)
	e2:SetOperation(c53183600.spop)
	c:RegisterEffect(e2)
	-- 场上的「卡通世界」被破坏时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c53183600.sdescon)
	e3:SetOperation(c53183600.sdesop)
	c:RegisterEffect(e3)
	-- 这张卡在对方场上没有卡通怪兽存在的场合，可以直接攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetCondition(c53183600.dircon)
	c:RegisterEffect(e4)
	-- 这张卡在对方场上存在卡通怪兽的场合，只能选择卡通怪兽作为攻击对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e5:SetCondition(c53183600.atcon)
	e5:SetValue(c53183600.atlimit)
	c:RegisterEffect(e5)
	-- 这张卡在特殊召唤的回合不能攻击。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e6:SetCondition(c53183600.atcon)
	c:RegisterEffect(e6)
	-- 这张卡的攻击宣言之际，自己必须支付500基本分。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	e7:SetOperation(c53183600.atklimit)
	c:RegisterEffect(e7)
	-- 效果作用
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_ATTACK_COST)
	e8:SetCost(c53183600.atcost)
	e8:SetOperation(c53183600.atop)
	c:RegisterEffect(e8)
end
-- 过滤函数：检查场上是否存在「卡通世界」
function c53183600.cfilter(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 效果作用
function c53183600.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家可解放的怪兽组（不包括手牌）
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 检查自己场上是否存在「卡通世界」
	return Duel.IsExistingMatchingCard(c53183600.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查是否能选出2只满足条件的怪兽进行解放
		and rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp,REASON_SPSUMMON)
end
-- 效果作用
function c53183600.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家可解放的怪兽组（不包括手牌）
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从可解放怪兽中选择2只满足条件的怪兽组
	local sg=rg:SelectSubGroup(tp,aux.mzctcheckrel,true,2,2,tp,REASON_SPSUMMON)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 效果作用
function c53183600.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定怪兽组进行解放
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤函数：检查是否为「卡通世界」被破坏的卡片
function c53183600.sfilter(c)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousCodeOnField()==15259703 and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果作用
function c53183600.sdescon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c53183600.sfilter,1,nil)
end
-- 效果作用
function c53183600.sdesop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自身破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 过滤函数：检查是否为表侧表示的卡通怪兽
function c53183600.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 效果作用
function c53183600.dircon(e)
	-- 判断对方场上是否存在卡通怪兽
	return not Duel.IsExistingMatchingCard(c53183600.atkfilter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 效果作用
function c53183600.atcon(e)
	-- 判断对方场上是否存在卡通怪兽
	return Duel.IsExistingMatchingCard(c53183600.atkfilter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 效果作用
function c53183600.atlimit(e,c)
	return not c:IsType(TYPE_TOON) or c:IsFacedown()
end
-- 效果作用
function c53183600.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- 使该卡在本回合不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 效果作用
function c53183600.atcost(e,c,tp)
	-- 检查玩家是否能支付500基本分
	return Duel.CheckLPCost(tp,500)
end
-- 效果作用
function c53183600.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家支付500基本分
	Duel.PayLPCost(tp,500)
end
