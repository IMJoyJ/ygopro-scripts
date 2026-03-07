--霊魂鳥影－姫孔雀
-- 效果：
-- 「灵魂的降神」降临
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在手卡·场上存在当作「灵魂鸟神-姬孔雀」使用。
-- ②：这张卡仪式召唤的场合才能发动。效果文本有「灵魂怪兽」记述的1张魔法·陷阱卡从卡组加入手卡。
-- ③：这张卡被除外的下个回合的准备阶段发动。除外状态的这张卡特殊召唤。
-- ④：这张卡特殊召唤的回合的结束阶段发动。这张卡回到手卡。
local s,id,o=GetID()
-- 初始化卡片效果，启用复活限制，设置卡名变更效果，创建②效果、③效果和④效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 使该卡在手牌或场上时视为「灵魂鸟神-姬孔雀」
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
	-- 为该卡添加特殊召唤成功时回到手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SPSUMMON_SUCCESS)
end
-- ②效果的发动条件：该卡为仪式召唤
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 检索过滤函数：筛选卡组中类型为魔法或陷阱且文本包含「灵魂怪兽」的卡
function s.filter(c)
	-- 筛选卡组中类型为魔法或陷阱且文本包含「灵魂怪兽」的卡
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.IsTypeInText(c,TYPE_SPIRIT) and c:IsAbleToHand()
end
-- ②效果的发动时点处理：确认卡组中存在满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认卡组中存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的发动处理：选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③效果的触发处理：记录除外时的回合数
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 记录除外时的回合数用于后续判断
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,2,Duel.GetTurnCount())
end
-- ③效果的发动条件：除外的回合数+1为当前回合
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetFlagEffectLabel(id)
	-- 获取当前回合数
	local tn=Duel.GetTurnCount()
	if not ct or tn==ct then
		c:ResetFlagEffect(id)
		return false
	else return tn==ct+1 end
end
-- ④效果的发动时点处理：设置特殊召唤的连锁操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ④效果的发动处理：将该卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认该卡能被特殊召唤并执行特殊召唤
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
