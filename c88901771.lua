--熟練の青魔道士
-- 效果：
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。
-- ②：把有3个魔力指示物放置的这张卡解放才能发动。从自己的手卡·卡组·墓地选1只「暗黑骑士 盖亚」怪兽特殊召唤。
-- ③：自己主要阶段把墓地的这张卡除外，以自己场上1张可以放置魔力指示物的卡为对象才能发动。给那张卡放置1个魔力指示物。
function c88901771.initial_effect(c)
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,3)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 设置效果处理为：在连锁发生时，记录这张卡在场上存在
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c88901771.acop)
	c:RegisterEffect(e1)
	-- ②：把有3个魔力指示物放置的这张卡解放才能发动。从自己的手卡·卡组·墓地选1只「暗黑骑士 盖亚」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88901771,0))  --"放置1个魔力指示物"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c88901771.spcost)
	e2:SetTarget(c88901771.sptg)
	e2:SetOperation(c88901771.spop)
	c:RegisterEffect(e2)
	-- ③：自己主要阶段把墓地的这张卡除外，以自己场上1张可以放置魔力指示物的卡为对象才能发动。给那张卡放置1个魔力指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(88901771,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置发动代价为：把墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c88901771.cttg)
	e3:SetOperation(c88901771.ctop)
	c:RegisterEffect(e3)
end
-- 连锁处理结束时，若有魔法卡发动且这张卡在场，则给这张卡放置1个魔力指示物
function c88901771.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 检查并执行发动代价：这张卡有3个魔力指示物放置，并将这张卡解放
function c88901771.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetCounter(0x1)==3 and e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：属于「暗黑骑士 盖亚」系列且可以特殊召唤的怪兽
function c88901771.filter(c,e,tp)
	return c:IsSetCard(0xbd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与合法性检查（检查怪兽区域空位及手卡·卡组·墓地是否存在可特召的「暗黑骑士 盖亚」怪兽）
function c88901771.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位（由于自身作为代价被解放，空位数量需大于-1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查自己的手卡、卡组、墓地是否存在至少1只满足特召条件的「暗黑骑士 盖亚」怪兽
		and Duel.IsExistingMatchingCard(c88901771.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理信息：从手卡、卡组、墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果②的效果处理：从手卡·卡组·墓地选1只「暗黑骑士 盖亚」怪兽特殊召唤
function c88901771.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否还有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选出1只不受王家长眠之谷影响的、手卡·卡组·墓地的「暗黑骑士 盖亚」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c88901771.filter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：场上表侧表示且可以放置魔力指示物的卡
function c88901771.ctfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x1,1)
end
-- 效果③的发动准备与目标选择（选择场上1张可以放置魔力指示物的卡为对象）
function c88901771.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c88901771.ctfilter(chkc) end
	-- 检查场上是否存在至少1个可以放置魔力指示物的合法对象
	if chk==0 then return Duel.IsExistingTarget(c88901771.ctfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要放置魔力指示物的卡
	Duel.Hint(HINT_SELECTMSG,tp,94)
	-- 选择场上1张可以放置魔力指示物的卡作为效果对象
	Duel.SelectTarget(tp,c88901771.ctfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置效果处理信息：给卡片放置1个魔力指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- 效果③的效果处理：给作为对象的卡放置1个魔力指示物
function c88901771.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x1,1)
	end
end
