--輝光帝ギャラクシオン
-- 效果：
-- 名字带有「光子」的4星怪兽×2
-- 1回合1次，把这张卡最多2个超量素材取除才能发动。为这个效果发动而取除的超量素材数量的以下效果适用。
-- ●1个：从手卡把1只「银河眼光子龙」特殊召唤。
-- ●2个：从卡组把1只「银河眼光子龙」特殊召唤。
function c40390147.initial_effect(c)
	-- 为这张卡添加超量召唤手续：超量召唤时需把2只等级4且名字带有「光子」字段的怪兽叠放作为超量素材。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x55),4,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡最多2个超量素材取除才能发动。为这个效果发动而取除的超量素材数量的以下效果适用。●1个：从手卡把1只「银河眼光子龙」特殊召唤。●2个：从卡组把1只「银河眼光子龙」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40390147,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c40390147.sptg)
	e1:SetOperation(c40390147.spop)
	c:RegisterEffect(e1)
end
-- 定义可特殊召唤对象的过滤条件：必须是「银河眼光子龙」（卡号93717133），且该卡能够被当前效果特殊召唤（满足召唤条件及苏生限制）。
function c40390147.spfilter(c,e,tp)
	return c:IsCode(93717133) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的代价/发动前判定：计算两个可选分支（取除1个素材从手牌特殊召唤、取除2个素材从卡组特殊召唤）是否可行；在chk==0时，要求主怪兽区有空位且至少有一个分支可行。
function c40390147.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查分支“取除1个素材从手卡特殊召唤”是否可行：手卡存在符合条件的「银河眼光子龙」，且本卡至少可以取除1个超量素材作为代价。
	local b1=Duel.IsExistingMatchingCard(c40390147.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
	-- 检查分支“取除2个素材从卡组特殊召唤”是否可行：卡组存在符合条件的「银河眼光子龙」，且本卡至少可以取除2个超量素材作为代价。
	local b2=Duel.IsExistingMatchingCard(c40390147.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST)
	-- 在发动条件确认时（chk==0），如果自己的主要怪兽区域没有空格，则无法发动；否则还需要至少一个可选分支成立。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and (b1 or b2) end
	local opt=0
	if b1 and b2 then
		-- 当两个分支都可用时，弹出选项让玩家选择取除1个素材（从手卡特殊召唤）还是取除2个素材（从卡组特殊召唤），opt记录选项序号。
		opt=Duel.SelectOption(tp,aux.Stringid(40390147,1),aux.Stringid(40390147,2))  --"从手卡把1只「银河眼光子龙」特殊召唤/从卡组把1只「银河眼光子龙」特殊召唤"
	elseif b1 then
		-- 当只有从手卡特殊召唤分支可用时，玩家只能选择取除1个素材的选项，opt为0。
		opt=Duel.SelectOption(tp,aux.Stringid(40390147,1))  --"从手卡把1只「银河眼光子龙」特殊召唤"
	else
		-- 当只有从卡组特殊召唤分支可用时，由于只有一个选项，Duel.SelectOption返回0，加1后opt为1，表示取除2个素材。
		opt=Duel.SelectOption(tp,aux.Stringid(40390147,2))+1  --"从卡组把1只「银河眼光子龙」特殊召唤"
	end
	e:SetLabel(opt)
	e:GetHandler():RemoveOverlayCard(tp,opt+1,opt+1,REASON_COST)
	if opt==0 then
		-- 将操作信息设置为“从手卡把1只怪兽特殊召唤”，位置为手卡，数量为1，供相关卡的效果检测（如星尘龙、王家长眠之谷）。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	else
		-- 将操作信息设置为“从卡组把1只怪兽特殊召唤”，位置为卡组，数量为1，供相关卡的效果检测。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	end
end
-- 效果处理：根据之前选择的标签，从手卡或卡组中选出符合条件的「银河眼光子龙」并特殊召唤到自己的主要怪兽区域；若主怪兽区无空位则不处理。
function c40390147.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理开始时再次确认主要怪兽区域有空位，否则无法特殊召唤，直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=nil
	if e:GetLabel()==0 then
		-- 从手卡中获取第一张满足spfilter条件的「银河眼光子龙」作为要特殊召唤的卡。
		tc=Duel.GetFirstMatchingCard(c40390147.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	else
		-- 从卡组中获取第一张满足spfilter条件的「银河眼光子龙」作为要特殊召唤的卡。
		tc=Duel.GetFirstMatchingCard(c40390147.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	end
	if tc then
		-- 将选中的「银河眼光子龙」以表侧表示特殊召唤到玩家tp的场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
