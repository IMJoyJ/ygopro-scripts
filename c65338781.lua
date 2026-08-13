--熟練の赤魔術士
-- 效果：
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。
-- ②：把有3个魔力指示物放置的这张卡解放才能发动。从自己的手卡·卡组·墓地选1只「恶魔」怪兽特殊召唤。
-- ③：自己主要阶段把墓地的这张卡除外，以自己场上1张可以放置魔力指示物的卡为对象才能发动。给那张卡放置1个魔力指示物。
function c65338781.initial_effect(c)
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,3)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	-- 注册辅助用永续效果：在魔法卡发动的连锁发生时，记录这张卡当时在怪兽区域存在（不入连锁、不会被无效）。
	e1:SetOperation(aux.chainreg)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c65338781.acop)
	c:RegisterEffect(e2)
	-- ②：把有3个魔力指示物放置的这张卡解放才能发动。从自己的手卡·卡组·墓地选1只「恶魔」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(65338781,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c65338781.spcost)
	e3:SetTarget(c65338781.sptg)
	e3:SetOperation(c65338781.spop)
	c:RegisterEffect(e3)
	-- ③：自己主要阶段把墓地的这张卡除外，以自己场上1张可以放置魔力指示物的卡为对象才能发动。给那张卡放置1个魔力指示物。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(65338781,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设定发动代价：把墓地的这张卡除外。
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c65338781.cttg)
	e4:SetOperation(c65338781.ctop)
	c:RegisterEffect(e4)
end
c65338781.mentioned_counter={
	[0x1]=true,
}
-- 连锁处理结束时检查：若刚处理的是魔法卡的发动（EFFECT_TYPE_ACTIVATE的魔法卡效果），且这张卡在该连锁发生时已在场上存在，则给这张卡放置1个魔力指示物。
function c65338781.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 代价处理：发动条件检查要求这张卡放置有3个魔力指示物且可以解放，满足时将这张卡解放作为发动代价。
function c65338781.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetCounter(0x1)==3 and e:GetHandler():IsReleasable() end
	-- 把这张卡解放，作为效果的发动代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数：选出「恶魔」系列的、可以被特殊召唤的怪兽。
function c65338781.filter(c,e,tp)
	return c:IsSetCard(0x45) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标函数：检查自己主要怪兽区域有可用格子，且自己的手卡·卡组·墓地存在至少1只可以特殊召唤的「恶魔」怪兽。
function c65338781.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否有可用的怪兽空格（解放这张卡后至少空出1格）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 并检查自己的手卡·卡组·墓地是否存在至少1只满足过滤条件的「恶魔」怪兽。
		and Duel.IsExistingMatchingCard(c65338781.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：预告将从手卡·卡组·墓地特殊召唤1只怪兽（供星尘龙、王家长眠之谷等效果检测）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：自己主要怪兽区域没有空格则中断；否则提示选择，从自己的手卡·卡组·墓地选1只「恶魔」怪兽（不受王家长眠之谷影响的），以表侧表示特殊召唤到自己场上。
function c65338781.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若自己主要怪兽区域没有可用空格，则不进行特殊召唤直接结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡·卡组·墓地选1只满足过滤条件且不受王家长眠之谷影响的「恶魔」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c65338781.filter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选出的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：选出表侧表示的、可以放置魔力指示物的卡。
function c65338781.ctfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x1,1)
end
-- 目标函数：检查并选择自己场上1张表侧表示且可以放置魔力指示物的卡作为效果对象，并设置放置魔力指示物的操作信息。
function c65338781.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c65338781.ctfilter(chkc) end
	-- 检查自己场上是否存在至少1张可以取为对象、可以放置魔力指示物的表侧表示的卡。
	if chk==0 then return Duel.IsExistingTarget(c65338781.ctfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 向玩家发送选择提示：请选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择自己场上1张满足过滤条件的卡，并将其设为当前效果的对象。
	Duel.SelectTarget(tp,c65338781.ctfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置操作信息：预告将给卡放置1个魔力指示物。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- 效果处理：取得当前效果的对象卡，若该卡表侧表示且仍与本效果关联，则给那张卡放置1个魔力指示物。
function c65338781.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x1,1)
	end
end
