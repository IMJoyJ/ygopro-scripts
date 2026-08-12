--トゥーン・ブラック・マジシャン・ガール
-- 效果：
-- 这张卡不能通常召唤。自己场上有「卡通世界」存在的状态，把自己场上1只怪兽解放的场合可以特殊召唤。
-- ①：这张卡的攻击力上升双方墓地的「黑魔术师」「黑混沌之魔术师」数量×300。
-- ②：这张卡在对方场上没有卡通怪兽存在的场合，可以直接攻击。存在的场合，只能选择卡通怪兽作为攻击对象。
-- ③：场上的「卡通世界」被破坏时这张卡破坏。
function c90960358.initial_effect(c)
	-- 注册卡片记载的特定卡号列表（黑魔术师、卡通世界）
	aux.AddCodeList(c,46986414,15259703)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。自己场上有「卡通世界」存在的状态，把自己场上1只怪兽解放的场合可以特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c90960358.spcon)
	e2:SetTarget(c90960358.sptg)
	e2:SetOperation(c90960358.spop)
	c:RegisterEffect(e2)
	-- ③：场上的「卡通世界」被破坏时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c90960358.sdescon)
	e3:SetOperation(c90960358.sdesop)
	c:RegisterEffect(e3)
	-- ②：这张卡在对方场上没有卡通怪兽存在的场合，可以直接攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetCondition(c90960358.dircon)
	c:RegisterEffect(e4)
	-- 存在的场合，只能选择卡通怪兽作为攻击对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e5:SetCondition(c90960358.atcon)
	e5:SetValue(c90960358.atlimit)
	c:RegisterEffect(e5)
	-- 存在的场合，只能选择卡通怪兽作为攻击对象。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e6:SetCondition(c90960358.atcon)
	c:RegisterEffect(e6)
	-- 这张卡不能通常召唤。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_SUMMON_SUCCESS)
	e7:SetOperation(c90960358.atklimit)
	c:RegisterEffect(e7)
	-- ①：这张卡的攻击力上升双方墓地的「黑魔术师」「黑混沌之魔术师」数量×300。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e8:SetCode(EFFECT_UPDATE_ATTACK)
	e8:SetRange(LOCATION_MZONE)
	e8:SetValue(c90960358.val)
	c:RegisterEffect(e8)
end
-- 过滤场上表侧表示的「卡通世界」的条件函数
function c90960358.cfilter(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 过滤解放后能腾出可用怪兽区域的怪兽的条件函数
function c90960358.spcfilter(c,tp)
	-- 检查将该怪兽解放后，自己场上是否有可用的怪兽区域
	return Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则的条件判定函数
function c90960358.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在表侧表示的「卡通世界」
	return Duel.IsExistingMatchingCard(c90960358.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 并且检查自己场上是否存在至少1只可解放且解放后能腾出怪兽区域的怪兽
		and Duel.CheckReleaseGroupEx(tp,c90960358.spcfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤规则的选择目标函数
function c90960358.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有可解放且解放后能腾出怪兽区域的怪兽组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c90960358.spcfilter,nil,tp)
	-- 给玩家发送“请选择要解放的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的具体执行函数
function c90960358.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选定的怪兽
	Duel.Release(g,REASON_SPSUMMON)
end
-- 过滤因被破坏而离场的表侧表示「卡通世界」的条件函数
function c90960358.sfilter(c)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousCodeOnField()==15259703 and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 场上的「卡通世界」被破坏时自爆效果的触发条件判定
function c90960358.sdescon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c90960358.sfilter,1,nil)
end
-- 场上的「卡通世界」被破坏时自爆效果的具体执行函数
function c90960358.sdesop(e,tp,eg,ep,ev,re,r,rp)
	-- 破坏这张卡自身
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 过滤对方场上表侧表示的卡通怪兽的条件函数
function c90960358.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 可以直接攻击的条件判定（对方场上没有卡通怪兽）
function c90960358.dircon(e)
	-- 检查对方场上是否存在表侧表示的卡通怪兽，若不存在则返回true
	return not Duel.IsExistingMatchingCard(c90960358.atkfilter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 只能选择卡通怪兽作为攻击对象的条件判定（对方场上有卡通怪兽）
function c90960358.atcon(e)
	-- 检查对方场上是否存在表侧表示的卡通怪兽，若存在则返回true
	return Duel.IsExistingMatchingCard(c90960358.atkfilter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 限制攻击目标的过滤函数，使非卡通怪兽或里侧表示怪兽不能被选择为攻击对象
function c90960358.atlimit(e,c)
	return not c:IsType(TYPE_TOON) or c:IsFacedown()
end
-- 通常召唤成功时限制攻击的具体执行函数（使其在本回合不能攻击）
function c90960358.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 计算攻击力上升数值的函数
function c90960358.val(e,c)
	-- 返回双方墓地的「黑魔术师」与「黑混沌之魔术师」的总数量乘以300的数值
	return Duel.GetMatchingGroupCount(Card.IsCode,c:GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,nil,46986414,30208479)*300
end
