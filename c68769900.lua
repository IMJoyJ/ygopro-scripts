--海造賊－赤髭の航海士
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方回合才能发动。把持有和对方的场上·墓地的怪兽的其中任意种相同属性的1只「海造贼」怪兽从额外卡组特殊召唤，自己场上的这张卡当作装备卡使用给那只怪兽装备。
-- ②：这张卡从手卡·怪兽区域送去墓地的场合，以「海造贼-红胡子航海士」以外的自己场上1只「海造贼」怪兽为对象才能发动。这张卡当作装备卡使用给那只怪兽装备。
function c68769900.initial_effect(c)
	-- ①：对方回合才能发动。把持有和对方的场上·墓地的怪兽的其中任意种相同属性的1只「海造贼」怪兽从额外卡组特殊召唤，自己场上的这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68769900,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,68769900)
	e1:SetCondition(c68769900.spcon)
	e1:SetTarget(c68769900.sptg)
	e1:SetOperation(c68769900.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡·怪兽区域送去墓地的场合，以「海造贼-红胡子航海士」以外的自己场上1只「海造贼」怪兽为对象才能发动。这张卡当作装备卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68769900,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,68769901)
	e2:SetCondition(c68769900.eqcon)
	e2:SetTarget(c68769900.eqtg)
	e2:SetOperation(c68769900.eqop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件函数（对方回合）
function c68769900.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方玩家
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤对方场上或墓地中，其属性在额外卡组有可特殊召唤的「海造贼」怪兽相对应的怪兽
function c68769900.cfilter(c,e,tp)
	-- 检查该怪兽是否表侧表示存在于场上或存在于墓地，且额外卡组中存在相同属性、可特殊召唤的「海造贼」怪兽
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and Duel.IsExistingMatchingCard(c68769900.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetAttribute())
end
-- 过滤额外卡组中满足特定属性且可以特殊召唤的「海造贼」怪兽
function c68769900.spfilter(c,e,tp,attr)
	-- 检查卡片是否为「海造贼」怪兽、属性是否与指定属性相同、是否能特殊召唤，且额外怪兽区域有空位
	return c:IsSetCard(0x13f) and c:IsAttribute(attr) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果①的发动准备（Target）函数
function c68769900.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔陷区是否有空位（用于将自身作为装备卡装备）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 且对方场上或墓地存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c68769900.cfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil,e,tp) end
	-- 设置连锁处理信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置连锁处理信息：将自身作为装备卡装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 过滤对方场上表侧表示或墓地存在的怪兽（用于在效果处理时获取所有可用的属性）
function c68769900.cfilter2(c)
	return c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)
end
-- 效果①的效果处理（Operation）函数
function c68769900.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上表侧表示及墓地的所有怪兽
	local g=Duel.GetMatchingGroup(c68769900.cfilter2,tp,0,LOCATION_MZONE+LOCATION_GRAVE,nil)
	local tc=g:GetFirst()
	local attr=0
	while tc do
		attr=attr|tc:GetAttribute()
		tc=g:GetNext()
	end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只与对方场上·墓地怪兽相同属性的「海造贼」怪兽
	local sg=Duel.SelectMatchingCard(tp,c68769900.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,attr)
	local sc=sg:GetFirst()
	-- 成功特殊召唤该怪兽，且该怪兽表侧表示存在，且自身卡片仍存在于场上并由自己控制时
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)~=0 and sc:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) then
		if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
		-- 将自身作为装备卡装备给特殊召唤的怪兽，若装备失败则结束处理
		if not Duel.Equip(tp,c,sc,false) then return end
		-- 自己场上的这张卡当作装备卡使用给那只怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabelObject(sc)
		e1:SetValue(c68769900.eqlimit)
		c:RegisterEffect(e1)
	end
end
-- 装备限制函数，限制该卡只能装备给指定的怪兽
function c68769900.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 效果②的发动条件函数（从手卡·怪兽区域送去墓地的场合）
function c68769900.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_MZONE)
end
-- 过滤自己场上表侧表示的「海造贼-红胡子航海士」以外的「海造贼」怪兽
function c68769900.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13f) and not c:IsCode(68769900)
end
-- 效果②的发动准备（Target）函数
function c68769900.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c68769900.eqfilter(chkc) end
	-- 检查自身是否仍存在于墓地，且自己魔陷区是否有空位
	if chk==0 then return c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 且自己场上存在可以作为装备对象的其他「海造贼」怪兽
		and Duel.IsExistingTarget(c68769900.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只「海造贼」怪兽作为效果的对象
	Duel.SelectTarget(tp,c68769900.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁处理信息：将自身作为装备卡装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
	-- 设置连锁处理信息：自身从墓地离开（装备到场上）
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- 效果②的效果处理（Operation）函数
function c68769900.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and c:IsRelateToEffect(e) then
		-- 将自身作为装备卡装备给对象怪兽，若装备失败则结束处理
		if not Duel.Equip(tp,c,tc) then return end
		-- 这张卡当作装备卡使用给那只怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabelObject(tc)
		e1:SetValue(c68769900.eqlimit)
		c:RegisterEffect(e1)
	end
end
