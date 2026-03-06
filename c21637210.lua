--ファイアウォール・ドラゴン・シンギュラリティ
-- 效果：
-- 效果怪兽3只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，以最多有自己的场上·墓地的怪兽种类（仪式·融合·同调·超量）数量的对方的场上·墓地的卡为对象才能发动。那些卡回到手卡。这张卡的攻击力上升回去数量×500。
-- ②：这张卡所连接区的怪兽被战斗破坏的场合或者被送去墓地的场合，以自己墓地1只电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
function c21637210.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用至少3个效果怪兽作为连接素材
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
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,21637210)
	-- 设置效果发动条件为不能在伤害步骤后发动
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
	-- ②：这张卡所连接区的怪兽被战斗破坏的场合或者被送去墓地的场合，以自己墓地1只电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
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
-- 定义一个过滤函数，用于筛选场上或墓地中的效果怪兽
function c21637210.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) and c:IsFaceupEx()
end
-- 设置效果的发动条件和目标选择逻辑，根据场上和墓地中的怪兽数量确定最多可选择的对方卡数
function c21637210.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 获取满足条件的己方场上或墓地中的怪兽组
	local g=Duel.GetMatchingGroup(c21637210.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 判断是否满足发动条件，即己方场上或墓地中有怪兽且对方场上或墓地中有卡可选择
	if chk==0 then return #g>0 and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	local ct=0
	for i,type in ipairs({TYPE_RITUAL,TYPE_FUSION,TYPE_SYNCHRO,TYPE_XYZ}) do
		if g:IsExists(Card.IsType,1,nil,type) then
			ct=ct+1
		end
	end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 根据选择的卡数选择对方场上或墓地中的卡作为目标
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,ct,nil)
	-- 设置效果操作信息，表示将选择的卡返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- 设置效果的处理逻辑，将目标卡返回手牌并根据返回数量提升攻击力
function c21637210.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取与当前连锁相关的卡作为目标
	local g=Duel.GetTargetsRelateToChain()
	if #g==0 then return end
	-- 将目标卡送入手牌，返回实际送入手牌的卡数
	local ct=Duel.SendtoHand(g,nil,REASON_EFFECT)
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- ②：这张卡所连接区的怪兽被战斗破坏的场合或者被送去墓地的场合，以自己墓地1只电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 定义一个过滤函数，用于判断怪兽是否从己方场上被破坏或送去墓地
function c21637210.cfilter(c,tp,zone)
	local seq=c:GetPreviousSequence()
	if c:IsPreviousControler(1-tp) then seq=seq+16 end
	return c:IsPreviousLocation(LOCATION_MZONE) and bit.extract(zone,seq)~=0
end
-- 设置触发条件，当己方连接区的怪兽被战斗破坏或送去墓地时触发
function c21637210.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c21637210.cfilter,1,nil,tp,e:GetHandler():GetLinkedZone())
end
-- 定义一个过滤函数，用于排除因战斗破坏而触发的怪兽
function c21637210.cfilter2(c,tp,zone)
	return not c:IsReason(REASON_BATTLE) and c21637210.cfilter(c,tp,zone)
end
-- 设置触发条件，当己方连接区的怪兽被送去墓地（非战斗破坏）时触发
function c21637210.regcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c21637210.cfilter2,1,nil,tp,e:GetHandler():GetLinkedZone())
end
-- 触发一个自定义时点，用于激活后续特殊召唤效果
function c21637210.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 触发一个自定义时点，用于激活后续特殊召唤效果
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+21637210,e,0,tp,0,0)
end
-- 定义一个过滤函数，用于筛选可特殊召唤的电子界族怪兽
function c21637210.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的发动条件和目标选择逻辑
function c21637210.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21637210.spfilter(chkc,e,tp) end
	-- 判断是否满足发动条件，即己方场上是否有空位且己方墓地中有电子界族怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件，即己方场上是否有空位且己方墓地中有电子界族怪兽
		and Duel.IsExistingTarget(c21637210.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择己方墓地中的一只电子界族怪兽作为特殊召唤目标
	local g=Duel.SelectTarget(tp,c21637210.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果操作信息，表示将选择的卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 设置效果的处理逻辑，将目标卡特殊召唤到己方场上
function c21637210.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡特殊召唤到己方场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
