--ヘルグレイブ・スクワーマー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，自己场上有恶魔族怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以把自己场上1只「于贝尔」或者有那个卡名记述的怪兽破坏。
-- ②：把墓地的这张卡除外才能发动。从自己的手卡·墓地把「地狱墓场蠕动者」以外的1只攻击力和守备力是0的恶魔族怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片的两个效果，分别是①从手卡特殊召唤并可能破坏场上的于贝尔或其同名怪兽，②从墓地除外并特殊召唤攻击力和守备力为0的恶魔族怪兽
function s.initial_effect(c)
	-- 记录该卡效果文本上记载着卡号78371393（于贝尔）
	aux.AddCodeList(c,78371393)
	-- ①：自己·对方回合，自己场上有恶魔族怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以把自己场上1只「于贝尔」或者有那个卡名记述的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"自身特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DRAW_PHASE+TIMING_STANDBY_PHASE,TIMING_DRAW_PHASE+TIMING_STANDBY_PHASE+TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_ATTACK+TIMING_BATTLE_END+TIMING_END_PHASE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从自己的手卡·墓地把「地狱墓场蠕动者」以外的1只攻击力和守备力是0的恶魔族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤恶魔族怪兽"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 效果发动时需要将此卡从墓地除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 用于检测场上是否存在恶魔族怪兽的过滤函数
function s.cfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsFaceup()
end
-- 判断是否满足效果①的发动条件：自己场上有恶魔族怪兽存在
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检测自己场上是否存在至少1只恶魔族怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置效果①的发动时点和目标，检查是否可以将此卡特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 用于检测场上是否存在于贝尔或其同名怪兽的过滤函数
function s.desfilter(c)
	-- 检测目标怪兽是否为于贝尔或其同名怪兽
	return c:IsFaceupEx() and (c:IsCode(78371393) or aux.IsCodeListed(c,78371393))
end
-- 处理效果①的发动效果，将此卡特殊召唤并可能破坏场上的于贝尔或其同名怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 判断是否满足效果①的发动条件：特殊召唤成功、场上有于贝尔或其同名怪兽、玩家选择破坏
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把怪兽破坏？"
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择场上满足条件的1只怪兽进行破坏
		local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 为选中的怪兽显示被选为对象的动画效果
			Duel.HintSelection(g)
			-- 将选中的怪兽破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 用于筛选可特殊召唤的恶魔族怪兽的过滤函数
function s.spfilter(c,e,tp)
	return not c:IsCode(id)
		and c:IsRace(RACE_FIEND) and c:IsAttack(0) and c:IsDefense(0)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 设置效果②的发动时点和目标，检查是否可以特殊召唤符合条件的恶魔族怪兽
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测自己手牌或墓地中是否存在符合条件的恶魔族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤恶魔族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 处理效果②的发动效果，从手牌或墓地特殊召唤符合条件的恶魔族怪兽
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有足够的特殊召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的恶魔族怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的恶魔族怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的恶魔族怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
