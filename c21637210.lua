--ファイアウォール・ドラゴン・シンギュラリティ
-- 效果：
-- 效果怪兽3只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，以最多有自己的场上·墓地的怪兽种类（仪式·融合·同调·超量）数量的对方的场上·墓地的卡为对象才能发动。那些卡回到手卡。这张卡的攻击力上升回去数量×500。
-- ②：这张卡所连接区的怪兽被战斗破坏的场合或者被送去墓地的场合，以自己墓地1只电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
function c21637210.initial_effect(c)
	-- 为c添加连接召唤手续，需要3个满足过滤条件f的怪兽作为素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),3)
	c:EnableReviveLimit()
	-- ①：自己·对方回合，以最多有自己的场上·墓地的怪兽种类（仪式·融合·同调·超量）数量的对方的场上·墓地的卡为对象才能发动。那些卡回到手卡。这张卡的攻击力上升回去数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21637210,0))  --"对方卡回到手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,21637210)
	-- 限制效果只能在伤害步骤或者尚未进行伤害计算时发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c21637210.thtg)
	e1:SetOperation(c21637210.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡所连接区的怪兽被战斗破坏的场合或者被送去墓地的场合，以自己墓地1只电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c21637210.regcon)
	e2:SetOperation(c21637210.regop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c21637210.regcon2)
	c:RegisterEffect(e3)
	-- 墓地电子界族怪兽特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(21637210,1))  --"墓地电子界族怪兽特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_CUSTOM+21637210)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,21637211)
	e4:SetTarget(c21637210.sptg)
	e4:SetOperation(c21637210.spop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于筛选仪式、融合、同调或超量怪兽，且处于场上或墓地的表侧表示怪兽。
function c21637210.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) and c:IsFaceupEx()
end
-- 设置效果的描述为“对方卡回到手卡”，类别为回手和攻击力改变，类型为快速效果，属性为可取对象且可在伤害步骤发动，代码为自由连锁，发动范围为主怪兽区，提示时机为伤害步骤、怪兽正面上场或结束阶段，限制每回合使用次数为1次。
function c21637210.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 检索满足条件的卡片组
	local g=Duel.GetMatchingGroup(c21637210.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 检查是否有可作为目标的手牌
	if chk==0 then return #g>0 and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	local ct=0
	for i,type in ipairs({TYPE_RITUAL,TYPE_FUSION,TYPE_SYNCHRO,TYPE_XYZ}) do
		if g:IsExists(Card.IsType,1,nil,type) then
			ct=ct+1
		end
	end
	-- 向玩家发送提示信息，选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择要返回手牌的目标卡。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,ct,nil)
	-- 设置操作信息为回手效果，目标卡组为选定的卡片，数量为选定卡的数量。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- 执行效果：将目标卡送回手牌并提升攻击力。
function c21637210.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中的目标卡
	local g=Duel.GetTargetsRelateToChain()
	if #g==0 then return end
	-- 将目标卡送去持有者的手牌
	local ct=Duel.SendtoHand(g,nil,REASON_EFFECT)
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 提升攻击力，数值为返回手牌的数量乘以500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 自定义过滤函数，用于判断怪兽是否在之前的回合位于主怪兽区，并且其序列号与当前连接区的顺序匹配。
function c21637210.cfilter(c,tp,zone)
	local seq=c:GetPreviousSequence()
	if c:IsPreviousControler(1-tp) then seq=seq+16 end
	return c:IsPreviousLocation(LOCATION_MZONE) and bit.extract(zone,seq)~=0
end
-- 设置效果的条件：如果存在满足cfilter条件的卡片在连接区域，则可以发动效果。
function c21637210.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c21637210.cfilter,1,nil,tp,e:GetHandler():GetLinkedZone())
end
-- 自定义过滤函数，用于判断怪兽是否不是因为战斗被破坏送去墓地，并且满足cfilter条件。
function c21637210.cfilter2(c,tp,zone)
	return not c:IsReason(REASON_BATTLE) and c21637210.cfilter(c,tp,zone)
end
-- 设置效果的条件：如果存在满足cfilter2条件的卡片在连接区域，则可以发动效果。
function c21637210.regcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c21637210.cfilter2,1,nil,tp,e:GetHandler():GetLinkedZone())
end
-- 触发事件后执行的操作：发送自定义事件。
function c21637210.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送自定义事件
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+21637210,e,0,tp,0,0)
end
-- 过滤函数，用于筛选种族为电子界族的怪兽，且可以特殊召唤的怪兽。
function c21637210.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的目标：从墓地选择一只符合条件的电子界族怪兽进行特殊召唤。
function c21637210.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21637210.spfilter(chkc,e,tp) end
	-- 检查场上是否有可用的怪兽区
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足spfilter条件的卡片在墓地中
		and Duel.IsExistingTarget(c21637210.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送提示信息，选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择要特殊召唤的目标卡。
	local g=Duel.SelectTarget(tp,c21637210.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤效果，目标卡组为选定的卡片，数量为1张。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行效果：将目标怪兽特殊召唤到场上。
function c21637210.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取第一个目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 特殊召唤目标怪兽。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
