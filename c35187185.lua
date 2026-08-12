--夢魔鏡の天魔－ネイロス
-- 效果：
-- 属性不同的「梦魔镜」怪兽×2
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要这张卡在怪兽区域存在，这张卡的属性也当作「暗」使用。
-- ②：这张卡以外的自己场上的怪兽被解放的场合，以场上1张卡为对象才能发动。那张卡破坏。
-- ③：这张卡被对方破坏的场合才能发动。从自己墓地选「梦魔镜的天魔-涅伊洛斯」以外的1只「梦魔镜」怪兽特殊召唤。
function c35187185.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用2个满足条件的「梦魔镜」怪兽作为融合素材
	aux.AddFusionProcFunRep(c,c35187185.ffilter,2,true)
	-- 只要这张卡在怪兽区域存在，这张卡的属性也当作「暗」使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e1)
	-- 这张卡以外的自己场上的怪兽被解放的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35187185,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,35187185)
	e2:SetCondition(c35187185.descon)
	e2:SetTarget(c35187185.destg)
	e2:SetOperation(c35187185.desop)
	c:RegisterEffect(e2)
	-- 这张卡被对方破坏的场合才能发动。从自己墓地选「梦魔镜的天魔-涅伊洛斯」以外的1只「梦魔镜」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35187185,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,35187186)
	e3:SetCondition(c35187185.spcon)
	e3:SetTarget(c35187185.sptg)
	e3:SetOperation(c35187185.spop)
	c:RegisterEffect(e3)
end
-- 融合召唤时用于筛选融合素材的过滤函数，确保属性不同
function c35187185.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x131) and (not sg or not sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute()))
end
-- 用于判断解放的怪兽是否在自己场上
function c35187185.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 判断是否有自己场上的怪兽被解放
function c35187185.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c35187185.cfilter,1,e:GetHandler(),tp)
end
-- 选择破坏对象，确保场上存在可破坏的卡
function c35187185.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查是否有场上存在的卡可以作为破坏对象
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏操作，将目标卡破坏
function c35187185.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的破坏对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 用于筛选可特殊召唤的「梦魔镜」怪兽
function c35187185.spfilter(c,e,tp)
	return c:IsSetCard(0x131) and not c:IsCode(35187185) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断该卡是否被对方破坏且为己方控制
function c35187185.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousControler(tp) and rp==1-tp
end
-- 设置特殊召唤的条件，检查是否有足够的召唤位置和满足条件的墓地怪兽
function c35187185.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方墓地是否存在满足条件的「梦魔镜」怪兽
		and Duel.IsExistingMatchingCard(c35187185.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 执行特殊召唤操作，从墓地特殊召唤符合条件的怪兽
function c35187185.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地选择满足条件的怪兽作为特殊召唤对象
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c35187185.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以特殊召唤方式召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
