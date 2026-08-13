--ホーリーナイツ・シエル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，让「圣夜骑士团·西耶勒」以外的自己场上1只「圣夜骑士」怪兽或者龙族·光属性·7星怪兽回到持有者手卡才能发动。这张卡特殊召唤。
-- ②：自己场上没有怪兽存在的场合，把墓地的这张卡除外才能发动。从手卡把1只龙族·光属性·7星怪兽特殊召唤。
function c27036706.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，让「圣夜骑士团·西耶勒」以外的自己场上1只「圣夜骑士」怪兽或者龙族·光属性·7星怪兽回到持有者手卡才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27036706,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,27036706)
	e1:SetCost(c27036706.spcost1)
	e1:SetTarget(c27036706.sptg1)
	e1:SetOperation(c27036706.spop1)
	c:RegisterEffect(e1)
	-- ②：自己场上没有怪兽存在的场合，把墓地的这张卡除外才能发动。从手卡把1只龙族·光属性·7星怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27036706,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,27036707)
	e2:SetCondition(c27036706.spcon2)
	-- 设置②效果的发动代价为把墓地中的这张卡除外（aux.bfgcost实现除外自身作为COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c27036706.sptg2)
	e2:SetOperation(c27036706.spop2)
	c:RegisterEffect(e2)
end
-- 定义①效果COST选择对象的过滤函数：候选卡必须能作为COST返回手牌，且返回后自己场上仍有可用怪兽区，并且是「圣夜骑士」怪兽（卡名不含本卡）或龙族·光属性·7星怪兽。
function c27036706.cfilter(c,tp)
	-- 候选卡必须可以作为COST返回手牌，且将该卡返回手牌后自己场上仍有空的怪兽区域，以确保随后能特殊召唤这张卡。
	return c:IsAbleToHandAsCost() and Duel.GetMZoneCount(tp,c)>0
		and (c:IsSetCard(0x159) and not c:IsCode(27036706) or c:IsRace(RACE_DRAGON) and c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_LIGHT))
end
-- ①效果的COST处理：从自己场上选择1只满足cfilter条件的怪兽返回持有者手卡作为发动代价；检测阶段只确认存在可选卡，实际执行时用选择框选出并送入手牌。
function c27036706.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段（chk==0）检查自己场上是否存在满足cfilter过滤条件的卡，若不存在则不能发动①效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c27036706.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 显示选择提示“请选择要返回手牌的卡”，引导玩家选择要返回手牌的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从自己场上选择1只满足cfilter条件的怪兽，作为①效果的COST返回手牌。
	local g=Duel.SelectMatchingCard(tp,c27036706.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 将选择的卡返回持有者手卡，作为①效果的发动COST。
	Duel.SendtoHand(g,nil,REASON_COST)
end
-- ①效果的发动条件判定：确认此卡（手牌中的这张卡）能够被特殊召唤；若能，则设置后续特殊召唤的操作信息。
function c27036706.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理时进行特殊召唤的操作信息：目标为本卡（手牌中的此卡），数量为1，取不取对象的信息按规则处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：若此卡仍与当前效果关联，则将其特殊召唤到自己场上。
function c27036706.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：自己场上没有怪兽存在时才可发动。
function c27036706.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（主要怪兽区）的怪兽数量为0，即自己场上没有怪兽。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 定义②效果从手卡特殊召唤对象的过滤函数：必须是龙族·光属性·7星怪兽，并且能够被特殊召唤。
function c27036706.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件判定：自己场上有空余的怪兽区域，且手卡中存在满足spfilter条件的可特殊召唤的怪兽。
function c27036706.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在检测阶段确认自己场上存在可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认手卡中是否存在满足spfilter过滤条件的龙族·光属性·7星怪兽。
		and Duel.IsExistingMatchingCard(c27036706.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置②效果处理时要从手卡特殊召唤1只怪兽的操作信息；由于是不取对象的效果，targets设为nil，位置为手卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果的处理：确认仍有空余怪兽区后，从手卡选择1只符合条件的龙族·光属性·7星怪兽，并以表侧表示特殊召唤。
function c27036706.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若自己场上没有可用怪兽区域，则本次特殊召唤无法进行，直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示“请选择要特殊召唤的卡”，引导玩家选择手卡中的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只满足spfilter条件的龙族·光属性·7星怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c27036706.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
