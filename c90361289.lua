--機巧狐－宇迦之御魂稲荷
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组有怪兽特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。从手卡·卡组把攻击力和守备力的数值相同而属性是和作为对象的怪兽相同的1只怪兽特殊召唤。
-- ③：每次对方对怪兽的召唤·特殊召唤成功发动。给与对方300伤害。
function c90361289.initial_effect(c)
	-- ①：从卡组有怪兽特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90361289,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,90361289)
	e1:SetCondition(c90361289.spcon1)
	e1:SetTarget(c90361289.sptg1)
	e1:SetOperation(c90361289.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。从手卡·卡组把攻击力和守备力的数值相同而属性是和作为对象的怪兽相同的1只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90361289,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,90361290)
	e2:SetTarget(c90361289.sptg2)
	e2:SetOperation(c90361289.spop2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：每次对方对怪兽的召唤·特殊召唤成功发动。给与对方300伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(90361289,2))
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c90361289.damcon)
	e4:SetTarget(c90361289.damtg)
	e4:SetOperation(c90361289.damop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
-- 过滤特殊召唤自卡组的怪兽
function c90361289.filter(c)
	return c:IsSummonLocation(LOCATION_DECK)
end
-- 检查是否有怪兽从卡组特殊召唤，作为效果①的发动条件
function c90361289.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c90361289.filter,1,nil)
end
-- 效果①的发动准备与合法性检测（检查怪兽区域是否有空位，以及自身是否能特殊召唤）
function c90361289.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息，表示将特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：将自身从手卡特殊召唤
function c90361289.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤对方场上表侧表示的怪兽，且手卡或卡组中存在与其属性相同、攻防数值相同的可特殊召唤怪兽
function c90361289.cfilter(c,e,tp)
	-- 检查怪兽是否表侧表示，且手卡或卡组中存在满足特殊召唤条件的对应属性怪兽
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c90361289.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,c:GetAttribute())
end
-- 过滤手卡或卡组中攻击力与守备力相同、属性与目标相同且能特殊召唤的怪兽
function c90361289.spfilter(c,e,tp,attr)
	-- 检查怪兽的攻击力与守备力是否相同，且属性是否与目标属性一致
	return aux.AtkEqualsDef(c) and c:IsAttribute(attr)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与目标选择（选择对方场上1只表侧表示怪兽为对象）
function c90361289.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c90361289.cfilter(chkc,e,tp) end
	-- 检查自身怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上是否存在满足条件的表侧表示怪兽作为效果对象
		and Duel.IsExistingTarget(c90361289.cfilter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择对方场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c90361289.cfilter,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置连锁处理中的操作信息，表示从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果②的处理：从手卡或卡组特殊召唤1只与对象怪兽属性相同且攻防数值相同的怪兽
function c90361289.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身怪兽区域是否有空位，若无则直接结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁中选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local attr=tc:GetAttribute()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡或卡组选择1只与对象怪兽属性相同且攻防数值相同的怪兽
		local g=Duel.SelectMatchingCard(tp,c90361289.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,attr)
		if g:GetCount()>0 then
			-- 将选择的怪兽特殊召唤到自身场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤由对方玩家召唤或特殊召唤的怪兽
function c90361289.damfilter(c,tp)
	return c:IsSummonPlayer(1-tp)
end
-- 检查是否有怪兽由对方玩家召唤或特殊召唤，作为效果③的发动条件
function c90361289.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c90361289.damfilter,1,nil,tp)
end
-- 效果③的发动准备（必发效果，直接返回true并设置伤害操作信息）
function c90361289.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理中的操作信息，表示给与对方300点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 效果③的处理：给与对方300点伤害
function c90361289.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行给与对方300点效果伤害的操作
	Duel.Damage(1-tp,300,REASON_EFFECT)
end
