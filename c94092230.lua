--インヴェルズ・グレズ
-- 效果：
-- 这张卡不能特殊召唤。这张卡通常召唤的场合，必须把自己场上存在的3只名字带有「侵入魔鬼」的怪兽解放作召唤。可以把基本分支付一半，这张卡以外的场上存在的卡全部破坏。这个效果1回合只能使用1次。
function c94092230.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 必须把自己场上存在的3只名字带有「侵入魔鬼」的怪兽解放作召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRIBUTE_LIMIT)
	e2:SetValue(c94092230.tlimit)
	c:RegisterEffect(e2)
	-- 这张卡通常召唤的场合，必须把自己场上存在的3只名字带有「侵入魔鬼」的怪兽解放作召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(94092230,0))  --"把3只怪兽解放召唤"
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e3:SetCondition(c94092230.ttcon)
	e3:SetOperation(c94092230.ttop)
	e3:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e3)
	-- 必须把自己场上存在的3只名字带有「侵入魔鬼」的怪兽解放作召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_LIMIT_SET_PROC)
	e4:SetCondition(c94092230.setcon)
	c:RegisterEffect(e4)
	-- 可以把基本分支付一半，这张卡以外的场上存在的卡全部破坏。这个效果1回合只能使用1次。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(94092230,1))  --"破坏"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCost(c94092230.descost)
	e5:SetTarget(c94092230.destg)
	e5:SetOperation(c94092230.desop)
	c:RegisterEffect(e5)
end
-- 限制为通常召唤此卡进行解放的怪兽必须是名字带有「侵入魔鬼」的怪兽
function c94092230.tlimit(e,c)
	return not c:IsSetCard(0x100a)
end
-- 3只怪兽解放召唤的条件检查函数
function c94092230.ttcon(e,c,minc)
	if c==nil then return true end
	-- 检查解放召唤所需的3只怪兽是否满足数量和解放条件
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 3只怪兽解放召唤的具体操作函数
function c94092230.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 让玩家选择场上3只用于解放召唤的怪兽
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 将选中的怪兽解放用于通常召唤
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 限制此卡不能进行里侧表示放置（Set）
function c94092230.setcon(e,c,minc)
	if not c then return true end
	return false
end
-- 破坏效果的发动代价（Cost）处理函数
function c94092230.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付一半的基本分
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 破坏效果的发动目标（Target）处理函数
function c94092230.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在除这张卡以外的至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取场上除这张卡以外的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置效果处理信息为破坏场上除这张卡以外的所有卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的效果处理（Operation）函数
function c94092230.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除这张卡以外的所有卡片（排除已离场的自身）
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 破坏获取到的所有卡片
	Duel.Destroy(g,REASON_EFFECT)
end
