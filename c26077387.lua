--閃刀姫－レイ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，把这张卡解放才能发动。从额外卡组把1只「闪刀姬」怪兽在额外怪兽区域特殊召唤。
-- ②：这张卡在墓地存在的状态，自己场上的「闪刀姬」连接怪兽因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。这张卡特殊召唤。
function c26077387.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己·对方回合，把这张卡解放才能发动。从额外卡组把1只「闪刀姬」怪兽在额外怪兽区域特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26077387,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,26077387)
	e1:SetCost(c26077387.spcost1)
	e1:SetTarget(c26077387.sptg1)
	e1:SetOperation(c26077387.spop1)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡在墓地存在的状态，自己场上的「闪刀姬」连接怪兽因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26077387,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,26077388)
	e2:SetCondition(c26077387.spcon2)
	e2:SetTarget(c26077387.sptg2)
	e2:SetOperation(c26077387.spop2)
	c:RegisterEffect(e2)
end
-- 发动①的代价处理：先确认这张卡是否可以被解放；若可以，则以解放自身作为发动代价。
function c26077387.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡解放并送入墓地，解放原因记为COST，即作为发动效果所需支付的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选额外卡组中可作为特召对象的「闪刀姬」怪兽：必须满足字段「闪刀姬」、能够被特殊召唤，并且在这张零衣被解放后仍有额外怪兽区域空位可供其特殊召唤。
function c26077387.spfilter1(c,e,tp,ec)
	return c:IsSetCard(0x1115) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 计算这张零衣被解放离场后，额外怪兽区域（0x60）是否存在可用的空格，从而保证选择的「闪刀姬」怪兽能够被特殊召唤到额外怪兽区域。
		and Duel.GetLocationCountFromEx(tp,tp,ec,c,0x60)>0
end
-- ①的发动目标/条件判定：检查额外卡组是否存在至少1只满足spfilter1条件的「闪刀姬」怪兽；若满足，则将本次处理登记为特殊召唤操作。
function c26077387.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定阶段（chk==0）：从自己的额外卡组中确认是否存在至少1只可被特殊召唤的「闪刀姬」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c26077387.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 登记操作信息：本次效果将把1只来自额外卡组的怪兽特殊召唤；目标数量为1，目标位置为额外卡组，供后续时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①的效果处理：让玩家从额外卡组选择1只符合条件的「闪刀姬」怪兽，将其以表侧表示特殊召唤到额外怪兽区域。
function c26077387.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家进行选择，显示“请选择要特殊召唤的卡”的选择框。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己的额外卡组中选出1张满足spfilter1条件的「闪刀姬」怪兽。
	local g=Duel.SelectMatchingCard(tp,c26077387.spfilter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,e:GetHandler())
	if g:GetCount()>0 then
		-- 将选中的「闪刀姬」怪兽以表侧表示特殊召唤到自己的额外怪兽区域（0x60）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,0x60)
	end
end
-- 用于判定“自己场上的「闪刀姬」连接怪兽离场”：该怪兽离场前必须是表侧表示、控制者为这张零衣的持有者、是连接怪兽、持有「闪刀姬」字段，并且离场原因是由对方玩家的效果造成，或是在战斗中被破坏。
function c26077387.cfilter(c,tp,rp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and bit.band(c:GetPreviousTypeOnField(),TYPE_LINK)~=0
		and c:IsPreviousSetCard(0x1115) and (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT)))
end
-- ②的发动条件：本次离场怪兽中存在满足cfilter条件的「闪刀姬」连接怪兽，并且这些离场怪兽中不包含墓地的这张零衣自身，即不是零衣自己离场触发。
function c26077387.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c26077387.cfilter,1,nil,tp,rp) and not eg:IsContains(e:GetHandler())
end
-- ②的发动目标/条件判定：确认自己的主要怪兽区域有空位，且墓地的这张零衣本身可以被特殊召唤；满足后登记特殊召唤操作。
function c26077387.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定阶段：检查自己场上主要怪兽区域是否有空位，用于特殊召唤墓地中的这张零衣。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：本次效果将把这张零衣从墓地特殊召唤；操作信息中明确目标为这张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②的效果处理：若墓地的这张零衣仍与效果保持关联（没有因处理前离开发动区域等原因失联），则将其特殊召唤。
function c26077387.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将墓地的这张零衣以表侧表示特殊召唤到自己场上，不检查召唤条件与苏生限制，直接进行特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
