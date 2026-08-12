--ドラゴン・アイス
-- 效果：
-- 对方对怪兽的特殊召唤成功时，可以把自己1张手卡丢弃，这张卡从手卡或者墓地特殊召唤。「龙冰」在场上只能有1张表侧表示存在。
function c64262809.initial_effect(c)
	c:SetUniqueOnField(1,1,64262809)
	-- 对方对怪兽的特殊召唤成功时，可以把自己1张手卡丢弃，这张卡从手卡或者墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64262809,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c64262809.spcon)
	e1:SetCost(c64262809.spcost)
	e1:SetTarget(c64262809.sptg)
	e1:SetOperation(c64262809.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选由对方玩家特殊召唤的怪兽
function c64262809.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp)
end
-- 发动条件：检查当前特殊召唤成功的怪兽中是否存在对方特殊召唤的怪兽
function c64262809.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c64262809.cfilter,1,nil,tp)
end
-- 发动代价：丢弃1张手卡（若自身在手卡且因其他效果无法送墓，则不能将自身作为代价丢弃）
function c64262809.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local exc=(c:IsLocation(LOCATION_HAND) and not c:IsAbleToGraveAsCost()) and c or nil
	-- 代价检查：检查手卡中是否存在除自身（若适用）以外可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,exc) end
	-- 执行代价：玩家选择并丢弃1张手卡
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,exc)
end
-- 效果目标：检查自身是否能特殊召唤以及怪兽区域是否有空位
function c64262809.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查：检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将特殊召唤自身（1张）注册为连锁处理的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若此卡仍在原本位置（或作为代价从手卡丢弃到墓地），则将此卡特殊召唤
function c64262809.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() or (c:IsLocation(LOCATION_GRAVE) and c:IsPreviousLocation(LOCATION_HAND) and c:GetReasonEffect()==e) then
		-- 执行特殊召唤：将此卡在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
