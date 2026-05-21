--大神官デ・ザード
-- 效果：
-- 根据战斗破坏怪兽的次数得到下面的效果：
-- ●1次：只要这张卡在场上表侧表示存在，以这张卡为对象的魔法·陷阱卡的发动和效果无效并破坏。
-- ●2次：可以把这张卡做祭品，从自己的手卡·卡组选1只「不死王 巫妖」特殊召唤到场上。
function c88989706.initial_effect(c)
	-- 根据战斗破坏怪兽的次数得到下面的效果：
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetOperation(c88989706.regop)
	c:RegisterEffect(e1)
	-- ●1次：只要这张卡在场上表侧表示存在，以这张卡为对象的魔法·陷阱卡的发动和效果无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_F)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCondition(c88989706.discon)
	e2:SetTarget(c88989706.distg)
	e2:SetOperation(c88989706.disop)
	c:RegisterEffect(e2)
	-- ●2次：可以把这张卡做祭品，从自己的手卡·卡组选1只「不死王 巫妖」特殊召唤到场上。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(88989706,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c88989706.spcon)
	e3:SetCost(c88989706.spcost)
	e3:SetTarget(c88989706.sptg)
	e3:SetOperation(c88989706.spop)
	c:RegisterEffect(e3)
end
-- 战斗破坏怪兽时，为自身注册一个用于计数战斗破坏次数的Flag效果。
function c88989706.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToBattle() then
		c:RegisterFlagEffect(88989707,RESET_EVENT+RESETS_STANDARD,0,0)
	end
end
-- 检查自身是否拥有至少1个战斗破坏计数，且当前连锁的效果是取对象且对象包含自身，且该效果为魔法·陷阱卡的发动。
function c88989706.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(88989707)==0 then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前处理的连锁的效果的对象卡片组。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not tg or not tg:IsContains(e:GetHandler()) then return false end
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 无效并破坏效果的靶子（Target）函数，设置无效和破坏的操作信息。
function c88989706.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为使该魔法·陷阱卡的发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置当前连锁的操作信息为破坏该魔法·陷阱卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 无效并破坏效果的执行（Operation）函数，使该魔法·陷阱卡的发动无效并将其破坏。
function c88989706.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁是否为紧接在目标效果发动后的下一个连锁，若不是则不处理。
	if Duel.GetCurrentChain()~=ev+1 then return end
	-- 如果成功使目标效果的发动无效，且该卡在场上（或与效果关联），则继续执行。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 因效果将目标卡片破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 检查自身是否拥有至少2个战斗破坏计数。
function c88989706.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(88989707)>=2
end
-- 特殊召唤效果的消耗（Cost）函数，检查自身是否可以被解放，并将其解放。
function c88989706.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身作为发动成本（Cost）解放。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤卡组或手卡中卡名为「不死王 巫妖」且可以无视召唤条件特殊召唤的卡。
function c88989706.filter(c,e,tp)
	return c:IsCode(39711336) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 特殊召唤效果的靶子（Target）函数，检查自身解放后是否有可用的怪兽区域，并确认手卡或卡组中是否存在满足条件的「不死王 巫妖」。
function c88989706.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查自己场上的怪兽区域是否有空位（因为自身会被解放，所以可用区域数大于-1即可）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 并检查自己的手卡或卡组中是否存在至少1张满足特殊召唤条件的「不死王 巫妖」。
		and Duel.IsExistingMatchingCard(c88989706.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为从手卡或卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 特殊召唤效果的执行（Operation）函数，从手卡或卡组选择1只「不死王 巫妖」特殊召唤，并完成正规召唤程序。
function c88989706.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择特殊召唤卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡或卡组中选择1张满足特殊召唤条件的「不死王 巫妖」。
	local g=Duel.SelectMatchingCard(tp,c88989706.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	-- 如果选出了卡，则将其以表侧表示、无视召唤条件特殊召唤到自己场上。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)>0 then
		g:GetFirst():CompleteProcedure()
	end
end
