--ブルーアイズ・トゥーン・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。自己场上有「卡通世界」存在的状态，把自己场上2只怪兽解放的场合可以特殊召唤。
-- ①：这张卡在特殊召唤的回合不能攻击。
-- ②：这张卡的攻击宣言之际，自己必须支付500基本分。
-- ③：这张卡在对方场上没有卡通怪兽存在的场合，可以直接攻击。存在的场合，只能选择卡通怪兽作为攻击对象。
-- ④：场上的「卡通世界」被破坏时这张卡破坏。
function c53183600.initial_effect(c)
	-- 将「卡通世界」的卡片密码注册到该卡的关联卡片列表中
	aux.AddCodeList(c,15259703)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。自己场上有「卡通世界」存在的状态，把自己场上2只怪兽解放的场合可以特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c53183600.spcon)
	e2:SetTarget(c53183600.sptg)
	e2:SetOperation(c53183600.spop)
	c:RegisterEffect(e2)
	-- ④：场上的「卡通世界」被破坏时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c53183600.sdescon)
	e3:SetOperation(c53183600.sdesop)
	c:RegisterEffect(e3)
	-- ③：这张卡在对方场上没有卡通怪兽存在的场合，可以直接攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetCondition(c53183600.dircon)
	c:RegisterEffect(e4)
	-- 存在的场合，只能选择卡通怪兽作为攻击对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e5:SetCondition(c53183600.atcon)
	e5:SetValue(c53183600.atlimit)
	c:RegisterEffect(e5)
	-- 存在的场合，只能选择卡通怪兽作为攻击对象。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e6:SetCondition(c53183600.atcon)
	c:RegisterEffect(e6)
	-- ①：这张卡在特殊召唤的回合不能攻击。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	e7:SetOperation(c53183600.atklimit)
	c:RegisterEffect(e7)
	-- ②：这张卡的攻击宣言之际，自己必须支付500基本分。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_ATTACK_COST)
	e8:SetCost(c53183600.atcost)
	e8:SetOperation(c53183600.atop)
	c:RegisterEffect(e8)
end
-- 过滤条件：场上表侧表示的「卡通世界」
function c53183600.cfilter(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 检查自己场上是否存在「卡通世界」以及是否有2只可解放的怪兽，作为特殊召唤的条件
function c53183600.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家场上可用于特殊召唤解放的怪兽组
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 检查自己场上是否存在表侧表示的「卡通世界」
	return Duel.IsExistingMatchingCard(c53183600.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查是否能选择2只怪兽解放，且解放后主怪兽区有足够的空位用于特殊召唤
		and rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp,REASON_SPSUMMON)
end
-- 特殊召唤的准备流程，选择并记录要解放的2只怪兽
function c53183600.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上可用于特殊召唤解放的怪兽组
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 玩家选择2只解放后能腾出足够怪兽区域空位的怪兽
	local sg=rg:SelectSubGroup(tp,aux.mzctcheckrel,true,2,2,tp,REASON_SPSUMMON)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤的操作，解放选中的怪兽
function c53183600.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选中的怪兽
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤条件：场上表侧表示被破坏的「卡通世界」
function c53183600.sfilter(c)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousCodeOnField()==15259703 and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 检查离场的卡片中是否包含被破坏的「卡通世界」
function c53183600.sdescon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c53183600.sfilter,1,nil)
end
-- 破坏自身（这张卡）
function c53183600.sdesop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果破坏这张卡
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 过滤条件：对方场上表侧表示的卡通怪兽
function c53183600.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 检查对方场上是否存在卡通怪兽，作为能否直接攻击的条件
function c53183600.dircon(e)
	-- 确认对方场上不存在表侧表示的卡通怪兽
	return not Duel.IsExistingMatchingCard(c53183600.atkfilter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 检查对方场上是否存在卡通怪兽，作为攻击限制的启用条件
function c53183600.atcon(e)
	-- 确认对方场上存在表侧表示的卡通怪兽
	return Duel.IsExistingMatchingCard(c53183600.atkfilter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 限制不能选择非卡通怪兽或里侧表示怪兽作为攻击对象
function c53183600.atlimit(e,c)
	return not c:IsType(TYPE_TOON) or c:IsFacedown()
end
-- 在特殊召唤成功时，为自身施加本回合不能攻击的限制
function c53183600.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这张卡在特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 检查玩家是否能支付500基本分作为攻击宣言的代价
function c53183600.atcost(e,c,tp)
	-- 检查玩家是否拥有至少500基本分
	return Duel.CheckLPCost(tp,500)
end
-- 执行支付500基本分作为攻击宣言代价的操作
function c53183600.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 扣除玩家500基本分
	Duel.PayLPCost(tp,500)
end
