--ブリリアント・ローズ
-- 效果：
-- 这个卡名在规则上也当作「宝石骑士」卡使用。这个卡名的①的效果1回合只能使用1次。
-- ①：从手卡丢弃1张其他的「宝石骑士」卡或「幻奏」卡才能发动。这张卡从手卡特殊召唤。
-- ②：1回合1次，从额外卡组把1只「宝石骑士」怪兽或「幻奏」怪兽送去墓地才能发动。这张卡的卡名·种族·属性直到结束阶段变成和为这个效果发动而送去墓地的怪兽的原本的卡名·种族·属性相同。
function c61011438.initial_effect(c)
	-- ①：从手卡丢弃1张其他的「宝石骑士」卡或「幻奏」卡才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,61011438)
	e1:SetCost(c61011438.spcost)
	e1:SetTarget(c61011438.sptg)
	e1:SetOperation(c61011438.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，从额外卡组把1只「宝石骑士」怪兽或「幻奏」怪兽送去墓地才能发动。这张卡的卡名·种族·属性直到结束阶段变成和为这个效果发动而送去墓地的怪兽的原本的卡名·种族·属性相同。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c61011438.cpcost)
	e2:SetOperation(c61011438.cpop)
	c:RegisterEffect(e2)
end
-- 过滤函数，筛选手卡中可以丢弃的「宝石骑士」或「幻奏」卡片
function c61011438.cfilter(c)
	return c:IsSetCard(0x1047,0x9b) and c:IsDiscardable()
end
-- 效果①的COST，检查并从手卡丢弃1张其他的「宝石骑士」卡或「幻奏」卡
function c61011438.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认手卡中是否存在除这张卡以外的「宝石骑士」或「幻奏」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c61011438.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家选择并丢弃1张手卡中除这张卡以外的「宝石骑士」或「幻奏」卡作为发动代价
	Duel.DiscardHand(tp,c61011438.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 效果①的Target，检查怪兽区域是否有空位以及自身是否可以特殊召唤
function c61011438.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息，声明此效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的Operation，若此卡仍存在于手卡，则将其在自己场上表侧表示特殊召唤
function c61011438.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到发动效果的玩家场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，筛选额外卡组中可以送去墓地的「宝石骑士」或「幻奏」怪兽
function c61011438.cpfilter(c)
	return c:IsSetCard(0x1047,0x9b) and c:IsAbleToGraveAsCost()
end
-- 效果②的COST，从额外卡组选择1只「宝石骑士」或「幻奏」怪兽送去墓地，并记录该怪兽
function c61011438.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认额外卡组中是否存在可以送去墓地的「宝石骑士」或「幻奏」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c61011438.cpfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 向玩家发送提示信息，要求选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从额外卡组选择1张符合条件的「宝石骑士」或「幻奏」怪兽
	local g=Duel.SelectMatchingCard(tp,c61011438.cpfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选中的怪兽送去墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabelObject(tc)
end
-- 效果②的Operation，将此卡的卡名、种族、属性直到结束阶段变成与作为代价送去墓地的怪兽的原本数据相同
function c61011438.cpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsFaceup() and c:IsRelateToEffect(e)) then return end
	local tc=e:GetLabelObject()
	local code=tc:GetOriginalCodeRule()
	-- 这张卡的卡名……直到结束阶段变成和为这个效果发动而送去墓地的怪兽的原本的卡名……相同。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(code)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetValue(tc:GetOriginalRace())
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e3:SetValue(tc:GetOriginalAttribute())
	c:RegisterEffect(e3)
end
