--創獄神ネルヴァ
-- 效果：
-- 「神艺」怪兽×3
-- 自己对「创狱神 涅瓦」1回合只能有1次特殊召唤。这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
-- ●把种族不同的自己场上3只怪兽解放的场合可以守备表示特殊召唤。
-- ①：只要场地区域有卡存在，这张卡不会被效果破坏。
-- ②：1回合1次，自己把「神艺」怪兽的效果发动时才能发动。那个效果变成「对方场上的卡全部破坏」。
local s,id,o=GetID()
-- 初始化效果函数，设置卡片的特殊召唤限制、融合召唤手续、守备召唤条件、不被效果破坏和效果变更等效果
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	-- 添加融合召唤手续，使用3个满足s.ffilter条件的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,s.ffilter,3,true)
	c:EnableReviveLimit()
	-- 自己对「创狱神 涅瓦」1回合只能有1次特殊召唤。这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetRange(LOCATION_EXTRA)
	-- 设置该卡只能通过融合召唤特殊召唤
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- ●把种族不同的自己场上3只怪兽解放的场合可以守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	-- ①：只要场地区域有卡存在，这张卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己把「神艺」怪兽的效果发动时才能发动。那个效果变成「对方场上的卡全部破坏」。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"效果变更"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.chcon)
	e3:SetTarget(s.chtg)
	e3:SetOperation(s.chop)
	c:RegisterEffect(e3)
end
-- 过滤函数，判断怪兽是否为「神艺」卡组
function s.ffilter(c)
	return c:IsFusionSetCard(0x1cd)
end
-- 过滤函数，判断怪兽是否可以被解放用于特殊召唤
function s.hspfilter(c,tp,sc)
	return c:IsControler(tp) and c:IsReleasable(REASON_SPSUMMON)
		and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
-- 检查组是否满足解放条件，包括场地数量和种族不同
function s.hspchk(g,tp,sc)
	-- 检查是否有足够的场地用于特殊召唤
	return Duel.GetLocationCountFromEx(tp,tp,g,sc)>0
		and g:GetClassCount(Card.GetRace)==#g
end
-- 守备召唤条件函数，检查是否满足解放3只种族不同的怪兽的条件
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取满足守备召唤条件的怪兽组
	local rg=Duel.GetMatchingGroup(s.hspfilter,tp,LOCATION_MZONE,0,nil,tp,e:GetHandler())
	return rg:CheckSubGroup(s.hspchk,3,3,tp,e:GetHandler())
end
-- 守备召唤目标选择函数，选择3只满足条件的怪兽
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足守备召唤条件的怪兽组
	local rg=Duel.GetMatchingGroup(s.hspfilter,tp,LOCATION_MZONE,0,nil,tp,e:GetHandler())
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,s.hspchk,true,3,3,tp,e:GetHandler())
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 守备召唤处理函数，解放选中的怪兽
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 实际执行解放操作
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 不被效果破坏的条件函数，判断场地区域是否有卡
function s.indcon(e)
	-- 判断场地区域是否有卡
	return Duel.IsExistingMatchingCard(aux.TRUE,e:GetHandlerPlayer(),LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 效果变更的发动条件函数，判断是否为「神艺」怪兽的效果发动
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	local b1=re:GetHandler():IsRelateToEffect(re) and ec:IsSetCard(0x1cd)
	local b2=re:GetActivateLocation()==LOCATION_MZONE and not ec:IsLocation(LOCATION_MZONE) and ec:IsPreviousSetCard(0x1cd)
	return rp==tp and re:IsActiveType(TYPE_MONSTER) and (b1 or b2)
end
-- 效果变更的目标选择函数，检查对方场上是否有卡
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否有卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,rp,0,LOCATION_ONFIELD,1,nil) end
end
-- 效果变更的处理函数，将连锁效果的目标改为对方场上所有卡
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 将连锁效果的目标改为对方场上所有卡
	Duel.ChangeTargetCard(ev,g)
	-- 将连锁效果的处理函数改为s.repop函数
	Duel.ChangeChainOperation(ev,s.repop)
end
-- 效果变更的处理函数，破坏对方场上所有卡
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有卡的组
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 实际执行破坏操作
	Duel.Destroy(sg,REASON_EFFECT)
end
