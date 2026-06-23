--捕食植物ヘリアンフォリンクス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方场上的怪兽有捕食指示物放置中的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡被对方破坏的场合，以「捕食植物 卷瓶子草喙嘴龙」以外的自己墓地1只龙族·植物族的暗属性怪兽为对象才能发动。那只怪兽特殊召唤。
function c5259518.initial_effect(c)
	-- ①：对方场上的怪兽有捕食指示物放置中的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,5259518)
	e1:SetCondition(c5259518.spcon1)
	e1:SetTarget(c5259518.sptg1)
	e1:SetOperation(c5259518.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏的场合，以「捕食植物 卷瓶子草喙嘴龙」以外的自己墓地1只龙族·植物族的暗属性怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,5259519)
	e2:SetCondition(c5259518.spcon2)
	e2:SetTarget(c5259518.sptg2)
	e2:SetOperation(c5259518.spop2)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查场上是否存在具有捕食指示物的怪兽
function c5259518.cfilter(c)
	return c:IsFaceup() and c:GetCounter(0x1041)>0
end
-- 效果条件函数，判断对方场上有无捕食指示物放置中的怪兽
function c5259518.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的卡片组
	return Duel.IsExistingMatchingCard(c5259518.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 效果处理时的判定函数，判断是否可以将此卡特殊召唤
function c5259518.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，确定本次效果将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，执行将此卡特殊召唤的操作
function c5259518.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以正面表示的形式特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果条件函数，判断此卡是否因战斗或被对方控制而破坏
function c5259518.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or rp==1-tp) and c:IsPreviousControler(tp)
end
-- 过滤函数，检查墓地是否存在符合条件的龙族·植物族暗属性怪兽
function c5259518.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON+RACE_PLANT) and c:IsAttribute(ATTRIBUTE_DARK) and not c:IsCode(5259518) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时的判定函数，判断是否可以将目标怪兽特殊召唤
function c5259518.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c5259518.spfilter(chkc,e,tp) end
	-- 判断场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检索满足条件的目标卡片组
		and Duel.IsExistingTarget(c5259518.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c5259518.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，确定本次效果将特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，执行将目标怪兽特殊召唤的操作
function c5259518.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示的形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
