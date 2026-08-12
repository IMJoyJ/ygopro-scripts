--レッドポータン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「波波」怪兽为对象才能发动。那只怪兽直到下个回合的结束时当作调整使用。
-- ②：这张卡已在怪兽区域存在的状态，自己或者对方同调召唤成功的场合才能发动。从手卡·卡组把1只「波波」怪兽特殊召唤。
function c16001119.initial_effect(c)
	-- ①：以自己场上1只「波波」怪兽为对象才能发动。那只怪兽直到下个回合的结束时当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,16001119)
	e1:SetTarget(c16001119.chtg)
	e1:SetOperation(c16001119.chop)
	c:RegisterEffect(e1)
	-- ②：这张卡已在怪兽区域存在的状态，自己或者对方同调召唤成功的场合才能发动。从手卡·卡组把1只「波波」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,16001120)
	e2:SetCondition(c16001119.spcon)
	e2:SetTarget(c16001119.sptg)
	e2:SetOperation(c16001119.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否为正面表示的「波波」怪兽且不是调整
function c16001119.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x147) and not c:IsType(TYPE_TUNER)
end
-- 设置效果的对象为己方场上的「波波」怪兽
function c16001119.chtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c16001119.filter(chkc) end
	-- 检查己方场上是否存在满足条件的「波波」怪兽
	if chk==0 then return Duel.IsExistingTarget(c16001119.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的「波波」怪兽作为效果对象
	Duel.SelectTarget(tp,c16001119.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数，将选中的怪兽变为调整
function c16001119.chop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 创建一个使对象怪兽变为调整类型的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(TYPE_TUNER)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
	tc:RegisterEffect(e1)
end
-- 过滤函数，用于判断是否为同调召唤的怪兽
function c16001119.confil(c,tp)
	return (c:IsSummonPlayer(tp) or c:IsSummonPlayer(1-tp)) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤函数，用于判断是否为「波波」怪兽且可特殊召唤
function c16001119.spfilter(c,e,tp)
	return c:IsSetCard(0x147) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否为己方或对方的同调召唤成功且不包含自身
function c16001119.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c16001119.confil,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 设置特殊召唤的条件，检查是否有满足条件的「波波」怪兽
function c16001119.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或卡组中是否存在满足条件的「波波」怪兽
		and Duel.IsExistingMatchingCard(c16001119.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将特殊召唤1只「波波」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤效果的处理函数，从手牌或卡组选择并特殊召唤1只「波波」怪兽
function c16001119.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或卡组中选择1只满足条件的「波波」怪兽
	local g=Duel.SelectMatchingCard(tp,c16001119.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽特殊召唤到己方场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
