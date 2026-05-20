--DDD覇龍王ペンドラゴン
-- 效果：
-- ①：这张卡在手卡的场合，自己主要阶段从自己的手卡·场上把龙族怪兽和恶魔族怪兽各1只解放才能发动。这张卡从手卡特殊召唤。
-- ②：1回合1次，自己主要阶段丢弃1张手卡才能发动。这张卡的攻击力直到回合结束时上升500。那之后，可以选场上1张魔法·陷阱卡破坏。
function c56619314.initial_effect(c)
	-- ①：这张卡在手卡的场合，自己主要阶段从自己的手卡·场上把龙族怪兽和恶魔族怪兽各1只解放才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56619314,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c56619314.spcost)
	e1:SetTarget(c56619314.sptg)
	e1:SetOperation(c56619314.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段丢弃1张手卡才能发动。这张卡的攻击力直到回合结束时上升500。那之后，可以选场上1张魔法·陷阱卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56619314,1))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c56619314.cost)
	e2:SetOperation(c56619314.operation)
	c:RegisterEffect(e2)
end
-- 过滤属于指定种族且由自己控制的卡片（用于特殊召唤的解放检查）
function c56619314.spfilter(c,rac,tp)
	return c:IsRace(rac) and c:IsControler(tp)
end
-- 特殊召唤效果的Cost处理函数，检查并执行解放手卡·场上龙族和恶魔族怪兽各1只的操作
function c56619314.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=0
		-- 检查自己场上是否存在可解放的龙族怪兽，若有则将所需空怪兽区域数减1
		if Duel.CheckReleaseGroup(tp,c56619314.spfilter,1,nil,RACE_DRAGON,tp) then ct=ct-1 end
		-- 检查自己场上是否存在可解放的恶魔族怪兽，若有则将所需空怪兽区域数减1
		if Duel.CheckReleaseGroup(tp,c56619314.spfilter,1,nil,RACE_FIEND,tp) then ct=ct-1 end
		-- 检查特殊召唤此卡所需的怪兽区域空格数是否足够
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>ct
			-- 检查手卡·场上是否存在除这张卡以外的至少1只可解放的龙族怪兽
			and Duel.CheckReleaseGroupEx(tp,Card.IsRace,1,REASON_COST,true,e:GetHandler(),RACE_DRAGON)
			-- 检查手卡·场上是否存在除这张卡以外的至少1只可解放的恶魔族怪兽
			and Duel.CheckReleaseGroupEx(tp,Card.IsRace,1,REASON_COST,true,e:GetHandler(),RACE_FIEND)
	end
	-- 获取自己场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>0 then
		-- 让玩家从手卡·场上选择1只除这张卡以外的龙族怪兽准备解放
		local g1=Duel.SelectReleaseGroupEx(tp,Card.IsRace,1,1,REASON_COST,true,e:GetHandler(),RACE_DRAGON)
		-- 让玩家从手卡·场上选择1只除这张卡以外的恶魔族怪兽准备解放
		local g2=Duel.SelectReleaseGroupEx(tp,Card.IsRace,1,1,REASON_COST,true,e:GetHandler(),RACE_FIEND)
		g1:Merge(g2)
		-- 解放选中的龙族和恶魔族怪兽
		Duel.Release(g1,REASON_COST)
	elseif ft==0 then
		-- 当场上没有空格时，必须先从场上选择1只龙族或恶魔族怪兽解放以腾出格子
		local g1=Duel.SelectReleaseGroup(tp,c56619314.spfilter,1,1,nil,RACE_DRAGON+RACE_FIEND,tp)
		local rac=RACE_DRAGON
		if g1:GetFirst():IsRace(RACE_DRAGON) then rac=RACE_FIEND end
		-- 从手卡·场上选择另1个种族的怪兽准备解放
		local g2=Duel.SelectReleaseGroupEx(tp,Card.IsRace,1,1,REASON_COST,true,e:GetHandler(),rac)
		g1:Merge(g2)
		-- 解放选中的两只怪兽（其中至少一只是从场上解放以腾出格子）
		Duel.Release(g1,REASON_COST)
	else
		-- 从场上选择1只龙族怪兽准备解放
		local g1=Duel.SelectReleaseGroup(tp,c56619314.spfilter,1,1,nil,RACE_DRAGON,tp)
		-- 从场上选择1只恶魔族怪兽准备解放
		local g2=Duel.SelectReleaseGroup(tp,c56619314.spfilter,1,1,nil,RACE_FIEND,tp)
		g1:Merge(g2)
		-- 解放选中的场上龙族和恶魔族怪兽
		Duel.Release(g1,REASON_COST)
	end
end
-- 特殊召唤效果的Target处理函数，检查自身是否能特殊召唤并设置特殊召唤的操作信息
function c56619314.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示此效果会特殊召唤1张自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的Operation处理函数，将自身特殊召唤到场上
function c56619314.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 攻击力上升效果的Cost处理函数，检查并执行丢弃1张手卡的操作
function c56619314.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤场上的魔法·陷阱卡（用于破坏效果的目标筛选）
function c56619314.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 攻击力上升及破坏效果的Operation处理函数，使自身攻击力上升500，并可选择破坏场上1张魔法·陷阱卡
function c56619314.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 获取场上所有的魔法·陷阱卡
		local g=Duel.GetMatchingGroup(c56619314.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		-- 若场上存在魔法·陷阱卡，询问玩家是否选择其中1张破坏
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(56619314,2)) then  --"是否选场上1张魔法·陷阱卡破坏？"
			-- 中断当前效果处理，使后续的破坏处理与攻击力上升不视为同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local dg=g:Select(tp,1,1,nil)
			-- 显式展示被选为破坏目标的卡片
			Duel.HintSelection(dg)
			-- 破坏选中的魔法·陷阱卡
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
