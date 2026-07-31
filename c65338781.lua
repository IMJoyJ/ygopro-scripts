--熟練の赤魔術士
-- 效果：
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。
-- ②：把有3个魔力指示物放置的这张卡解放才能发动。从自己的手卡·卡组·墓地选1只「恶魔」怪兽特殊召唤。
-- ③：自己主要阶段把墓地的这张卡除外，以自己场上1张可以放置魔力指示物的卡为对象才能发动。给那张卡放置1个魔力指示物。
function c65338781.initial_effect(c)
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,3)
	-- ①：连锁登记效果：魔法卡发动时注册连锁Flag标记
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	-- 连锁注册：为连锁发动的魔法卡设置FLAG_ID_CHAINING标记
	e1:SetOperation(aux.chainreg)
	c:RegisterEffect(e1)
	-- ①：放置魔力指示物效果：每次双方发动魔法卡处理结算时，为此卡放置1个魔力指示物（上限3个）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c65338781.acop)
	c:RegisterEffect(e2)
	-- ②：解放特召效果：把放置有3个魔力指示物的此卡解放才能发动。从手卡·卡组·墓地选1只「恶魔」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(65338781,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c65338781.spcost)
	e3:SetTarget(c65338781.sptg)
	e3:SetOperation(c65338781.spop)
	c:RegisterEffect(e3)
	-- ③：墓地除外效果：自己主要阶段把墓地的这张卡除外，以自己场上1张可以放置魔力指示物的卡为对象才能发动。给那张卡放置1个魔力指示物。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(65338781,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- ③效果发动Cost：把墓地的这张卡除外
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c65338781.cttg)
	e4:SetOperation(c65338781.ctop)
	c:RegisterEffect(e4)
end
c65338781.mentioned_counter={
	[0x1]=true,
}
-- 放置魔力指示物处理：确认发动的卡为魔法卡且处于连锁标记中，为此卡添加1个魔力指示物
function c65338781.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- ②效果发动Cost：此卡有3个魔力指示物且可解放，将其解放
function c65338781.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetCounter(0x1)==3 and e:GetHandler():IsReleasable() end
	-- 解放自身作为效果发动Cost
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 特召过滤条件：「恶魔」字段怪兽且可特殊召唤
function c65338781.filter(c,e,tp)
	return c:IsSetCard(0x45) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动准备：检查怪兽区空位并确认手卡·卡组·墓地是否存在可特召的「恶魔」怪兽
function c65338781.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查解放自身后怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡、卡组、墓地是否存在可特殊召唤的「恶魔」怪兽
		and Duel.IsExistingMatchingCard(c65338781.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从手卡、卡组或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果处理：从手卡·卡组·墓地选1只「恶魔」怪兽表侧表示特殊召唤
function c65338781.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组·墓地选择1只满足条件的「恶魔」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c65338781.filter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 放置指示物过滤条件：表侧表示且可添加魔力指示物
function c65338781.ctfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x1,1)
end
-- ③效果发动准备：选择自己场上1张可放置魔力指示物的卡作为对象
function c65338781.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c65338781.ctfilter(chkc) end
	-- 发动条件检查：自己场上是否存在可放置魔力指示物的卡
	if chk==0 then return Duel.IsExistingTarget(c65338781.ctfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1张满足条件的卡作为对象
	Duel.SelectTarget(tp,c65338781.ctfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置连锁操作信息：放置1个魔力指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- ③效果处理：为目标卡放置1个魔力指示物
function c65338781.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x1,1)
	end
end
