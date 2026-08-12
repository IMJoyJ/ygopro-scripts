--トゥーン・デーモン
-- 效果：
-- 这张卡不能通常召唤。自己场上有「卡通世界」存在的场合才能特殊召唤（5星以上需要解放）。这张卡在特殊召唤的回合不能攻击。这张卡若不支付500基本分则不能攻击宣言。对方场上不存在卡通怪兽的场合，这张卡可以直接攻击对方玩家。存在的场合，必须选择卡通怪兽作为攻击对象。场上的「卡通世界」被破坏时，这张卡破坏。
function c91842653.initial_effect(c)
	-- 注册本卡记有「卡通世界」的卡片密码
	aux.AddCodeList(c,15259703)
	c:EnableReviveLimit()
	-- 自己场上有「卡通世界」存在的场合才能特殊召唤（5星以上需要解放）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c91842653.spcon)
	e2:SetTarget(c91842653.sptg)
	e2:SetOperation(c91842653.spop)
	c:RegisterEffect(e2)
	-- 场上的「卡通世界」被破坏时，这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c91842653.sdescon)
	e3:SetOperation(c91842653.sdesop)
	c:RegisterEffect(e3)
	-- 对方场上不存在卡通怪兽的场合，这张卡可以直接攻击对方玩家。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetCondition(c91842653.dircon)
	c:RegisterEffect(e4)
	-- 存在的场合，必须选择卡通怪兽作为攻击对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e5:SetCondition(c91842653.atcon)
	e5:SetValue(c91842653.atlimit)
	c:RegisterEffect(e5)
	-- 存在的场合，必须选择卡通怪兽作为攻击对象。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e6:SetCondition(c91842653.atcon)
	c:RegisterEffect(e6)
	-- 这张卡在特殊召唤的回合不能攻击。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	e7:SetOperation(c91842653.atklimit)
	c:RegisterEffect(e7)
	-- 这张卡若不支付500基本分则不能攻击宣言。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_ATTACK_COST)
	e8:SetCost(c91842653.atcost)
	e8:SetOperation(c91842653.atop)
	c:RegisterEffect(e8)
end
-- 过滤场上表侧表示的「卡通世界」
function c91842653.cfilter(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 过滤解放后能让玩家在怪兽区域特殊召唤怪兽的卡
function c91842653.spcfilter(c,tp)
	-- 检查解放该卡后，玩家场上是否有可用的怪兽区域
	return Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则的条件：场上有「卡通世界」且有可解放的怪兽
function c91842653.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在表侧表示的「卡通世界」
	return Duel.IsExistingMatchingCard(c91842653.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查自己场上是否存在至少1张可解放且解放后能腾出怪兽区域的怪兽
		and Duel.CheckReleaseGroupEx(tp,c91842653.spcfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤规则的准备操作：选择1只怪兽作为解放的代价
function c91842653.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取可解放的怪兽组，并过滤出解放后能腾出怪兽区域的怪兽
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c91842653.spcfilter,nil,tp)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的执行操作：解放选定的怪兽
function c91842653.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选定的怪兽
	Duel.Release(g,REASON_SPSUMMON)
end
-- 过滤条件：场上表侧表示被破坏的「卡通世界」
function c91842653.sfilter(c)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousCodeOnField()==15259703 and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 自毁效果的触发条件：场上的「卡通世界」被破坏
function c91842653.sdescon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c91842653.sfilter,1,nil)
end
-- 自毁效果的执行操作：破坏自身
function c91842653.sdesop(e,tp,eg,ep,ev,re,r,rp)
	-- 破坏自身
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 过滤对方场上表侧表示的卡通怪兽
function c91842653.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 直接攻击的条件：对方场上不存在卡通怪兽
function c91842653.dircon(e)
	-- 检查对方场上是否不存在表侧表示的卡通怪兽
	return not Duel.IsExistingMatchingCard(c91842653.atkfilter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 攻击限制的条件：对方场上存在卡通怪兽
function c91842653.atcon(e)
	-- 检查对方场上是否存在表侧表示的卡通怪兽
	return Duel.IsExistingMatchingCard(c91842653.atkfilter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 攻击目标限制：不能选择非卡通怪兽或里侧表示怪兽作为攻击对象
function c91842653.atlimit(e,c)
	return not c:IsType(TYPE_TOON) or c:IsFacedown()
end
-- 特殊召唤成功时的处理：给自身添加本回合不能攻击的效果
function c91842653.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- 这张卡在特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 攻击宣言代价的检查：检查是否能支付500基本分
function c91842653.atcost(e,c,tp)
	-- 检查玩家是否能支付500基本分
	return Duel.CheckLPCost(tp,500)
end
-- 攻击宣言代价的执行：支付500基本分
function c91842653.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 扣除玩家500基本分
	Duel.PayLPCost(tp,500)
end
