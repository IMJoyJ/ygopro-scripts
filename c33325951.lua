--霊魂鳥影－姫孔雀
-- 效果：
-- 「灵魂的降神」降临
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在手卡·场上存在当作「灵魂鸟神-姬孔雀」使用。
-- ②：这张卡仪式召唤的场合才能发动。效果文本有「灵魂怪兽」记述的1张魔法·陷阱卡从卡组加入手卡。
-- ③：这张卡被除外的下个回合的准备阶段发动。除外状态的这张卡特殊召唤。
-- ④：这张卡特殊召唤的回合的结束阶段发动。这张卡回到手卡。
local s,id,o=GetID()
-- 初始化效果注册函数。
function s.initial_effect(c)
	-- 注册卡片密码73055622（灵魂的降神）至当前卡片的记载卡密码列表中。
	aux.AddCodeList(c,73055622)
	c:EnableReviveLimit()
	-- 设置这张卡的卡名在手卡·场上当作「灵魂鸟神-姬孔雀」使用。
	aux.EnableChangeCode(c,25415052,LOCATION_HAND+LOCATION_ONFIELD)
	-- ②：这张卡仪式召唤的场合才能发动。效果文本有「灵魂怪兽」记述的1张魔法·陷阱卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ③：这张卡被除外的下个回合的准备阶段发动。除外状态的这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	-- ④：这张卡特殊召唤的回合的结束阶段发动。这张卡回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- 为当前卡片注册灵魂怪兽的结束阶段回到手牌效果。
	aux.EnableSpiritReturn(c,EVENT_SPSUMMON_SUCCESS)
end
-- 效果发动条件为这张卡是被仪式召唤的场合。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤函数，筛选卡组里是魔法·陷阱卡、且效果文本记述了“灵魂怪兽”并且可加入手牌的卡。
function s.filter(c)
	-- 检查卡片是否是魔法·陷阱卡、且其效果文本中是否记述了灵魂怪兽类型，并且当前可以被加入手卡。
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.IsTypeInText(c,TYPE_SPIRIT) and c:IsAbleToHand()
end
-- 效果发动目标，判断卡组中是否存在符合过滤条件的魔法·陷阱卡，并注册加入手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张文本中记述了灵魂怪兽的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将卡组中的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理逻辑，将符合条件的卡从卡组加入手牌并确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组检索1张符合过滤条件的魔法或陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡片加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方确认所检索的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 当前卡片被除平时，为其注册一个在两个回合后（下个回合准备阶段）失效的Flag标记，并记录被除外时的回合数。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 给这张卡注册标志性效果（Flag），标记其已被除外且记录其被除外的回合。
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,2,Duel.GetTurnCount())
end
-- 特殊召唤效果的发动条件，判断是否是在被除外的下个回合的准备阶段。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetFlagEffectLabel(id)
	-- 获取当前的回合数。
	local tn=Duel.GetTurnCount()
	if not ct or tn==ct then
		c:ResetFlagEffect(id)
		return false
	else return tn==ct+1 end
end
-- 特殊召唤效果的目标确认，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的具体处理逻辑，将这张卡以表侧表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果这张卡与触发的效果有关，则将其特殊召唤到自己的场上。
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
