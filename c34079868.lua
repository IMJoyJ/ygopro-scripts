--真竜剣士マスターP
-- 效果：
-- 这张卡不能通常召唤。把自己场上的「龙剑士」怪兽和「龙魔王」怪兽各1只解放的场合才能特殊召唤。
-- ①：1回合1次，魔法·陷阱·怪兽的效果发动时才能发动。那个发动无效并破坏。
-- ②：场上的这张卡被对方破坏的场合才能发动。从卡组把「龙剑士」怪兽和「龙魔王」怪兽各1只特殊召唤。
function c34079868.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己场上的「龙剑士」怪兽和「龙魔王」怪兽各1只解放的场合才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 特殊召唤条件设置为必须解放「龙剑士」和「龙魔王」怪兽各1只。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c34079868.spcon)
	e1:SetTarget(c34079868.sptg)
	e1:SetOperation(c34079868.spop)
	c:RegisterEffect(e1)
	-- 1回合1次，魔法·陷阱·怪兽的效果发动时才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34079868,0))  --"效果发动无效"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c34079868.discon)
	e2:SetTarget(c34079868.distg)
	e2:SetOperation(c34079868.disop)
	c:RegisterEffect(e2)
	-- 场上的这张卡被对方破坏的场合才能发动。从卡组把「龙剑士」怪兽和「龙魔王」怪兽各1只特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34079868,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c34079868.condition)
	e3:SetTarget(c34079868.target)
	e3:SetOperation(c34079868.operation)
	c:RegisterEffect(e3)
end
-- 检查所选的2只怪兽是否满足解放条件且分别属于「龙剑士」和「龙魔王」卡组。
function c34079868.fselect(g,tp)
	-- 检查所选的2只怪兽是否满足解放条件且分别属于「龙剑士」和「龙魔王」卡组。
	return aux.mzctcheckrel(g,tp,REASON_SPSUMMON) and aux.gfcheck(g,Card.IsSetCard,0xc7,0xda)
end
-- 检查是否满足特殊召唤条件，即场上有满足条件的2只怪兽可被解放。
function c34079868.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家可解放的怪兽组。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	return g:CheckSubGroup(c34079868.fselect,2,2,tp)
end
-- 选择满足条件的2只怪兽进行解放。
function c34079868.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家可解放的怪兽组。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 提示玩家选择要解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=g:SelectSubGroup(tp,c34079868.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行解放操作。
function c34079868.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定的怪兽解放。
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 判断是否可以无效对方的连锁发动。
function c34079868.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 判断当前连锁是否可以被无效。
	return Duel.IsChainNegatable(ev)
end
-- 设置无效效果和破坏效果的处理信息。
function c34079868.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效效果的处理信息。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏效果的处理信息。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行无效效果和破坏效果。
function c34079868.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效连锁发动且目标卡存在。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏目标卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 判断是否满足特殊召唤条件。
function c34079868.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 检查「龙剑士」怪兽是否可以被特殊召唤且卡组中存在「龙魔王」怪兽。
function c34079868.spfilter1(c,e,tp)
	return c:IsSetCard(0xc7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查卡组中是否存在满足条件的「龙魔王」怪兽。
		and Duel.IsExistingMatchingCard(c34079868.spfilter2,tp,LOCATION_DECK,0,1,c,e,tp)
end
-- 检查「龙魔王」怪兽是否可以被特殊召唤。
function c34079868.spfilter2(c,e,tp)
	return c:IsSetCard(0xda) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查是否满足特殊召唤条件。
function c34079868.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查卡组中是否存在满足条件的「龙剑士」怪兽。
		and Duel.IsExistingMatchingCard(c34079868.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的处理信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 检查是否满足特殊召唤条件。
function c34079868.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的怪兽区域。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只「龙剑士」怪兽。
	local g1=Duel.SelectMatchingCard(tp,c34079868.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只「龙魔王」怪兽。
	local g2=Duel.SelectMatchingCard(tp,c34079868.spfilter2,tp,LOCATION_DECK,0,1,1,g1:GetFirst(),e,tp)
	g1:Merge(g2)
	if g1:GetCount()==2 then
		-- 将指定的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
	end
end
