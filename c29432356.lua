--智天の神星龍
-- 效果：
-- ←5 【灵摆】 5→
-- 「智天之神星龙」的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从卡组选1只「神数」灵摆怪兽表侧表示加入自己的额外卡组，这张卡的灵摆刻度直到回合结束时变成和那只灵摆怪兽的灵摆刻度相同。
-- 【怪兽效果】
-- 这张卡不能通常召唤。这张卡在额外卡组表侧表示存在，把包含「神数」怪兽3只以上的自己场上的怪兽全部解放的场合才能特殊召唤。
-- ①：这张卡特殊召唤成功的回合，自己在通常的灵摆召唤外加上只有1次，自己主要阶段可以把「神数」怪兽灵摆召唤。
-- ②：1回合1次，把自己场上1只怪兽解放才能发动。从卡组把1只「神数」怪兽特殊召唤。
function c29432356.initial_effect(c)
	c:EnableReviveLimit()
	-- 为「智天之神星龙」添加灵摆怪兽属性（灵摆召唤、灵摆卡发动等基础特性），使其作为灵摆怪兽正常运作。
	aux.EnablePendulumAttribute(c)
	-- 「智天之神星龙」的灵摆效果1回合只能使用1次。①：自己主要阶段才能发动。从卡组选1只「神数」灵摆怪兽表侧表示加入自己的额外卡组，这张卡的灵摆刻度直到回合结束时变成和那只灵摆怪兽的灵摆刻度相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29432356,0))  --"「神数」灵摆怪兽加入自己的额外卡组"
	e1:SetCategory(CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,29432357)
	e1:SetTarget(c29432356.sctg)
	e1:SetOperation(c29432356.scop)
	c:RegisterEffect(e1)
	-- 这张卡不能通常召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	-- 这张卡在额外卡组表侧表示存在，把包含「神数」怪兽3只以上的自己场上的怪兽全部解放的场合才能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCondition(c29432356.hspcon)
	e3:SetOperation(c29432356.hspop)
	c:RegisterEffect(e3)
	-- ①：这张卡特殊召唤成功的回合，自己在通常的灵摆召唤外加上只有1次，自己主要阶段可以把「神数」怪兽灵摆召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetOperation(c29432356.penop)
	c:RegisterEffect(e4)
	-- ②：1回合1次，把自己场上1只怪兽解放才能发动。从卡组把1只「神数」怪兽特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(29432356,3))  --"从卡组把1只「神数」怪兽特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCost(c29432356.spcost)
	e5:SetTarget(c29432356.sptg)
	e5:SetOperation(c29432356.spop)
	c:RegisterEffect(e5)
end
-- 过滤卡组中的卡：必须是「神数」灵摆怪兽，且其左刻度不等于本卡的左刻度（防止选到无法改变刻度的同名刻度卡）。
function c29432356.scfilter(c,pc)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xc4)
		and c:GetLeftScale()~=pc:GetLeftScale()
end
-- 灵摆效果的发动条件与操作信息设置：自己主要阶段检查卡组是否存在符合条件的「神数」灵摆怪兽；若可以发动，则将效果类别设为回额外卡组，并标明处理时从卡组选择1张加入额外卡组。
function c29432356.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时点（chk==0）检查卡组中是否存在至少1张满足scfilter的「神数」灵摆怪兽，存在才允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c29432356.scfilter,tp,LOCATION_DECK,0,1,nil,e:GetHandler()) end
	-- 将当前连锁的操作信息设置为“从卡组将1张卡加入额外卡组”（CATEGORY_TOEXTRA），目标为卡组，供后续检测与连锁处理使用。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时，从卡组选择1只满足条件的「神数」灵摆怪兽，将其表侧表示加入额外卡组；若成功，则为此卡注册左右刻度变更效果，使左右灵摆刻度分别变为所选卡的左右刻度直到回合结束。
function c29432356.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 显示选择提示文字“请选择要加入自己的额外卡组的卡”，引导玩家进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(29432356,1))  --"请选择要加入自己的额外卡组的卡"
	-- 从卡组筛选并让玩家选择1只满足scfilter的「神数」灵摆怪兽（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c29432356.scfilter,tp,LOCATION_DECK,0,1,1,nil,c)
	local tc=g:GetFirst()
	-- 如果成功选到卡且将其表侧表示加入额外卡组，则继续执行后续的灵摆刻度变更处理。
	if tc and Duel.SendtoExtraP(tc,nil,REASON_EFFECT)>0 then
		-- 这张卡的灵摆刻度直到回合结束时变成和那只灵摆怪兽的灵摆刻度相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetValue(tc:GetLeftScale())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		e2:SetValue(tc:GetRightScale())
		c:RegisterEffect(e2)
	end
end
-- 特殊召唤条件判定：自己场上的怪兽全部可以解放，且其中包含3只以上「神数」怪兽，并且解放后额外卡组怪兽有可用的特殊召唤区域；同时保证场上存在可解放的怪兽。
function c29432356.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上主要怪兽区域的全部怪兽组，用于检查解放材料数量与「神数」怪兽数量要求。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 获取自己场上可解放的怪兽组（非上级召唤用途），用于确认存在可解放的怪兽。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	return (g:GetCount()>0 or rg:GetCount()>0) and g:FilterCount(Card.IsReleasable,nil,REASON_SPSUMMON)==g:GetCount()
		and g:FilterCount(Card.IsSetCard,nil,0xc4)>=3
		-- 额外卡组怪兽特殊召唤时，检查将自己场上怪兽全部解放后，额外怪兽区域/可用的主怪兽区域是否有空位。
		and Duel.GetLocationCountFromEx(tp,tp,g,c)>0
end
-- 执行特殊召唤手续时，解放自己场上所有可解放的怪兽（全部怪兽），作为这张卡从额外卡组特殊召唤的代价。
function c29432356.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 再次获取自己场上可解放的怪兽组（此时应为自己场上全部怪兽），准备全部解放。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 将这些怪兽全部解放，完成特殊召唤手续。
	Duel.Release(g,REASON_SPSUMMON)
end
-- 在这张卡特殊召唤成功时，给其控制者注册一个效果：本回合追加一次「神数」怪兽的灵摆召唤机会（仅在通常灵摆召唤之外追加1次），并持续到回合结束。
function c29432356.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ①：这张卡特殊召唤成功的回合，自己在通常的灵摆召唤外加上只有1次，自己主要阶段可以把「神数」怪兽灵摆召唤。②：1回合1次，把自己场上1只怪兽解放才能发动。从卡组把1只「神数」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29432356,2))  --"使用「智天之神星龙」的效果灵摆召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_PENDULUM_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetCountLimit(1,29432356)
	e2:SetValue(c29432356.pendvalue)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将刚创建的“追加灵摆召唤机会”效果注册给当前玩家tp，使该玩家本回合获得额外灵摆召唤的权利。
	Duel.RegisterEffect(e2,tp)
end
-- 作为追加灵摆召唤效果的判定值，仅允许「神数」系怪兽（setname 0xc4）通过这次追加的灵摆召唤出场。
function c29432356.pendvalue(e,c)
	return c:IsSetCard(0xc4)
end
-- 解放候选过滤器：当主怪兽区有空位时（ft>0）任何可解放怪兽都满足；若主怪兽区无空位，则只允许选择自己场上位于主怪兽区（非额外怪兽区）的怪兽，以便解放后空出主怪兽区来特殊召唤。
function c29432356.spcfilter(c,ft,tp)
	return ft>0 or (c:IsControler(tp) and c:GetSequence()<5)
end
-- 效果②的发动代价处理：检查并选择自己场上1只可解放的怪兽，将其解放作为发动代价（REASON_COST）。
function c29432356.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己主要怪兽区的空位数量，用于判断解放哪里的怪兽可腾出特殊召唤位置。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 效果发动时检查：主怪兽区空位数是否大于-1（即允许通过解放怪兽腾出至少1个空位）且存在满足spcfilter的可解放怪兽；满足才可发动。
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c29432356.spcfilter,1,nil,ft,tp) end
	-- 让玩家从自己场上选择1只满足spcfilter的怪兽作为解放代价。
	local sg=Duel.SelectReleaseGroup(tp,c29432356.spcfilter,1,1,nil,ft,tp)
	-- 将选中的怪兽解放，作为效果发动的代价。
	Duel.Release(sg,REASON_COST)
end
-- 从卡组筛选可特殊召唤的「神数」怪兽：必须属于「神数」系列且可以被当前效果特殊召唤（满足苏生限制与召唤条件）。
function c29432356.spfilter(c,e,tp)
	return c:IsSetCard(0xc4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的目标/发动条件：检查卡组中是否存在符合条件的「神数」怪兽；设置操作信息为从卡组特殊召唤1只怪兽。
function c29432356.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点（chk==0）检查卡组中是否存在至少1只满足spfilter的「神数」怪兽，存在才允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c29432356.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，标明该效果处理时将从卡组特殊召唤1只怪兽（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②处理：若主怪兽区有空位，则从卡组选择1只「神数」怪兽特殊召唤到自己的主怪兽区。
function c29432356.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若主怪兽区没有空位（≤0），则效果处理中止，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足spfilter的「神数」怪兽（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c29432356.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的场上（不检查召唤条件、不检查苏生限制，因为是效果特殊召唤）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
