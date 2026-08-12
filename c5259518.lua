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
c5259518.mentioned_counter={
	[0x1041]=true,
}
-- 过滤条件：表侧表示且放置有捕食指示物（0x1041）的卡
function c5259518.cfilter(c)
	return c:IsFaceup() and c:GetCounter(0x1041)>0
end
-- 发动条件：对方场上存在放置有捕食指示物的怪兽
function c5259518.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方主要怪兽区是否存在至少1只表侧表示且放置有捕食指示物的怪兽
	return Duel.IsExistingMatchingCard(c5259518.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 效果发动的检测：自己主要怪兽区有空位且这张卡可以从手卡特殊召唤
function c5259518.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己主要怪兽区是否有可用空格且这张卡满足特殊召唤条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次连锁将把这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与效果关联，则将其从手卡特殊召唤
function c5259518.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 发动条件：这张卡被对方（战斗或对方的效果）破坏且原本由自己控制
function c5259518.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or rp==1-tp) and c:IsPreviousControler(tp)
end
-- 过滤条件：自己墓地中「捕食植物 卷瓶子草喙嘴龙」以外的龙族·植物族暗属性且可以特殊召唤的怪兽
function c5259518.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON+RACE_PLANT) and c:IsAttribute(ATTRIBUTE_DARK) and not c:IsCode(5259518) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的检测：自己主要怪兽区有空位且墓地存在可作为对象的符合条件怪兽
function c5259518.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c5259518.spfilter(chkc,e,tp) end
	-- 检测自己主要怪兽区是否有可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己墓地存在至少1只可作为效果对象的符合条件怪兽
		and Duel.IsExistingTarget(c5259518.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 以自己墓地1只符合条件的怪兽为对象
	local g=Duel.SelectTarget(tp,c5259518.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次连锁将把作为对象的1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：若作为对象的怪兽仍与效果关联，则将其特殊召唤
function c5259518.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
