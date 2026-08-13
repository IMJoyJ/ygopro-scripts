--磁石の戦士Σ＋
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：只要自己场上有地属性怪兽存在，可以攻击的对方怪兽必须向地属性怪兽作出攻击。
-- ②：只要对方场上有地属性怪兽存在，对方选择自身怪兽的攻击对象之际，那个攻击对象由自己选择。
-- ③：这张卡被送去墓地的场合，以除「磁石战士Σ+」外的自己墓地1只4星以下的「磁石战士」怪兽为对象才能发动。那只怪兽加入手卡或特殊召唤。
local s,id,o=GetID()
-- 此函数为这张卡注册全部效果：①通过场地永续效果让可以攻击的对方怪兽必须攻击（EFFECT_MUST_ATTACK），并通过另一个效果强制攻击对象为地属性怪兽（EFFECT_MUST_ATTACK_MONSTER）；②通过黑暗贵族效果在对方场上有地属性怪兽时由自己选择对方怪兽的攻击对象（EFFECT_PATRICIAN_OF_DARKNESS）；③设置墓地诱发效果，从自己墓地选1只4星以下「磁石战士」怪兽加入手卡或特殊召唤。
function s.initial_effect(c)
	-- 对应①“只要自己场上有地属性怪兽存在，可以攻击的对方怪兽必须向地属性怪兽作出攻击。”中的“可以攻击的对方怪兽必须攻击”部分：以场地永续效果强制对方怪兽进入必须攻击状态。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_MUST_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(s.atkcon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e2:SetValue(s.atklimit)
	c:RegisterEffect(e2)
	-- 对应②“只要对方场上有地属性怪兽存在，对方选择自身怪兽的攻击对象之际，那个攻击对象由自己选择。”：以黑暗贵族效果夺取对方攻击对象的选择权。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_PATRICIAN_OF_DARKNESS)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCondition(s.podcond)
	e3:SetTargetRange(0,1)
	c:RegisterEffect(e3)
	-- 对应③“这张卡被送去墓地的场合，以除「磁石战士Σ+」外的自己墓地1只4星以下的「磁石战士」怪兽为对象才能发动。那只怪兽加入手卡或特殊召唤。”：注册该诱发选发效果，含有取对象、特殊召唤/回手牌属性，并设置同名卡1回合1次。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"回收效果"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_GRAVE_SPSUMMON+CATEGORY_GRAVE_ACTION)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 定义过滤器：判断怪兽是否为表侧表示的地属性怪兽，用于检测场上是否存在地属性怪兽。
function s.atkfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsFaceup()
end
-- ①效果的发动条件：自己场上存在至少1只表侧表示的地属性怪兽。
function s.atkcon(e)
	-- 以本卡控制者为基准，检查其场上主要怪兽区是否存在至少1只表侧表示的地属性怪兽。
	return Duel.IsExistingMatchingCard(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- EFFECT_MUST_ATTACK_MONSTER 的 Value 函数：判定某只怪兽是否是被强制攻击的对象，即表侧表示的地属性怪兽，从而让对方怪兽必须向这种怪兽攻击。
function s.atklimit(e,c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsFaceup()
end
-- 定义过滤器：用于判断某只怪兽是否为表侧表示的地属性怪兽，供②效果的条件使用。
function s.podfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsFaceup()
end
-- ②效果的发动条件：以本卡控制者为基准，对方场上存在至少1只表侧表示的地属性怪兽。
function s.podcond(e)
	local tp=e:GetOwnerPlayer()
	-- 以本卡控制者为基准，检查对方场上主要怪兽区是否存在至少1只表侧表示的地属性怪兽。
	return Duel.IsExistingMatchingCard(s.podfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- ③效果的对象筛选条件：自己墓地中，卡名不是「磁石战士Σ+」、4星以下且属于「磁石战士」字段的怪兽，并且该怪兽能够加入手卡或能够被特殊召唤。
function s.filter(c,e,tp)
	return not c:IsCode(id) and c:IsLevelBelow(4) and c:IsSetCard(0x2066)
		-- 进一步限定：目标怪兽可以被加入手卡，或者自己场上有可用的主要怪兽区且该怪兽可以特殊召唤（满足召唤条件和苏生限制）。
		and (c:IsAbleToHand() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- ③效果的 Target 函数：在发动时检测自己墓地是否存在符合条件的对象；若存在则让玩家选择1张作为效果对象，并登记为取对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 发动判定：若自己墓地存在至少1张满足条件的卡片，则③效果可以发动。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向当前玩家显示“请选择效果的对象”的选择提示，用于选择墓地对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己墓地选择1张满足条件的「磁石战士」怪兽作为效果对象，并自动将其设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
end
-- ③效果处理：取得对象卡，确认其仍与效果关联后，先进行王家长眠之谷的适用检查；若不受影响，则根据玩家选择或条件，将对象特殊召唤或加入手卡。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得③效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 若对象卡受到王家长眠之谷的影响且当前连锁可被无效，则本次效果直接无效并终止处理。
		if aux.NecroValleyNegateCheck(tc) then return end
		-- 若对象卡受到王家长眠之谷的影响（即使连锁未被无效），也不能进行后续移动；此判断用于确保对象不受王谷限制。
		if not aux.NecroValleyFilter()(tc) then return end
		-- 判断自己场上是否有可用的主要怪兽区，并且对象卡能够被特殊召唤（满足苏生限制和召唤条件），以决定是否可以选择特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 当对象卡不能被加入手卡时只能特殊召唤；若能加入手卡，则让玩家在“加入手卡(1190)”与“特殊召唤(1152)”之间选择，选择特殊召唤（返回1）时才执行特召。
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将选择的对象卡以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		elseif tc:IsAbleToHand() then
			-- 将选择的对象卡加入其持有者的手卡（效果处理）。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
