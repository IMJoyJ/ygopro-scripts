--ぜんなのついなぎひめ
-- 效果：
-- 效果怪兽2只以上
-- 这张卡连接召唤的场合，手卡1只怪兽也能作为连接素材。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组把1只怪兽送去墓地。只用自己场上的怪兽为素材作连接召唤的场合，也能从额外卡组选送去墓地的怪兽。
-- ②：这张卡从场上送去墓地的场合，下次的自己准备阶段才能发动。从自己墓地把1只怪兽加入手卡。
local s,id,o=GetID()
-- 注册“禅那之追傩仪姬”的卡片效果：注册连接召唤手续与召唤素材限制，作为效果外文本的手卡怪兽连接素材效果，连接召唤成功时从卡组/额外卡组送墓的效果①，素材检查效果，以及送去墓地时在下次自己准备阶段回收墓地怪兽的效果②。
function s.initial_effect(c)
	-- 为卡片添加连接召唤手续：需要2只以上的效果怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	c:EnableReviveLimit()
	-- 这张卡连接召唤的场合，手卡1只怪兽也能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetValue(s.matval)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡连接召唤的场合才能发动。从卡组把1只怪兽送去墓地。只用自己场上的怪兽为素材作连接召唤的场合，也能从额外卡组选送去墓地的怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	-- 只用自己场上的怪兽为素材作连接召唤的场合，也能从额外卡组选送去墓地的怪兽。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ②：这张卡从场上送去墓地的场合，下次的自己准备阶段才能发动。从自己墓地把1只怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetOperation(s.spr)
	c:RegisterEffect(e4)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡从场上送去墓地的场合，下次的自己准备阶段才能发动。从自己墓地把1只怪兽加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))  --"加入手卡"
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,id+o)
	e5:SetCondition(s.thcon)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
end
-- 过滤条件判断：检查怪兽是否在手牌中（判定手牌怪兽是否作为连接素材）。
function s.is_goddess_opp(mc)
	return mc:IsLocation(LOCATION_HAND)
end
-- 手卡连接素材效果的有效性与数量限制判定：限制此效果仅对这张卡自身有效，且作为素材的怪兽必须来自手牌，且最多只能使用1只手牌怪兽作为连接素材。
function s.matval(e,lc,mg,c,tp)
	if e:GetHandler()~=lc then return false,nil end
	if not c:IsLocation(LOCATION_HAND) then return false,nil end
	if not mg then
		return true,true
	end
	if mg:IsExists(s.is_goddess_opp,1,c) then
		return true,false
	end
	return true,true
end
-- 连接素材过滤函数：检查怪兽是否不在场上（即来自手牌）或者是由对方控制。
function s.matfilter(c,tp)
	return not c:IsLocation(LOCATION_ONFIELD) or c:IsControler(1-tp)
end
-- 连接素材检查函数：检查连接召唤这张卡所使用的素材，如果所有素材均来自自己场上的怪兽，则将关联效果（e2）的标签值设置为1（允许从额外卡组将怪兽送去墓地），否则设为0。
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local tp=c:GetControler()
	if g:GetCount()>0 and not g:IsExists(s.matfilter,1,nil,tp) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 效果①的发动条件：这张卡连接召唤成功的场合。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤函数：检索满足是怪兽且可以送去墓地条件的卡片。
function s.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果①的发动准备（Target）：根据连接素材的检测标签值，确定送墓的范围（若仅以场上怪兽为素材则包含额外卡组，否则仅包含卡组）；检查是否存在可送去墓地的怪兽，并设置送去墓地的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_DECK
	if e:GetLabel()==1 then loc=loc+LOCATION_EXTRA end
	-- 效果发动判定：检查指定区域（卡组或卡组+额外卡组）中是否存在至少1张怪兽卡可以送去墓地。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,loc,0,1,nil) end
	-- 设置操作信息：将指定区域的1只怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,loc)
end
-- 效果①的效果处理（Operation）：根据素材判定标签确定送墓区域（仅卡组，或额外卡组加卡组），让玩家从中选择1只怪兽送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_DECK
	if e:GetLabel()==1 then loc=loc+LOCATION_EXTRA end
	-- 给玩家显示“选择要送去墓地的卡”的系统提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从指定区域（卡组或卡组加额外卡组）选择1张满足条件的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,loc,0,1,1,nil)
	if g:GetCount()>0 then
		-- 以效果原因将选中的卡送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 事件触发回调：当这张卡从场上送去墓地时，根据当前阶段和回合，在自身注册一个在下次自己准备阶段时重置的标记效果，用于后续效果的触发判定。
function s.spr(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsPreviousLocation(LOCATION_ONFIELD) then return end
	-- 判定当前是否正是己方的准备阶段。
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 将当前的回合数记录在效果的标签中。
		e:SetLabel(Duel.GetTurnCount())
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2)
	else
		e:SetLabel(0)
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
	end
end
-- 效果②的发动条件：当前回合非送墓回合、当前是自己的准备阶段、且卡片具有有效的送墓标记效果。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定当前回合数不同于送去墓地的回合数，且当前是自己的准备阶段，并且该卡带有送墓的标识效果。
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and tp==Duel.GetTurnPlayer() and c:GetFlagEffect(id)>0
end
-- 过滤函数：检索满足是怪兽且可以加入手牌条件的卡片。
function s.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的发动准备（Target）：检查墓地是否存在可以加入手牌的怪兽，并设置加入手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 效果发动判定：检查己方墓地中是否存在至少1张可以加入手牌的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：从墓地将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的效果处理（Operation）：从己方墓地选择1只不受“王家长眠之谷”影响的怪兽加入手牌，并向对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示“选择要加入手牌的卡”的系统提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从墓地选择1张不受“王家长眠之谷”影响且符合条件的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 以效果原因将选中的怪兽送入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的怪兽卡向对方玩家进行确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
