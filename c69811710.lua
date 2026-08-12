--宵星の騎士ギルス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「自奏圣乐」卡或「星遗物」卡送去墓地。和这张卡相同纵列有其他卡2张以上存在的场合，再在这个回合把这张卡当作调整使用。
-- ②：自己场上没有其他怪兽存在的场合才能发动。在双方场上把「星遗物衍生物」（机械族·暗·1星·攻/守0）各1只守备表示特殊召唤。
function c69811710.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「自奏圣乐」卡或「星遗物」卡送去墓地。和这张卡相同纵列有其他卡2张以上存在的场合，再在这个回合把这张卡当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69811710,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,69811710)
	e1:SetTarget(c69811710.tgtg)
	e1:SetOperation(c69811710.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己场上没有其他怪兽存在的场合才能发动。在双方场上把「星遗物衍生物」（机械族·暗·1星·攻/守0）各1只守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(69811710,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,69811711)
	e3:SetCondition(c69811710.spcon)
	e3:SetTarget(c69811710.sptg)
	e3:SetOperation(c69811710.spop)
	c:RegisterEffect(e3)
end
c69811710.treat_itself_tuner=true
-- 过滤条件：卡组中属于「自奏圣乐」或「星遗物」字段且能送去墓地的卡
function c69811710.tgfilter(c)
	return c:IsSetCard(0x11b,0xfe) and c:IsAbleToGrave()
end
-- ①号效果的发动准备（Target）
function c69811710.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「自奏圣乐」或「星遗物」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c69811710.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的处理（Operation）
function c69811710.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足条件的「自奏圣乐」或「星遗物」卡
	local g=Duel.SelectMatchingCard(tp,c69811710.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 若成功将选择的卡因效果送去墓地且该卡确实到达墓地
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		if c:GetColumnGroup():GetCount()>=2 and c:IsFaceup() and c:IsRelateToEffect(e) then
			-- 中断效果处理，使后续的当作调整处理不与送墓同时进行
			Duel.BreakEffect()
			-- 再在这个回合把这张卡当作调整使用
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_ADD_TYPE)
			e1:SetValue(TYPE_TUNER)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end
-- ②号效果的发动条件
function c69811710.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上除这张卡以外是否没有其他怪兽存在
	return Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_MZONE,0,e:GetHandler())==0
end
-- ②号效果的发动准备（Target）
function c69811710.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上怪兽区域的空位数
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取对方场上怪兽区域的空位数
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)
	if chk==0 then return ft1>0 and ft2>0
		-- 检查自己是否能将「星遗物衍生物」在自己场上守备表示特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,46647145,0xfe,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,tp)
		-- 检查自己是否能将「星遗物衍生物」在对方场上守备表示特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,46647145,0xfe,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,1-tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) end
	-- 向对方玩家提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
	-- 设置操作信息：特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
end
-- ②号效果的处理（Operation）
function c69811710.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上怪兽区域的空位数
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取对方场上怪兽区域的空位数
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft1<=0 or ft2<=0 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 若自己能将「星遗物衍生物」在自己场上守备表示特殊召唤
	if Duel.IsPlayerCanSpecialSummonMonster(tp,46647145,0xfe,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,tp)
		-- 且自己能将「星遗物衍生物」在对方场上守备表示特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,46647145,0xfe,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,1-tp) then
		-- 创建用于在自己场上特殊召唤的「星遗物衍生物」
		local token=Duel.CreateToken(tp,69811711)
		-- 将衍生物特殊召唤到自己场上（分步处理）
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 创建用于在对方场上特殊召唤的「星遗物衍生物」
		local token=Duel.CreateToken(tp,69811711)
		-- 将衍生物特殊召唤到对方场上（分步处理）
		Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
		-- 完成双方场上衍生物的特殊召唤
		Duel.SpecialSummonComplete()
	end
end
