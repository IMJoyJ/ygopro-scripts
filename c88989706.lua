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
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c88989706.spcon)
	e3:SetCost(c88989706.spcost)
	e3:SetTarget(c88989706.sptg)
	e3:SetOperation(c88989706.spop)
	c:RegisterEffect(e3)
end
-- 战破次数记录效果的Operation函数：当这张卡战斗破坏怪兽且仍与本次战斗关联时，为其累加1次标识88989707
function c88989706.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToBattle() then
		c:RegisterFlagEffect(88989707,RESET_EVENT+RESETS_STANDARD,0,0)
	end
end
-- 1次战破效果的Condition函数：检查这张卡战破次数>=1、对方连锁为取对象且对象包含这张卡的魔法·陷阱卡发动
function c88989706.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(88989707)==0 then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取正在连锁中的效果ev指定的所有对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not tg or not tg:IsContains(e:GetHandler()) then return false end
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 1次战破效果的Target函数：设置使触发连锁发动无效的操作信息，若该卡可破坏且仍与效果关联则设置破坏操作信息
function c88989706.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使触发的魔法·陷阱卡发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置将该魔法·陷阱卡破坏的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 1次战破效果的Operation函数：确认处于直接连锁位置后，使该魔法·陷阱卡发动无效并破坏
function c88989706.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁序号是否恰好为ev+1（即直接连锁应对该魔法·陷阱的发动）
	if Duel.GetCurrentChain()~=ev+1 then return end
	-- 尝试使连锁ev的发动无效，若无效成功且对象卡仍与效果关联则继续破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果破坏被无效发动的魔法·陷阱卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 2次战破效果的Condition函数：检查这张卡累计战斗破坏怪兽的次数（标识88989707数量）是否达到2次或以上
function c88989706.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(88989707)>=2
end
-- 2次战破效果的Cost函数：检查这张卡是否可解放，并在发动时将其解放作为祭品代价
function c88989706.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡作为发动代价解放
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数：筛选手卡或卡组中可无视召唤条件特殊召唤的「不死王 巫妖」(39711336)
function c88989706.filter(c,e,tp)
	return c:IsCode(39711336) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 2次战破效果的Target函数：检查己方怪兽区解放自身后有可用空位且手卡·卡组存在「不死王 巫妖」，并设置特殊召唤操作信息
function c88989706.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认考虑解放自身后己方怪兽区有可用空位（原空位数大于-1即解放后>=1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 且确认己方卡组或手卡中存在至少1只可无视召唤条件特殊召唤的「不死王 巫妖」
		and Duel.IsExistingMatchingCard(c88989706.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置从己方卡组·手卡特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 2次战破效果的Operation函数：确认有怪兽区空位后，从手卡·卡组选1只「不死王 巫妖」无视召唤条件特殊召唤并完成正规召唤手续
function c88989706.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查效果处理时己方主要怪兽区是否至少有1个可用空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向己方玩家发送选择要特殊召唤的「不死王 巫妖」提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方卡组或手卡中选择1只「不死王 巫妖」
	local g=Duel.SelectMatchingCard(tp,c88989706.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	-- 无视召唤条件将选中的「不死王 巫妖」以表侧表示特殊召唤到己方场上（随后调用CompleteProcedure完成正规特召手续）
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)>0 then
		g:GetFirst():CompleteProcedure()
	end
end
