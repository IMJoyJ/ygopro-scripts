--死神鳥シムルグ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤成功时才能发动。从卡组把「死神鸟 斯摩夫」以外的1张「斯摩夫」卡送去墓地。
-- ②：这张卡在墓地存在，对方的魔法与陷阱区域没有卡存在的场合才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个效果的发动后，直到回合结束时自己不是鸟兽族怪兽不能特殊召唤。
function c23619206.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从卡组把「死神鸟 斯摩夫」以外的1张「斯摩夫」卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23619206,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,23619206)
	e1:SetTarget(c23619206.tgtg)
	e1:SetOperation(c23619206.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，对方的魔法与陷阱区域没有卡存在的场合才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个效果的发动后，直到回合结束时自己不是鸟兽族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23619206,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,23619207)
	e2:SetCondition(c23619206.spcon)
	e2:SetTarget(c23619206.sptg)
	e2:SetOperation(c23619206.spop)
	c:RegisterEffect(e2)
end
-- 定义①的送墓筛选条件：是「斯摩夫」系列卡、不是「死神鸟 斯摩夫」自身，且可以被送去墓地。
function c23619206.tgfilter(c)
	return c:IsSetCard(0x12d) and not c:IsCode(23619206) and c:IsAbleToGrave()
end
-- ①的发动条件判定与操作设定：检查卡组是否存在符合条件的「斯摩夫」卡，并设置将1张卡送去墓地的操作信息。
function c23619206.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在己方卡组是否存在至少1张满足tgfilter的「斯摩夫」卡，以判断能否发动①。
	if chk==0 then return Duel.IsExistingMatchingCard(c23619206.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果为从卡组将1张卡送去墓地（CATEGORY_TOGRAVE）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①的效果处理：从己方卡组选择1张符合条件的「斯摩夫」卡送去墓地。
function c23619206.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家弹出选择提示：“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从己方卡组选择1张满足tgfilter的卡（「斯摩夫」卡且不是「死神鸟 斯摩夫」自身）。
	local g=Duel.SelectMatchingCard(tp,c23619206.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 定义过滤条件：判断卡片是否位于魔法与陷阱区域的前5格（不含场地魔法格），用于检查对方后场是否有卡。
function c23619206.cfilter(c)
	return c:GetSequence()<5
end
-- ②的发动条件判定：对方魔法与陷阱区域没有卡存在时才能发动。
function c23619206.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回对方场上是否不存在位于魔法与陷阱区域（不含场地魔法格）的卡片。
	return not Duel.IsExistingMatchingCard(c23619206.cfilter,tp,0,LOCATION_SZONE,1,nil)
end
-- ②发动时的合法性检查：自己怪兽区域存在空位，且墓地中的这张卡能够以表侧守备表示特殊召唤。
function c23619206.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域（空格数>0）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：本次效果为将这张卡特殊召唤（对象为e:GetHandler()，数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②的效果处理：将这张卡守备表示特殊召唤；成功后给它附加“离场时除外”的永续效果，并给自己附加“本回合不能特殊召唤鸟兽族以外的怪兽”的自肃效果。
function c23619206.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡仍与效果关联，并尝试将其以表侧守备表示特殊召唤；若特殊召唤成功则继续执行后续处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
	-- 这个效果的发动后，直到回合结束时自己不是鸟兽族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c23619206.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到场上，使其影响当前玩家tp（直到回合结束）。
	Duel.RegisterEffect(e1,tp)
end
-- 定义自肃限制条件：只有鸟兽族怪兽可以被特殊召唤，即非鸟兽族怪兽不能特殊召唤。
function c23619206.splimit(e,c)
	return not c:IsRace(RACE_WINDBEAST)
end
