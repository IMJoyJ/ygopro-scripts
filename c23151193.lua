--断罪のディアベルスター
-- 效果：
-- 这个卡名在规则上也当作「罪宝」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地把魔法卡和陷阱卡各1张除外才能发动。这张卡从手卡·墓地特殊召唤。
-- ②：自己·对方回合，把基本分支付一半，以对方场上1张卡为对象才能发动。那张卡破坏。那之后，场上有其他的「迪亚贝尔」怪兽卡存在的场合，可以从额外卡组把1只幻想魔族·魔法师族同调怪兽调整特殊召唤。
local s,id,o=GetID()
-- 创建并注册该卡的两个效果：①为从手卡/墓地除外魔法陷阱各1张作为COST进行特殊召唤的起动效果；②为支付一半LP取对象破坏对方场上1张卡，破坏后再从额外卡组特殊召唤1只幻想魔族·魔法师族同调调整的诱发即时效果。
function s.initial_effect(c)
	-- ①：从自己的手卡·墓地把魔法卡和陷阱卡各1张除外才能发动。这张卡从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，把基本分支付一半，以对方场上1张卡为对象才能发动。那张卡破坏。那之后，场上有其他的「迪亚贝尔」怪兽卡存在的场合，可以从额外卡组把1只幻想魔族·魔法师族同调怪兽调整特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- COST用魔法卡的过滤条件：该卡可以作为COST除外，且是魔法卡。
function s.spcostfilter1(c)
	return c:IsAbleToRemoveAsCost() and c:IsType(TYPE_SPELL)
end
-- COST用陷阱卡的过滤条件：该卡可以作为COST除外，且是陷阱卡。
function s.spcostfilter2(c)
	return c:IsAbleToRemoveAsCost() and c:IsType(TYPE_TRAP)
end
-- ①效果的COST合法性检查：手卡·墓地分别存在至少1张可除外的魔法卡和陷阱卡，且排除效果发动者自身。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡·墓地是否存在至少1张满足条件的魔法卡可作为COST，排除自身。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcostfilter1,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,e:GetHandler())
		-- 检查手卡·墓地是否存在至少1张满足条件的陷阱卡可作为COST，排除自身。
		and Duel.IsExistingMatchingCard(s.spcostfilter2,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,e:GetHandler()) end
	-- 给玩家显示“请选择要除外的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己手卡·墓地选择1张魔法卡作为COST，排除自身。
	local sg=Duel.SelectMatchingCard(tp,s.spcostfilter1,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,e:GetHandler())
	-- 从自己手卡·墓地选择1张陷阱卡作为COST，排除自身。
	local sg2=Duel.SelectMatchingCard(tp,s.spcostfilter2,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,e:GetHandler())
	-- 将选择的魔法卡和陷阱卡表侧表示除外，作为发动COST。
	Duel.Remove(sg+sg2,POS_FACEUP,REASON_COST)
end
-- ①效果发动时点的目标条件检查：自己主怪兽区有空位，且该卡可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的操作信息为特殊召唤，处理对象为本卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若该卡仍与效果关联且不受王家长眠之谷影响，则将其表侧表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定该卡是否仍与效果关联，并额外满足王家长眠之谷相关的过滤条件。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将该卡以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的COST函数：发动时总是合法，实际COST为支付当前LP一半的数值。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 付出当前LP一半（向下取整）的生命值作为COST。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- ②效果的取对象目标条件：选择对方场上1张卡为对象，并设置破坏操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在1张可以作为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给玩家显示“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1张卡作为效果对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次连锁的操作信息为破坏，对象为已选择的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 额外卡组特殊召唤候选的过滤条件：必须是同调怪兽且是调整；能被特殊召唤；种族为幻想魔族或魔法师族；且从额外卡组特召时有可用空格。
function s.spfilter(c,e,tp)
	return c:IsAllTypes(TYPE_SYNCHRO+TYPE_MONSTER+TYPE_TUNER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsRace(RACE_ILLUSION+RACE_SPELLCASTER)
		-- 检查从额外卡组特殊召唤该候选怪兽时是否有可用的额外怪兽区空格。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 场上“迪亚贝尔”怪兽的判定：表侧表示，属于0x19b字段，且原本类型包含怪兽。
function s.spconfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x19b) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- ②效果处理：先破坏对象；若破坏成功且场上有其他“迪亚贝尔”怪兽、额外卡组有符合条件的怪兽，则询问玩家是否额外特殊召唤，并执行特殊召唤。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判定对象卡仍与效果关联，并实际破坏成功。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 检查除本卡以外的场上是否存在表侧表示的“迪亚贝尔”怪兽。
		and Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,aux.ExceptThisCard(e))
		-- 检查额外卡组是否存在满足特殊召唤条件的幻想魔族·魔法师族同调调整怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		-- 询问玩家是否进行后续的额外卡组特殊召唤。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 中断当前效果的处理，使后续特殊召唤视为与破坏处理不同时进行。
		Duel.BreakEffect()
		-- 给玩家显示“请选择要特殊召唤的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只满足条件的怪兽作为特殊召唤对象。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的额外卡组怪兽表侧表示特殊召唤到自己的场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
