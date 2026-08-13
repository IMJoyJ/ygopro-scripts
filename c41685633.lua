--雷神龍－サンダー・ドラゴン
-- 效果：
-- 「雷龙」怪兽×3
-- 这张卡用融合召唤以及以下方法才能特殊召唤。
-- ●把手卡1只雷族怪兽和「雷神龙-雷龙」以外的自己场上1只雷族融合怪兽除外的场合可以从额外卡组特殊召唤。
-- ①：雷族怪兽的效果在手卡发动时才能发动（伤害步骤也能发动）。场上1张卡破坏。
-- ②：场上的这张卡被效果破坏的场合，可以作为代替把自己墓地2张卡除外。
function c41685633.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：需要3只满足条件的怪兽作为融合素材，素材条件是融合素材字段为0x11c（即「雷龙」系列怪兽），相当于效果原文的「雷龙」怪兽×3。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x11c),3,true)
	-- 这张卡用融合召唤以及以下方法才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设定该特殊召唤条件效果的值：仅当召唤方式为融合召唤（SUMMON_TYPE_FUSION）时判定通过，从而限定这张卡只能以融合召唤/或下方追加手续出场。
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ●把手卡1只雷族怪兽和「雷神龙-雷龙」以外的自己场上1只雷族融合怪兽除外的场合可以从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c41685633.sprcon)
	e2:SetTarget(c41685633.sptg)
	e2:SetOperation(c41685633.sprop)
	c:RegisterEffect(e2)
	-- ①：雷族怪兽的效果在手卡发动时才能发动（伤害步骤也能发动）。场上1张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(41685633,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c41685633.descon)
	e3:SetTarget(c41685633.destg)
	e3:SetOperation(c41685633.desop)
	c:RegisterEffect(e3)
	-- ②：场上的这张卡被效果破坏的场合，可以作为代替把自己墓地2张卡除外。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetTarget(c41685633.desreptg)
	c:RegisterEffect(e4)
end
-- 定义用于该特殊召唤手续的素材候选过滤：卡片必须是雷族怪兽、能够作为除外代价除外、并且可以作为这张卡以特殊召唤方式融合召唤的素材。即负责搜寻手牌的雷族怪兽和场上可用的雷族融合怪兽。
function c41685633.sprfilter1(c,sc)
	return c:IsRace(RACE_THUNDER) and c:IsAbleToRemoveAsCost() and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
-- 定义第二类素材的过滤：卡片必须位于自己场上且是融合怪兽，并且不是「雷神龙-雷龙」这张卡（若卡本身不是该卡号则直接通过，若是该卡号但还存在其他融合卡名编号也视为不是该卡的素材限制）。这样保证场上素材是「雷神龙-雷龙」以外的雷族融合怪兽。
function c41685633.sprfilter2(c)
	if not (c:IsLocation(LOCATION_MZONE) and c:IsFusionType(TYPE_FUSION)) then return false end
	if not c:IsFusionCode(41685633) then return true end
	for i,code in ipairs({c:GetFusionCode()}) do
		if code~=41685633 then return true end
	end
	return false
end
-- 检查一组2张素材是否合法：通过gffcheck确认其中同时包含1张手卡区域的雷族怪兽和1张场上满足sprfilter2的雷族融合怪兽，并且除外这2张后自己额外卡组仍有空格可以特殊召唤该怪兽。
function c41685633.fselect(g,tp,sc)
	-- 用aux.gffcheck检查两种排列组合：要么第一张是手卡雷族怪兽且第二张是场上非雷神龙-雷龙的雷族融合怪兽，要么反之。即确保素材组恰好由1只手上的雷族怪兽和1只场上符合条件的雷族融合怪兽组成。
	return aux.gffcheck(g,Card.IsLocation,LOCATION_HAND,c41685633.sprfilter2,nil)
		-- 确认把这2张素材除外后，自己的额外卡组怪兽可用区域仍有空格，能够从额外卡组特殊召唤这张融合怪兽（考虑从额外卡组出场的空格数量）。
		and Duel.GetLocationCountFromEx(tp,tp,g,sc)>0
end
-- 特殊召唤手续的条件判断：若c为nil表示仅规则确认（返回true）；否则从自己手卡和场上筛选所有可能的雷族素材，再检查是否存在2张卡组成的合法素材组且满足除外后有空格，满足才允许进行该特殊召唤。
function c41685633.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 取得以tp为视角的自己手卡和自己场上所有符合sprfilter1的雷族怪兽（包括手卡的雷族怪兽和场上的雷族怪兽），排除c本身，作为该特殊召唤手续的备选素材。
	local g=Duel.GetMatchingGroup(c41685633.sprfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,c)
	return g:CheckSubGroup(c41685633.fselect,2,2,tp,c)
end
-- 特殊召唤手续的目标选择：获取候选素材组后，让玩家从中选择2张卡作为特殊召唤的素材；选择结果需满足fselect，选定后用KeepAlive和SetLabelObject保存选中的组，返回true，否则返回false。
function c41685633.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 再次获取候选素材组（因为目标选择阶段需要实际素材列表），用于玩家选择要除外的素材。
	local g=Duel.GetMatchingGroup(c41685633.sprfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,c)
	-- 向玩家显示选择提示：请选择要除外的卡（用于特殊召唤手续中要除外的素材）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,c41685633.fselect,true,2,2,tp,c)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续执行：从效果标签取出之前选择的素材组，将这张卡记录为以这组卡为素材进行特殊召唤，然后把素材组表侧除外，最后删除临时Group对象。
function c41685633.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	-- 将作为融合手续素材的2张卡表侧除外（REASON_SPSUMMON），这是该特殊召唤手续要求的除外代价。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- ①效果的发动条件：当前连锁上刚刚发动了雷族怪兽的效果，且该效果是从手卡发动的怪兽效果（原种族为雷族），满足这些条件时这张卡才能发动①效果。伤害步骤可发动由效果的EFFECT_FLAG_DAMAGE_STEP属性实现。
function c41685633.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁触发效果的发生位置（如手卡、场上等），用loc保存，以便判断是否满足‘在手卡发动’的条件。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return bit.band(loc,LOCATION_HAND)~=0 and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():GetOriginalRace()==RACE_THUNDER
end
-- ①效果的发动对象处理：在发动阶段（chk==0）先确认场上是否存在至少1张可以破坏的卡；然后获取场上所有卡，并设置操作信息为破坏效果，可能影响范围为场上所有卡，预定破坏1张。
function c41685633.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：场上是否存在至少1张卡，因为①效果必须破坏场上1张卡，若场上无卡则无法发动。
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有卡（双方怪兽区域和魔法陷阱区域），作为该破坏效果可能影响的范围。
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息：该连锁的处理分类为破坏，目标集合为场上所有卡（g），破坏数量为1张，使其他卡能根据此信息进行对应连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果的实际处理：再次获取场上所有卡，若存在卡则从中选择1张破坏（不取对象效果，处理时选择），用效果原因破坏。
function c41685633.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有卡，用于效果处理时供玩家选择要破坏的卡。
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 显示选择提示：请选择要破坏的卡，让玩家从场上选择1张。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 显示被选中卡的选中动画，并记录这些卡被选为对象（供连锁判定等使用）。
		Duel.HintSelection(sg)
		-- 将选中的卡以效果原因（REASON_EFFECT）破坏，完成①效果的破坏处理。
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
-- ②代替破坏效果的判定：当这张卡将要被破坏时，确认当前破坏原因不是‘代替破坏’本身，而是效果破坏；同时自己墓地至少有2张可以除外的卡。条件满足后，进一步询问玩家是否发动代替效果。
function c41685633.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT)
		-- 追加条件：自己墓地存在至少2张可以除外的卡，作为代替破坏所除外的代价。
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,2,nil) end
	-- 弹出是否发动代替破坏效果的询问（选择是才继续），即玩家决定是否用除外墓地2张卡来代替这张卡被效果破坏。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 选择要除外的墓地卡前，显示选择提示：请选择要除外的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从自己墓地选择2张可以除外的卡（必须正好2张），这些卡将作为代替破坏的代价。
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,2,2,nil)
		-- 将选择的2张墓地卡表侧表示除外（REASON_COST），完成代替破坏的代价，使这张卡不被效果破坏。
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		return true
	else return false end
end
