--WAKE CUP！ マキ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡和手卡1只反转怪兽给对方观看才能发动。那2只里侧守备表示特殊召唤。
-- ②：这张卡反转的场合，以场上1只里侧守备表示怪兽为对象发动。那只怪兽变成表侧攻击表示。
-- ③：自己结束阶段，以场上1张里侧表示卡为对象才能发动。那张卡送去墓地。
local s,id,o=GetID()
-- 初始化卡片效果，注册①②③效果。
function s.initial_effect(c)
	-- ①：把手卡的这张卡和手卡1只反转怪兽给对方观看才能发动。那2只里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡反转的场合，以场上1只里侧守备表示怪兽为对象发动。那只怪兽变成表侧攻击表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"表示形式变更"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	-- ③：自己结束阶段，以场上1张里侧表示卡为对象才能发动。那张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"送去墓地"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
-- 过滤手牌中未公开且可以里侧守备表示特殊召唤的反转怪兽。
function s.costfilter(c,e,tp)
	return c:IsType(TYPE_FLIP) and not c:IsPublic() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- ①效果的发动代价：把手卡的这张卡和手卡1只反转怪兽给对方观看。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手牌中是否存在除自身以外可特殊召唤的反转怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c,e,tp) end
	-- 提示玩家选择要给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家选择手牌中1只满足条件的反转怪兽。
	local sc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c,e,tp):GetFirst()
	-- 将选择的怪兽给对方玩家确认。
	Duel.ConfirmCards(1-tp,sc)
	-- 洗切自身手牌。
	Duel.ShuffleHand(tp)
	sc:CreateEffectRelation(e)
	e:SetLabelObject(sc)
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"因「睡醒一杯！玛奇朵咖啡」的效果被观看"
	sc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"因「睡醒一杯！玛奇朵咖啡」的效果被观看"
end
-- ①效果的发动准备：检查是否满足特殊召唤2只怪兽的条件，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 检查自己场上的怪兽区域空位数是否大于1。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and not e:GetHandler():IsPublic() end
	-- 设置特殊召唤2只手牌怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
-- ①效果的处理：将自身与选中的反转怪兽里侧守备表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sc=e:GetLabelObject()
	local g=Group.FromCards(c,sc)
	local fg=g:Filter(Card.IsRelateToChain,nil)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 若怪兽区域空位数不足2个，则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	if not c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) or not sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) then return end
	if fg:GetCount()~=2 then return end
	-- 将这2只怪兽里侧守备表示特殊召唤。
	Duel.SpecialSummon(fg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 过滤场上的里侧守备表示怪兽。
function s.posfilter(c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE)
end
-- ②效果的发动准备：选择场上1只里侧守备表示怪兽为对象。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择场上1只里侧守备表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置改变表示形式的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- ②效果的处理：将作为对象的怪兽变成表侧攻击表示。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsFacedown() then
		-- 将该怪兽的表示形式变更为表侧攻击表示。
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
	end
end
-- ③效果的发动条件：自己回合的结束阶段。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己。
	return Duel.GetTurnPlayer()==tp
end
-- 过滤场上可以送去墓地的里侧表示卡片。
function s.tgfilter(c)
	return c:IsFacedown() and c:IsAbleToGrave()
end
-- ③效果的发动准备：选择场上1张里侧表示卡片为对象。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.tgfilter(chkc) end
	-- 检查场上是否存在可以送去墓地的里侧表示卡片。
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上1张里侧表示卡片作为效果对象。
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置将该卡送去墓地的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- ③效果的处理：将作为对象的卡送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 因效果将该卡送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
