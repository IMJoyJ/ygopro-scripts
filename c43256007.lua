--氷結界の随身
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡解放才能发动。从手卡把1只5星以上的「冰结界」怪兽特殊召唤。
-- ②：这个回合没有送去墓地的这张卡在墓地存在的场合，以自己场上1只3星以上的水属性怪兽为对象才能发动。那只怪兽的等级下降2星，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c43256007.initial_effect(c)
	-- ①：把这张卡解放才能发动。从手卡把1只5星以上的「冰结界」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43256007,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,43256007)
	e1:SetCost(c43256007.spcost1)
	e1:SetTarget(c43256007.sptg1)
	e1:SetOperation(c43256007.spop1)
	c:RegisterEffect(e1)
	-- ②：这个回合没有送去墓地的这张卡在墓地存在的场合，以自己场上1只3星以上的水属性怪兽为对象才能发动。那只怪兽的等级下降2星，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43256007,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 检查此卡是否在墓地且本回合未被送去墓地，满足条件时才能发动效果②。
	e2:SetCondition(aux.exccon)
	e2:SetCountLimit(1,43256008)
	e2:SetTarget(c43256007.sptg2)
	e2:SetOperation(c43256007.spop2)
	c:RegisterEffect(e2)
end
-- 效果①的发动费用：解放此卡。
function c43256007.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡从场上解放作为效果①的发动费用。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数：筛选手卡中满足「冰结界」卡族、怪兽类型、等级5以上且可特殊召唤的怪兽。
function c43256007.spfilter1(c,e,tp)
	return c:IsSetCard(0x2f) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动条件：确认场上是否有足够的召唤位置，并且手卡中是否存在满足条件的怪兽。
function c43256007.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡中是否存在满足条件的怪兽。
		and Duel.IsExistingMatchingCard(c43256007.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理信息：准备特殊召唤1只手卡中的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的处理：确认场上召唤位置后，选择并特殊召唤1只符合条件的手卡怪兽。
function c43256007.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤位置。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c43256007.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：筛选场上正面表示、等级3以上且为水属性的怪兽。
function c43256007.spfilter2(c)
	return c:IsFaceup() and c:IsLevelAbove(3) and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果②的发动条件：确认场上是否存在满足条件的怪兽，并且此卡可特殊召唤。
function c43256007.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c43256007.spfilter2(chkc) end
	local c=e:GetHandler()
	-- 检查场上是否存在满足条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c43256007.spfilter2,tp,LOCATION_MZONE,0,1,nil)
		-- 检查场上是否有足够的召唤位置且此卡可特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要降低等级的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只满足条件的怪兽作为对象。
	Duel.SelectTarget(tp,c43256007.spfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁处理信息：准备特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的处理：选择目标怪兽并降低其等级，然后将此卡特殊召唤到场上。
function c43256007.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or tc:GetLevel()<3 then return end
	local c=e:GetHandler()
	-- 给目标怪兽添加一个等级减少2的永续效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(-2)
	tc:RegisterEffect(e1)
	-- 判断目标怪兽未免疫该效果、此卡可特殊召唤且特殊召唤成功后执行后续处理。
	if not tc:IsImmuneToEffect(e1) and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 将此卡从场上离开时重新指定去向为除外。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2,true)
	end
end
