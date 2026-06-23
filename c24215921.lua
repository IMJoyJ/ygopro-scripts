--ヘルグレイブ・スクワーマー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，自己场上有恶魔族怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以把自己场上1只「于贝尔」或者有那个卡名记述的怪兽破坏。
-- ②：把墓地的这张卡除外才能发动。从自己的手卡·墓地把「地狱墓场蠕动者」以外的1只攻击力和守备力是0的恶魔族怪兽特殊召唤。
local s,id,o=GetID()
-- 定义卡片初始效果
function s.initial_effect(c)
	-- 将78371393加入代码列表，用于后续的卡名识别。
	aux.AddCodeList(c,78371393)
	-- 创建并注册第一个效果：自身特殊召唤和破坏怪兽。该效果为快速启动型，可在任意时机发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"自身特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 创建并注册第二个效果：从墓地特殊召唤恶魔族怪兽。该效果为起动型，需要消耗。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤恶魔族怪兽"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置cost，使用aux.bfgcost函数实现将这张卡除外的逻辑。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 定义一个过滤函数s.cfilter，用于判断恶魔族正面表示怪兽。
function s.cfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsFaceup()
end
-- 定义效果①的条件函数s.spcon，检查场上是否存在恶魔族怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有至少一张恶魔族怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义效果①的目标选择函数s.sptg，用于确定特殊召唤和破坏的目标。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家的怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义一个过滤函数s.desfilter，用于判断可以被破坏的怪兽（包括自身和同名卡）。
function s.desfilter(c)
	-- 判断怪兽是否正面表示且是地狱墓场蠕动者或具有该卡名的怪兽。
	return c:IsFaceupEx() and (c:IsCode(78371393) or aux.IsCodeListed(c,78371393))
end
-- 定义效果①的操作函数s.spop，实现特殊召唤和破坏怪兽的逻辑。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 如果特殊召唤成功并且存在可被破坏的怪兽，则询问玩家是否要进行破坏。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把怪兽破坏？"
		-- 中断当前效果链，防止连锁发动。
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家从场上选择一个符合s.desfilter条件的怪兽。
		local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 高亮显示被选中的怪兽。
			Duel.HintSelection(g)
			-- 以效果为理由破坏选定的怪兽。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 定义一个过滤函数s.spfilter，用于判断可以特殊召唤的恶魔族怪兽（攻击力/守备力为0）。
function s.spfilter(c,e,tp)
	return not c:IsCode(id)
		and c:IsRace(RACE_FIEND) and c:IsAttack(0) and c:IsDefense(0)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 定义效果②的目标选择函数s.sptg2，用于确定特殊召唤的目标。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家的怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌或墓地中是否存在符合s.spfilter条件的恶魔族怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 设置操作信息，表示将要进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 定义效果②的操作函数s.spop2，实现从手牌/墓地特殊召唤恶魔族怪兽的逻辑。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 如果怪兽区已满则直接返回。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌或墓地中选择一个符合aux.NecroValleyFilter(s.spfilter)条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 特殊召唤选定的怪兽。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
