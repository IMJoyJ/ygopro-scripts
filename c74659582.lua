--神碑の鬣スレイプニル
-- 效果：
-- 「神碑」怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段以及对方战斗阶段，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽和这张卡直到结束阶段除外。
-- ②：对方从卡组把卡加入手卡的场合才能发动。在自己场上把1只「神碑衍生物」（天使族·光·4星·攻/守1500）攻击表示特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含融合召唤手续、①效果（二速除外自己与对方场上表侧怪兽）和②效果（对方从卡组加手时特召神碑衍生物）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为2只「神碑」怪兽。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x17f),2,true)
	-- ①：自己主要阶段以及对方战斗阶段，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽和这张卡直到结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"怪兽除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ②：对方从卡组把卡加入手卡的场合才能发动。在自己场上把1只「神碑衍生物」（天使族·光·4星·攻/守1500）攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"召唤衍生物"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.tkcon)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
end
-- 判定当前是否为自己主要阶段或对方战斗阶段。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的回合玩家。
	local tn=Duel.GetTurnPlayer()
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	return (tn==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2))
		or (tn==1-tp and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
-- 过滤对方场上表侧表示且可以除外的怪兽。
function s.filter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- ①效果的发动准备与目标选择，确认自身和对方场上1只表侧表示怪兽是否可以除外，并进行取对象和设置操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.rfilter(chkc) end
	local c=e:GetHandler()
	-- 检查自身是否可以除外，以及对方场上是否存在可作为除外对象的表侧表示怪兽。
	if chk==0 then return c:IsAbleToRemove() and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向对方玩家提示发动了该效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	g:AddCard(c)
	-- 设置效果处理信息为除外这2张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
-- ①效果的处理，将自身和对象怪兽暂时除外，并注册在结束阶段将它们返回场上的延迟效果。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or not c:IsRelateToEffect(e) then return end
	local g=Group.FromCards(tc,c)
	-- 将自身和对象怪兽以效果原因暂时除外，并确认是否有卡片成功被除外。
	if Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)~=0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) then
		-- 获取本次操作中实际被除外的卡片组。
		local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED)
		if c:GetOriginalCode()~=id then
			og:RemoveCard(c)
		end
		-- 遍历实际被除外的卡片。
		for oc in aux.Next(og) do
			oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
		og:KeepAlive()
		-- 直到结束阶段除外。②：对方从卡组把卡加入手卡的场合才能发动。在自己场上把1只「神碑衍生物」（天使族·光·4星·攻/守1500）攻击表示特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(og)
		e1:SetCountLimit(1)
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		-- 注册在回合结束阶段触发的延迟效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤带有此卡效果标记的卡片，用于在结束阶段返回场上。
function s.retfilter(c)
	return c:GetFlagEffect(id)~=0
end
-- 检查是否存在需要返回场上的卡片，若无则重置该延迟效果。
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetLabelObject():IsExists(s.retfilter,1,nil) then
		e:GetLabelObject():DeleteGroup()
		e:Reset()
		return false
	end
	return true
end
-- 在结束阶段将之前被暂时除外的卡片返回场上。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():Filter(s.retfilter,nil)
	-- 遍历需要返回场上的卡片。
	for tc in aux.Next(g) do
		-- 将卡片返回到场上。
		Duel.ReturnToField(tc)
	end
end
-- 过滤从卡组加入手卡的卡片。
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK)
end
-- 判定是否满足对方从卡组把卡加入手卡的条件。
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- ②效果的发动准备，检查怪兽区域空位以及是否能特殊召唤神碑衍生物。
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤符合神碑衍生物属性、种族、攻守等数值的怪兽。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0x17f,TYPES_TOKEN_MONSTER,1500,1500,4,RACE_FAIRY,ATTRIBUTE_LIGHT,POS_FACEUP_ATTACK) end
	-- 向对方玩家提示发动了该效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果处理信息为产生1只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置效果处理信息为特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
-- ②效果的处理，在自己场上将1只「神碑衍生物」以攻击表示特殊召唤。
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否没有可用的怪兽区域空格。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 检查若无法特殊召唤符合神碑衍生物数值的怪兽则不处理。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0x17f,TYPES_TOKEN_MONSTER,1500,1500,4,RACE_FAIRY,ATTRIBUTE_LIGHT,POS_FACEUP_ATTACK) then return end
	-- 创建「神碑衍生物」卡片。
	local tk=Duel.CreateToken(tp,id+o)
	-- 将衍生物以攻击表示特殊召唤到自己场上。
	Duel.SpecialSummon(tk,0,tp,tp,false,false,POS_FACEUP_ATTACK)
end
