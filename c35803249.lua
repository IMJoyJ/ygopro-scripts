--人造人間－サイコ・ロード
-- 效果：
-- 这张卡不能通常召唤。把自己场上1只表侧表示的「人造人-念力震慑者」送去墓地的场合才能特殊召唤。
-- ①：只要这张卡在怪兽区域存在，双方不能把场上的陷阱卡的效果发动，场上的陷阱卡的效果无效化。
-- ②：1回合1次，自己主要阶段才能发动。场上的表侧表示的陷阱卡全部破坏，给与对方破坏数量×300伤害。
function c35803249.initial_effect(c)
	-- 记录该卡具有「人造人-念力震慑者」的卡片代码，用于特殊召唤条件判断
	aux.AddCodeList(c,77585513)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己场上1只表侧表示的「人造人-念力震慑者」送去墓地的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡无法被特殊召唤，强制返回假值以实现不能通常召唤的效果
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 特殊召唤规则：将自己场上1只表侧表示的「人造人-念力震慑者」送去墓地才能特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c35803249.spcon)
	e2:SetTarget(c35803249.sptg)
	e2:SetOperation(c35803249.spop)
	c:RegisterEffect(e2)
	-- 只要这张卡在怪兽区域存在，双方不能把场上的陷阱卡的效果发动
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_HAND+LOCATION_SZONE,LOCATION_HAND+LOCATION_SZONE)
	e3:SetTarget(c35803249.distg)
	c:RegisterEffect(e3)
	-- 只要这张卡在怪兽区域存在，场上的陷阱卡的效果无效化
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e4:SetTarget(c35803249.distg)
	c:RegisterEffect(e4)
	-- 连锁处理时，若陷阱卡在魔法陷阱区域发动，则使该效果无效
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAIN_SOLVING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetOperation(c35803249.disop)
	c:RegisterEffect(e5)
	-- 只要这张卡在怪兽区域存在，陷阱怪兽的效果无效
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e6:SetTarget(c35803249.distg)
	c:RegisterEffect(e6)
	-- 1回合1次，自己主要阶段才能发动。场上的表侧表示的陷阱卡全部破坏，给与对方破坏数量×300伤害
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(35803249,0))  --"表侧的陷阱卡全部破坏"
	e7:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1)
	e7:SetTarget(c35803249.destg)
	e7:SetOperation(c35803249.desop)
	c:RegisterEffect(e7)
end
-- 过滤函数，判断卡片是否为陷阱卡类型
function c35803249.distg(e,c)
	return c:IsType(TYPE_TRAP)
end
-- 连锁处理时，若触发位置为魔法陷阱区域且为陷阱卡类型，则使该连锁效果无效
function c35803249.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的触发位置信息
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if tl==LOCATION_SZONE and re:IsActiveType(TYPE_TRAP) then
		-- 使指定连锁的效果无效
		Duel.NegateEffect(ev)
	end
end
-- 过滤函数，判断是否为表侧表示的「人造人-念力震慑者」且可送入墓地并满足召唤区域要求
function c35803249.spfilter(c,tp)
	-- 判断卡片是否为表侧表示的「人造人-念力震慑者」且可送入墓地并满足召唤区域要求
	return c:IsFaceup() and c:IsCode(77585513) and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 判断是否满足特殊召唤条件，即自己场上存在表侧表示的「人造人-念力震慑者」
function c35803249.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否存在至少1张满足特殊召唤条件的「人造人-念力震慑者」
	return Duel.IsExistingMatchingCard(c35803249.spfilter,c:GetControler(),LOCATION_MZONE,0,1,nil,c:GetControler())
end
-- 设置特殊召唤的目标选择逻辑，选择一张符合条件的「人造人-念力震慑者」送入墓地
function c35803249.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足特殊召唤条件的「人造人-念力震慑者」
	local g=Duel.GetMatchingGroup(c35803249.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤操作，将选定的卡片送入墓地
function c35803249.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标卡片以特殊召唤原因送入墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
end
-- 过滤函数，判断是否为表侧表示的陷阱卡
function c35803249.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_TRAP)
end
-- 设置效果发动时的处理逻辑，检查场上是否存在陷阱卡并准备破坏和造成伤害
function c35803249.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1张表侧表示的陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c35803249.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有表侧表示的陷阱卡
	local sg=Duel.GetMatchingGroup(c35803249.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息，准备破坏陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	-- 设置操作信息，准备对对方造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,sg:GetCount()*300)
end
-- 执行效果处理，破坏所有表侧表示的陷阱卡并造成对应伤害
function c35803249.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有表侧表示的陷阱卡
	local sg=Duel.GetMatchingGroup(c35803249.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 破坏目标陷阱卡，返回实际破坏数量
	local ct=Duel.Destroy(sg,REASON_EFFECT)
	-- 对对方造成破坏数量乘以300的伤害
	Duel.Damage(1-tp,ct*300,REASON_EFFECT)
end
