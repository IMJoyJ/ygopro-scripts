--赫ける王の烙印
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：选需以「阿不思的落胤」为融合素材的自己场上1只融合怪兽，那只怪兽以外的场上的全部表侧表示的卡的效果直到回合结束时无效。
-- ②：这个回合有融合怪兽被送去自己墓地的场合，结束阶段才能发动。墓地的这张卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果：登记「阿不思的落胤」关联卡名；创建并注册①的魔法卡发动效果（无效全场表侧卡效果）和②的墓地回收效果；通过SetCountLimit(1,id)实现‘这个卡名的①②的效果1回合只能有1次使用其中任意1个’的共享次数限制；并注册全局监测融合怪兽进墓地的辅助效果。
function s.initial_effect(c)
	-- 将「阿不思的落胤」（68468459）登记为这张卡上记载的卡名，用于判断融合怪兽是否以阿不思的落胤为素材。
	aux.AddCodeList(c,68468459)
	-- 对应①效果：‘①：选需以「阿不思的落胤」为融合素材的自己场上1只融合怪兽，那只怪兽以外的场上的全部表侧表示的卡的效果直到回合结束时无效。’
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 对应②效果：‘②：这个回合有融合怪兽被送去自己墓地的场合，结束阶段才能发动。墓地的这张卡加入手卡。’
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 对应效果原文：‘这个回合有融合怪兽被送去自己墓地的场合’以及‘①：选需以「阿不思的落胤」为融合素材的自己场上1只融合怪兽，那只怪兽以外的场上的全部表侧表示的卡的效果直到回合结束时无效。’
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(s.checkop)
		-- 将全局监测效果注册到决斗中，持续监听怪兽被送去墓地的场合，为②的发动条件做记录。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 定义过滤函数：判断一张卡是否为融合怪兽且控制者为指定玩家，用于识别‘融合怪兽被送去自己墓地’。
function s.checkfilter(c,tp)
	return c:IsType(TYPE_FUSION) and c:IsControler(tp)
end
-- 对两个玩家分别检查本次送入墓地的怪兽中是否存在属于该玩家的融合怪兽，若有则为该玩家注册本回合的发动条件标记。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		-- 如果本次送去墓地的怪兽中存在属于玩家p的融合怪兽，则给玩家p注册编号为id的标记，并在结束阶段重置，标记‘这个回合有融合怪兽被送去自己墓地’。
		if eg:IsExists(s.checkfilter,1,nil,p) then Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1) end
	end
end
-- 定义①的选择对象过滤器：自己场上表侧表示、融合素材包含「阿不思的落胤」的融合怪兽，且场上还存在其他表侧可无效的卡，以保证有‘那只怪兽以外的表侧表示的卡’。
function s.filter(c)
	-- 判断该卡是表侧融合怪兽，且其融合素材包含「阿不思的落胤」（68468459）。
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459)
		-- 确认场上（除该怪兽外）存在至少1张表侧可无效的卡，确保发动时存在可被无效的其他表侧卡片。
		and Duel.IsExistingMatchingCard(s.dfilter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- 定义可被无效的表侧卡的过滤函数：表侧表示且满足一般的可无效条件（如效果怪兽、未无效的魔陷、表侧陷阱怪兽等）。
function s.dfilter(c)
	-- 判断这张卡表侧表示且能够被无效效果无效化。
	return c:IsFaceup() and aux.NegateAnyFilter(c)
end
-- ①的发动条件判定：自己场上是否存在满足条件的融合怪兽（即素材含阿不思且场上有其他可无效卡）。存在才可发动。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若不存在这样的融合怪兽，则①效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- ①效果处理：选择自己场上1只符合条件的融合怪兽，获取该怪兽以外的场上全部表侧可无效的卡，对每张卡执行无效化处理，使其效果直到回合结束时无效。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家显示选择表侧表示的卡片的提示信息（HINTMSG_FACEUP）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 效果处理时由玩家从自己场上选择1只满足s.filter的融合怪兽（不取对象效果）。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	if #g==0 then return end
	-- 显示并记录所选卡的选中动画，将该卡登记为当前效果处理中的对象。
	Duel.HintSelection(g)
	-- 获取场上除所选融合怪兽以外的全部表侧可无效的卡，作为效果要无效的对象集合。
	local ng=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,g)
	-- 遍历这些要被无效的卡，逐一执行无效化处理。
	for nc in aux.Next(ng) do
		-- 使与该卡相关的连锁无效化，并在该卡变为里侧表示时重置，防止无效效果被连锁解除。
		Duel.NegateRelatedChain(nc,RESET_TURN_SET)
		-- 对应①效果中的‘那只怪兽以外的场上的全部表侧表示的卡的效果直到回合结束时无效。’
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		nc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		nc:RegisterEffect(e2)
		if nc:IsType(TYPE_TRAPMONSTER) then
			local e3=e1:Clone()
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			nc:RegisterEffect(e3)
		end
	end
end
-- ②的发动条件：本回合玩家有融合怪兽被送去自己墓地（存在标记），且当前阶段为结束阶段。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 确认玩家本回合有融合怪兽被送入墓地，且当前处于结束阶段，才允许②发动。
	return Duel.GetFlagEffect(tp,id)>0 and Duel.GetCurrentPhase()==PHASE_END
end
-- ②的发动目标检查：墓地中的这张卡是否能够加入手卡；若可以，则设置本效果将把这张卡加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 向系统声明本次效果处理将把墓地中的这张卡加入持有者手卡（数量1），供相关卡的效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- ②的效果处理：若这张卡仍在墓地且与发动效果保持关联，则将其从墓地加入持有者手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若墓地中的这张卡仍与效果关联，则将其加入持有者手卡，完成回收。
	if c:IsRelateToEffect(e) then Duel.SendtoHand(c,nil,REASON_EFFECT) end
end
