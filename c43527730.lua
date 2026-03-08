--御巫の水舞踏
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：装备怪兽不会被效果破坏。
-- ②：自己主要阶段才能发动。原本卡名和装备怪兽不同的1只「御巫」怪兽从手卡·卡组特殊召唤，这张卡给那只怪兽装备。那之后，这张卡装备过的怪兽回到手卡。
function c43527730.initial_effect(c)
	-- ①：装备怪兽不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c43527730.target)
	e1:SetOperation(c43527730.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。原本卡名和装备怪兽不同的1只「御巫」怪兽从手卡·卡组特殊召唤，这张卡给那只怪兽装备。那之后，这张卡装备过的怪兽回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ①：装备怪兽不会被效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,43527730)
	e4:SetTarget(c43527730.sptg)
	e4:SetOperation(c43527730.spop)
	c:RegisterEffect(e4)
end
-- 选择装备对象怪兽
function c43527730.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查是否满足装备条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示选择装备对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备对象怪兽
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡效果处理
function c43527730.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 特殊召唤怪兽的过滤条件
function c43527730.spfilter(c,e,tp,code)
	return c:IsSetCard(0x18d) and not c:IsOriginalCodeRule(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果处理前的判定
function c43527730.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	-- 检查是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否有满足条件的「御巫」怪兽
		and Duel.IsExistingMatchingCard(c43527730.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,ec:GetOriginalCodeRule()) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	-- 设置装备怪兽回手的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,ec,1,0,0)
end
-- 特殊召唤并装备怪兽的效果处理
function c43527730.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=e:GetHandler():GetEquipTarget()
	-- 检查是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择要特殊召唤的「御巫」怪兽
	local g=Duel.SelectMatchingCard(tp,c43527730.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,ec:GetOriginalCodeRule())
	local tc=g:GetFirst()
	-- 关闭装备卡的自爆检查
	Duel.DisableSelfDestroyCheck()
	-- 执行特殊召唤和装备操作
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.Equip(tp,c,tc) then
		-- 设置装备对象限制效果
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c43527730.eqlimit)
		c:RegisterEffect(e1)
		if ec then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将装备怪兽送回手卡
			Duel.SendtoHand(ec,nil,REASON_EFFECT)
		end
	end
	-- 重新开启装备卡的自爆检查
	Duel.DisableSelfDestroyCheck(false)
end
-- 装备对象限制效果的判断函数
function c43527730.eqlimit(e,c)
	return e:GetOwner()==c
end
