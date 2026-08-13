--真竜剣士マスターP
-- 效果：
-- 这张卡不能通常召唤。把自己场上的「龙剑士」怪兽和「龙魔王」怪兽各1只解放的场合才能特殊召唤。
-- ①：1回合1次，魔法·陷阱·怪兽的效果发动时才能发动。那个发动无效并破坏。
-- ②：场上的这张卡被对方破坏的场合才能发动。从卡组把「龙剑士」怪兽和「龙魔王」怪兽各1只特殊召唤。
function c34079868.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 把自己场上的「龙剑士」怪兽和「龙魔王」怪兽各1只解放的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c34079868.spcon)
	e1:SetTarget(c34079868.sptg)
	e1:SetOperation(c34079868.spop)
	c:RegisterEffect(e1)
	-- ①：1回合1次，魔法·陷阱·怪兽的效果发动时才能发动。那个发动无效并破坏。
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
	-- ②：场上的这张卡被对方破坏的场合才能发动。从卡组把「龙剑士」怪兽和「龙魔王」怪兽各1只特殊召唤。
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
-- 检查选中的2张解放素材是否满足：解放后主怪兽区仍有空位，且其中1张为「龙剑士」、1张为「龙魔王」。
function c34079868.fselect(g,tp)
	-- 确认解放这组怪兽后场上仍有足够空位，且这组怪兽包含「龙剑士」与「龙魔王」各1只。
	return aux.mzctcheckrel(g,tp,REASON_SPSUMMON) and aux.gfcheck(g,Card.IsSetCard,0xc7,0xda)
end
-- 特殊召唤条件的判定：检查场上是否存在可解放的「龙剑士」和「龙魔王」各1只，且解放后另有空位可供特殊召唤。
function c34079868.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家tp当前可解放的怪兽组（用于特殊召唤的解放手续）。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	return g:CheckSubGroup(c34079868.fselect,2,2,tp)
end
-- 选择解放素材：让玩家从可解放的怪兽中选出「龙剑士」和「龙魔王」各1只，并将选择结果保存到效果标签中供解放时使用。
function c34079868.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家tp当前可解放的怪兽组。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 向玩家弹出“请选择要解放的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=g:SelectSubGroup(tp,c34079868.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 实际执行解放：取出之前保存的两只素材，以特殊召唤手续将其解放，完成特殊召唤代价。
function c34079868.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤手续为原因解放选中的「龙剑士」和「龙魔王」怪兽。
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- ①效果发动条件的判定：这张卡不处于战斗破坏确定状态，且当前连锁的效果可以被无效。
function c34079868.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 确认当前发动的效果连锁可以无效。
	return Duel.IsChainNegatable(ev)
end
-- ①效果发动目标处理：登记“无效”和可选的“破坏”操作信息，供后续处理及卡片互动使用。
function c34079868.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记将连锁上的那个效果发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若被无效的发动来源怪兽/卡可以被破坏且仍与效果关联，登记将其破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ①效果的解决：使连锁上的效果发动无效，若成功则破坏对应的那张卡。
function c34079868.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 若无效发动成功且原发动卡仍与该效果关联，则执行破坏处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将被无效的那张卡以效果原因破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- ②效果触发条件的判定：这张卡被对方从场上破坏，且被破坏前由自己控制。
function c34079868.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选卡组中可特殊召唤的「龙剑士」怪兽，同时确认卡组中还存在1只可特殊召唤的「龙魔王」怪兽。
function c34079868.spfilter1(c,e,tp)
	return c:IsSetCard(0xc7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查卡组中是否还存在1只可特殊召唤的「龙魔王」怪兽，以保证两只素材齐全。
		and Duel.IsExistingMatchingCard(c34079868.spfilter2,tp,LOCATION_DECK,0,1,c,e,tp)
end
-- 筛选卡组中可特殊召唤的「龙魔王」怪兽。
function c34079868.spfilter2(c,e,tp)
	return c:IsSetCard(0xda) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件判定：主怪兽区至少2个空位、未受「青眼精灵龙」效果限制、且卡组中存在符合条件的「龙剑士」和「龙魔王」各1只。
function c34079868.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认主怪兽区空位大于1，以容纳特殊召唤的2只怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认卡组中存在满足条件的「龙剑士」怪兽（同时保证有对应的「龙魔王」存在）。
		and Duel.IsExistingMatchingCard(c34079868.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记将从卡组把2只怪兽特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- ②效果处理：再次确认仍有2个空位且不受「青眼精灵龙」限制，然后从卡组选出「龙剑士」和「龙魔王」各1只进行特殊召唤。
function c34079868.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 确认主怪兽区空位仍不少于2个。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只符合条件的「龙剑士」怪兽。
	local g1=Duel.SelectMatchingCard(tp,c34079868.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只符合条件的「龙魔王」怪兽（排除已选的「龙剑士」）。
	local g2=Duel.SelectMatchingCard(tp,c34079868.spfilter2,tp,LOCATION_DECK,0,1,1,g1:GetFirst(),e,tp)
	g1:Merge(g2)
	if g1:GetCount()==2 then
		-- 将选中的「龙剑士」和「龙魔王」各1只以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
	end
end
