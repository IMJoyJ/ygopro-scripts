--ライトロード・サモナー ルミナス
-- 效果：
-- ①：1回合1次，丢弃1张手卡，以自己墓地1只4星以下的「光道」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：自己结束阶段发动。从自己卡组上面把3张卡送去墓地。
function c95503687.initial_effect(c)
	-- ①：1回合1次，丢弃1张手卡，以自己墓地1只4星以下的「光道」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95503687,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c95503687.spcost)
	e1:SetTarget(c95503687.sptg)
	e1:SetOperation(c95503687.spop)
	c:RegisterEffect(e1)
	-- ②：自己结束阶段发动。从自己卡组上面把3张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetDescription(aux.Stringid(95503687,1))  --"从卡组送3张卡去墓地"
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c95503687.discon)
	e2:SetTarget(c95503687.distg)
	e2:SetOperation(c95503687.disop)
	c:RegisterEffect(e2)
end
-- 效果①的Cost（发动代价）函数：丢弃1张手卡
function c95503687.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张可以丢弃的卡（排除自身）
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：自己墓地4星以下的「光道」怪兽，且可以特殊召唤
function c95503687.filter(c,e,tp)
	return c:IsSetCard(0x38) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的Target（发动条件与对象选择）函数
function c95503687.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c95503687.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己墓地是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingTarget(c95503687.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c95503687.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示该效果包含特殊召唤所选怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的Operation（效果处理）函数
function c95503687.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的Condition（发动条件）函数
function c95503687.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己的回合
	return tp==Duel.GetTurnPlayer()
end
-- 效果②的Target（发动准备）函数
function c95503687.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息，表示该效果包含从卡组送去墓地的操作（3张卡）
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
-- 效果②的Operation（效果处理）函数
function c95503687.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己卡组上面把3张卡送去墓地
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
end
