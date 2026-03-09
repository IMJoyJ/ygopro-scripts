--音響戦士サイザス
-- 效果：
-- ①：这张卡反转的场合才能发动。从卡组把「音响战士 合成器」以外的1只「音响战士」怪兽加入手卡。
-- ②：1回合1次，以「音响战士 合成器」以外的自己的场上·墓地1只「音响战士」怪兽为对象才能发动。这张卡直到结束阶段当作和那只怪兽同名卡使用，得到相同效果。
-- ③：把墓地的这张卡除外，以「音响战士 合成器」以外的除外的1只自己的「音响战士」怪兽为对象才能发动。那只怪兽特殊召唤。
function c49919798.initial_effect(c)
	-- ①：这张卡反转的场合才能发动。从卡组把「音响战士 合成器」以外的1只「音响战士」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49919798,0))  --"复制效果结束"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c49919798.thtg)
	e1:SetOperation(c49919798.thop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以「音响战士 合成器」以外的自己的场上·墓地1只「音响战士」怪兽为对象才能发动。这张卡直到结束阶段当作和那只怪兽同名卡使用，得到相同效果。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49919798,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCost(c49919798.cpcost)
	e2:SetTarget(c49919798.cptg)
	e2:SetOperation(c49919798.cpop)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外，以「音响战士 合成器」以外的除外的1只自己的「音响战士」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(49919798,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 将此卡除外作为cost
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c49919798.sptg)
	e3:SetOperation(c49919798.spop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的卡片组（非合成器的音响战士怪兽）
function c49919798.thfilter(c)
	return c:IsSetCard(0x1066) and not c:IsCode(49919798) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 判断是否能发动效果（是否有满足条件的怪兽）
function c49919798.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 设置连锁操作信息为检索满足条件的卡片组
	if chk==0 then return Duel.IsExistingMatchingCard(c49919798.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息为将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 选择并执行将目标怪兽加入手牌的操作
function c49919798.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的1张怪兽卡
	local g=Duel.SelectMatchingCard(tp,c49919798.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 设置效果发动的cost（检查是否已使用过此效果）
function c49919798.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(49919798)==0 end
	e:GetHandler():RegisterFlagEffect(49919798,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 过滤目标怪兽（表侧表示的音响战士怪兽，非合成器）
function c49919798.cpfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1066) and not c:IsCode(49919798)
end
-- 判断是否能发动效果（是否有满足条件的目标怪兽）
function c49919798.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c49919798.cpfilter(chkc) end
	-- 设置连锁操作信息为选择目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c49919798.cpfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的目标怪兽
	Duel.SelectTarget(tp,c49919798.cpfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
end
-- 执行将此卡变为与目标怪兽同名卡的效果
function c49919798.cpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and (not tc:IsLocation(LOCATION_MZONE) or tc:IsFaceup()) then
		local code=tc:GetCode()
		-- 创建一个使此卡变为指定代码的同名卡的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		c:RegisterEffect(e1)
		c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
	end
end
-- 过滤可特殊召唤的怪兽（表侧表示的音响战士怪兽，非合成器）
function c49919798.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x1066) and not c:IsCode(49919798) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否能发动效果（是否有满足条件的目标怪兽）
function c49919798.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c49919798.spfilter(chkc,e,tp) end
	-- 检查场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 设置连锁操作信息为选择目标怪兽
		and Duel.IsExistingTarget(c49919798.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从除外区中选择满足条件的1只怪兽
	local g=Duel.SelectTarget(tp,c49919798.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置连锁操作信息为特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行将目标怪兽特殊召唤的操作
function c49919798.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
