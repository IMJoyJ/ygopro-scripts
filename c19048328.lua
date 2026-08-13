--幻竜星－チョウホウ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：只要同调召唤的这张卡在怪兽区域存在，对方不能把原本属性和作为这张卡的同调素材的「龙星」怪兽相同的怪兽的效果发动。
-- ②：同调召唤的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把1只调整加入手卡。
-- ③：1回合1次，对方场上的怪兽被战斗·效果破坏时才能发动。原本属性和那1只怪兽相同的1只幻龙族怪兽从自己卡组守备表示特殊召唤。
function c19048328.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上（调整无额外限制，调整以外的怪兽至少1只）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 原本属性和作为这张卡的同调素材的「龙星」怪兽相同（本段为同调素材检查，记录素材中「龙星」怪兽的原本属性）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c19048328.matcheck)
	c:RegisterEffect(e1)
	-- ①：只要同调召唤的这张卡在怪兽区域存在，对方不能把原本属性和作为这张卡的同调素材的「龙星」怪兽相同的怪兽的效果发动。（同调召唤成功时注册该效果）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c19048328.regcon)
	e2:SetOperation(c19048328.regop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：同调召唤的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把1只调整加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19048328,0))  --"卡组调整加入手卡"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c19048328.thcon)
	e3:SetTarget(c19048328.thtg)
	e3:SetOperation(c19048328.thop)
	c:RegisterEffect(e3)
	-- ③：1回合1次，对方场上的怪兽被战斗·效果破坏时才能发动。原本属性和那1只怪兽相同的1只幻龙族怪兽从自己卡组守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(19048328,1))  --"卡组怪兽特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCountLimit(1)
	e4:SetCondition(c19048328.spcon)
	e4:SetTarget(c19048328.sptg)
	e4:SetOperation(c19048328.spop)
	c:RegisterEffect(e4)
end
-- 同调素材检查函数：筛选出作为同调素材的「龙星」（0x9e）怪兽，将它们的原本属性按位或合并后存入e的Label，供①效果判断属性是否相同。
function c19048328.matcheck(e,c)
	local g=c:GetMaterial():Filter(Card.IsSetCard,nil,0x9e)
	local att=0
	local tc=g:GetFirst()
	while tc do
		att=bit.bor(att,tc:GetOriginalAttribute())
		tc=g:GetNext()
	end
	e:SetLabel(att)
end
-- 条件函数：此卡以同调召唤方式特殊召唤成功时（SUMMON_TYPE_SYNCHRO）返回true，用于触发后续的①效果注册。
function c19048328.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 同调召唤成功时的处理：创建并注册针对对方的EFFECT_CANNOT_ACTIVATE封印效果（范围为此卡在怪兽区域存在期间），同时根据记录的素材属性为这张卡添加客户端提示标记（如地/水/炎/风/光/暗/神属性「龙星」素材）。
function c19048328.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 对方不能把原本属性和作为这张卡的同调素材的「龙星」怪兽相同的怪兽的效果发动（创建EFFECT_CANNOT_ACTIVATE封印，aclimit判定命中）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c19048328.aclimit)
	e1:SetLabelObject(e:GetLabelObject())
	c:RegisterEffect(e1)
	local att=e:GetLabelObject():GetLabel()
	if bit.band(att,ATTRIBUTE_EARTH)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(19048328,2))  --"地属性「龙星」怪兽作为同调素材"
	end
	if bit.band(att,ATTRIBUTE_WATER)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(19048328,3))  --"水属性「龙星」怪兽作为同调素材"
	end
	if bit.band(att,ATTRIBUTE_FIRE)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(19048328,4))  --"炎属性「龙星」怪兽作为同调素材"
	end
	if bit.band(att,ATTRIBUTE_WIND)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(19048328,5))  --"风属性「龙星」怪兽作为同调素材"
	end
	if bit.band(att,ATTRIBUTE_LIGHT)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(19048328,6))  --"光属性「龙星」怪兽作为同调素材"
	end
	if bit.band(att,ATTRIBUTE_DARK)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(19048328,7))  --"暗属性「龙星」怪兽作为同调素材"
	end
	if bit.band(att,ATTRIBUTE_DIVINE)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(19048328,8))  --"神属性「龙星」怪兽作为同调素材"
	end
end
-- 封印判定函数：若被发动的效果是怪兽效果，且该怪兽的原本属性与记录的素材属性（按位与）不为0，则禁止发动。
function c19048328.aclimit(e,re,tp)
	local att=e:GetLabelObject():GetLabel()
	return re:IsActiveType(TYPE_MONSTER) and bit.band(att,re:GetHandler():GetOriginalAttribute())~=0
end
-- ②效果的条件：这张卡以同调召唤方式被战斗或效果破坏并送去墓地，且破坏前在怪兽区域时满足发动条件。
function c19048328.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 检索过滤：卡组中存在满足调整类型且可以加入手卡的怪兽。
function c19048328.thfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end
-- ②效果的发动目标：确认卡组中有1只调整怪兽可检索，并设置将卡组1张卡加入手卡的操作信息。
function c19048328.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：自己卡组是否存在至少1只符合条件的调整怪兽（chk==0时返回合法性）。
	if chk==0 then return Duel.IsExistingMatchingCard(c19048328.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将1张卡从卡组加入手卡（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：玩家从卡组选择1只调整怪兽，加入手卡并向对方展示。
function c19048328.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡片（HINTMSG_ATOHAND）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让当前玩家从卡组选择1只符合条件的调整怪兽（1张）。
	local g=Duel.SelectMatchingCard(tp,c19048328.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片因效果加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 筛选条件：对方场上的怪兽被战斗或效果破坏、原本属性非0、破坏前在怪兽区域，且之前控制者是对方（p）。
function c19048328.cfilter(c,p)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:GetOriginalAttribute()~=0
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(p)
end
-- ③效果的条件：筛选出对方场上被战斗或效果破坏的怪兽，合并其原本属性存入e:SetLabel；存在则允许发动。
function c19048328.spcon(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c19048328.cfilter,nil,1-tp)
	if g:GetCount()>0 then
		local att=0
		local tc=g:GetFirst()
		while tc do
			att=bit.bor(att,tc:GetOriginalAttribute())
			tc=g:GetNext()
		end
		e:SetLabel(att)
		return true
	else return false end
end
-- 特殊召唤过滤：卡组中的幻龙族（RACE_WYRM）怪兽，其原本属性与破坏怪兽的属性有交集，且可以以表侧守备表示特殊召唤。
function c19048328.spfilter(c,e,tp,att)
	return c:IsRace(RACE_WYRM) and bit.band(att,c:GetOriginalAttribute())~=0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ③效果的发动目标：自己怪兽区域有空位，且卡组存在符合条件的幻龙族怪兽，并设置特殊召唤操作信息。
function c19048328.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：自己主要怪兽区域是否存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查卡组中是否存在符合条件的幻龙族怪兽（用于合法性）。
		and Duel.IsExistingMatchingCard(c19048328.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,e:GetLabel()) end
	-- 设置操作信息：本次效果将1只怪兽从卡组特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：从卡组选择1只符合条件的幻龙族怪兽，以表侧守备表示特殊召唤。
function c19048328.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己怪兽区域有空位，若没有则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片（HINTMSG_SPSUMMON）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只符合条件的幻龙族怪兽（1张）。
	local g=Duel.SelectMatchingCard(tp,c19048328.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
