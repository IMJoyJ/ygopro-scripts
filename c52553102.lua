--ジュラック・アステロ
-- 效果：
-- 调整＋调整以外的恐龙族怪兽1只以上
-- ①：这张卡同调召唤的场合才能发动。从自己的卡组·墓地把1张「朱罗纪」魔法·陷阱卡在自己场上盖放。
-- ②：1回合1次，对方把怪兽特殊召唤之际，从自己墓地把2只恐龙族怪兽除外才能发动。那个无效，那些怪兽破坏。
-- ③：对方回合，从自己墓地把包含这张卡的2只「朱罗纪」怪兽除外才能发动。从额外卡组把1只「朱罗纪陨石兽」当作同调召唤作特殊召唤。
local s,id,o=GetID()
-- 初始化「朱罗纪小行星兽」的效果：登记关联卡名，设定同调召唤素材（调整＋调整以外的恐龙族怪兽1只以上），解除苏生限制，并注册①盖放、②无效召唤、③特殊召唤三个效果。
function s.initial_effect(c)
	-- 登记这张卡文本中提到的「朱罗纪陨石兽」（17548456），使系统能关联该卡名。
	aux.AddCodeList(c,17548456)
	-- 设定同调召唤手续：调整＋调整以外的恐龙族怪兽1只以上作为素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_DINOSAUR),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。从自己的卡组·墓地把1张「朱罗纪」魔法·陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，对方把怪兽特殊召唤之际，从自己墓地把2只恐龙族怪兽除外才能发动。那个无效，那些怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"无效并破坏"
	e2:SetCategory(CATEGORY_DISABLE_SUMMON|CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_SPSUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- ③：对方回合，从自己墓地把包含这张卡的2只「朱罗纪」怪兽除外才能发动。从额外卡组把1只「朱罗纪陨石兽」当作同调召唤作特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：这张卡同调召唤成功的场合才能发动。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果①选择卡牌的过滤条件：是「朱罗纪」魔法·陷阱卡且可以盖放。
function s.setfilter(c)
	return c:IsSetCard(0x22) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 效果①发动时确认：自己卡组·墓地存在至少1张符合条件的「朱罗纪」魔法·陷阱卡。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果①发动时的合法性检测：检查自己卡组·墓地是否存在1张满足s.setfilter的「朱罗纪」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- 效果①的发动处理：从自己卡组·墓地把1张符合条件的「朱罗纪」魔法·陷阱卡盖放到自己场上。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要盖放的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己卡组·墓地选择1张符合条件的「朱罗纪」魔法·陷阱卡，过滤时排除受王家长眠之谷影响的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的「朱罗纪」魔法·陷阱卡盖放到自己场上。
		Duel.SSet(tp,tc)
	end
end
-- 效果②的发动条件：对方进行怪兽的特殊召唤之际，且当前没有其他连锁处理。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断特殊召唤由对方玩家进行（tp≠ep）且该特殊召唤不处于连锁中（连锁数为0），确保是在召唤之际直接发动。
	return tp~=ep and Duel.GetCurrentChain()==0
end
-- 效果②的cost过滤条件：墓地中的恐龙族怪兽且可以作为cost除外。
function s.discfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsAbleToRemoveAsCost()
end
-- 效果②的cost：从自己墓地选择2只恐龙族怪兽除外作为发动代价。
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost合法性检查：自己墓地是否存在至少2只恐龙族怪兽可以作为除外代价。
	if chk==0 then return Duel.IsExistingMatchingCard(s.discfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 向玩家显示“请选择要除外的卡”的提示信息，用于选择cost。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择2只恐龙族怪兽作为除外cost。
	local g=Duel.SelectMatchingCard(tp,s.discfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的2只恐龙族怪兽以表侧表示除外，作为效果②的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的目标设定：将正在特殊召唤的那组怪兽（eg）标记为本次无效召唤与破坏的对象，并写入操作信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定操作信息：预定要无效的召唤对象为eg（对方正在特殊召唤的怪兽），数量为eg的数量，用于触发相关检测。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设定操作信息：预定要破坏的对象为eg，数量为eg的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 效果②的处理：无效对方那次特殊召唤，并将那些怪兽破坏。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使eg中正在进行的特殊召唤无效化。
	Duel.NegateSummon(eg)
	-- 将因特殊召唤被无效而处于特殊召唤过程中的那些怪兽破坏。
	Duel.Destroy(eg,REASON_EFFECT)
end
-- 效果③的发动条件：仅在对方的回合可以发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是这张卡的控制者，即对方回合。
	return Duel.GetTurnPlayer()~=tp
end
-- 效果③的cost过滤条件：墓地中的「朱罗纪」怪兽且可以作为cost除外。
function s.cfilter(c)
	return c:IsSetCard(0x22) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果③的cost：从自己墓地把包含这张卡的2只「朱罗纪」怪兽除外。先选择另一只，再加上自身。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- cost合法性检查：这张卡自己满足除外条件，且墓地中还存在至少1张其他符合条件的「朱罗纪」怪兽。
	if chk==0 then return s.cfilter(c) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 从自己墓地选择1张符合条件的「朱罗纪」怪兽（不包含自身），用于与自身组成2张cost。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	-- 将选出的怪兽与这张卡自身一起以表侧表示除外，作为效果③的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果③特殊召唤目标的过滤条件：必须是「朱罗纪陨石兽」（17548456）、同调怪兽，能以同调召唤手续特殊召唤，且额外卡组特殊召唤区域有空位。
function s.spfilter(c,e,tp)
	return c:IsCode(17548456) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 检查从额外卡组特殊召唤时是否存在可用的怪兽区域空格。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果③发动时确认：没有必须使用特定素材的同调召唤限制，且额外卡组存在符合条件的「朱罗纪陨石兽」。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否受到“必须作为同调素材”的效果限制（EFFECT_MUST_BE_SMATERIAL），若存在则不能发动这个特殊召唤。
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查额外卡组中是否存在至少1只可由本次效果当作同调召唤特殊召唤的「朱罗纪陨石兽」。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设定操作信息：预定从额外卡组特殊召唤1只怪兽，用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果③处理：从额外卡组选1只「朱罗纪陨石兽」，清除其素材信息，将其以同调召唤方式特殊召唤，成功后调用CompleteProcedure完成同调手续。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认玩家没有受到必须使用特定素材的同调召唤限制，若受到限制则不再处理特殊召唤。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只符合条件的「朱罗纪陨石兽」作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 将选中的「朱罗纪陨石兽」以同调召唤方式特殊召唤到场上，若特殊召唤成功则继续执行CompleteProcedure完成同调召唤后的手续。
		if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	end
end
