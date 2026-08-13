--ミスティック・ソードマン LV2
-- 效果：
-- 攻击里侧守备表示怪兽的场合，不进行伤害计算，那只怪兽以里侧守备表示的状态直接破坏。这张卡战斗破坏怪兽的回合的结束阶段，可以把这张卡送去墓地，从手卡·卡组特殊召唤1只「谜之剑士 LV4」
function c47507260.initial_effect(c)
	-- “这张卡战斗破坏怪兽的回合”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c47507260.bdop)
	c:RegisterEffect(e1)
	-- “攻击里侧守备表示怪兽的场合，不进行伤害计算，那只怪兽以里侧守备表示的状态直接破坏。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47507260,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCondition(c47507260.descon)
	e2:SetTarget(c47507260.destg)
	e2:SetOperation(c47507260.desop)
	c:RegisterEffect(e2)
	-- “这张卡战斗破坏怪兽的回合的结束阶段，可以把这张卡送去墓地，从手卡·卡组特殊召唤1只「谜之剑士 LV4」。”
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(47507260,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCondition(c47507260.spcon)
	e3:SetCost(c47507260.spcost)
	e3:SetTarget(c47507260.sptg)
	e3:SetOperation(c47507260.spop)
	c:RegisterEffect(e3)
end
c47507260.lvup={74591968}
-- 此卡战斗破坏怪兽时，给自身注册一个标记（47507260），该标记持续到结束阶段，用于记录“这张卡战斗破坏怪兽的回合”，作为结束阶段升级效果发动条件。
function c47507260.bdop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(47507260,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 判断当前战斗是否满足条件：攻击者为这张卡自身，且攻击对象存在、为里侧守备表示（即攻击里侧守备表示怪兽的场合）。
function c47507260.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击对象怪兽。
	local d=Duel.GetAttackTarget()
	-- 检查攻击者是否为这张卡自身，并且攻击对象存在且为里侧守备表示。
	return e:GetHandler()==Duel.GetAttacker() and d and d:IsFacedown() and d:IsDefensePos()
end
-- 破坏效果的目标设定：在发动时将当前攻击对象指定为要破坏的卡，并注册破坏类操作信息。
function c47507260.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次效果的操作信息登记为破坏当前攻击对象（1张），以便连锁检测等系统判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
-- 效果处理时，若攻击目标仍与本次战斗相关（未离场或未失去关联），则将其破坏。
function c47507260.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击对象（处理阶段再次取得）。
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		-- 以效果原因将攻击对象怪兽破坏。
		Duel.Destroy(d,REASON_EFFECT)
	end
end
-- 检查这张卡是否带有之前设置的标记（47507260），即是否在本回合战斗破坏过怪兽，作为升级效果能否在结束阶段发动的条件。
function c47507260.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(47507260)>0
end
-- 升级效果的代价设定：可以把自己送去墓地作为发动代价。
function c47507260.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡自身送去墓地，作为效果发动代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 筛选符合条件的“谜之剑士 LV4”：卡名对应74591968，并且能被效果特殊召唤（无视召唤条件与苏生限制）。
function c47507260.spfilter(c,e,tp)
	return c:IsCode(74591968) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 升级效果发动条件的检查：主怪兽区有可用空间，并且手卡·卡组中存在至少1只可特殊召唤的「谜之剑士 LV4」。
function c47507260.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定主怪兽区是否有可用区域（此处>-1表示区域数不为负数，即存在可用格）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 判定手卡·卡组中是否存在至少1只符合条件的「谜之剑士 LV4」。
		and Duel.IsExistingMatchingCard(c47507260.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记本次效果为特殊召唤类操作，预计从手卡·卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理：若主怪兽区仍有空位，则从手卡·卡组选择1只「谜之剑士 LV4」特殊召唤，并执行召唤成功后的处理。
function c47507260.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主怪兽区有空位，否则不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作者显示选择提示，要求选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组中选择1张符合条件的「谜之剑士 LV4」（由spfilter过滤）。
	local g=Duel.SelectMatchingCard(tp,c47507260.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的「谜之剑士 LV4」以表侧攻击表示特殊召唤到自己的主要怪兽区（此处忽略召唤条件与苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
