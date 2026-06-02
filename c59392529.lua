--E・HERO リキッドマン
function c59392529.initial_effect(c)
	-- ①：这张卡召唤成功时，以「E・HERO リキッドマン」以外的自己墓地1只4星以下的「HERO」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59392529,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,59392529)
	e1:SetTarget(c59392529.target)
	e1:SetOperation(c59392529.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡作为「HERO」融合怪兽的融合召唤的素材送去墓地的场合或者被除外的场合才能发动。自己从卡组抽2张，那之后选1张手卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59392529,1))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,59392529)
	e2:SetCondition(c59392529.drcon)
	e2:SetTarget(c59392529.drtg)
	e2:SetOperation(c59392529.drop)
	c:RegisterEffect(e2)
end
-- 过滤条件：等级4以下、卡名含有「HERO」、且非「E・HERO リキッドマン」的可以特殊召唤的怪兽
function c59392529.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x8) and not c:IsCode(59392529) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①号效果的发动准备与目标选择
function c59392529.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c59392529.spfilter(chkc,e,tp) end
	-- 检查自身怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合特殊召唤条件的怪兽
		and Duel.IsExistingTarget(c59392529.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c59392529.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，包含特殊召唤分类和选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①号效果的处理：将选中的怪兽特殊召唤
function c59392529.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②号效果的发动条件：此卡在墓地或除外状态，且作为「HERO」融合怪兽的融合素材
function c59392529.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and r==REASON_FUSION and c:GetReasonCard():IsSetCard(0x8) and not c:IsReason(REASON_RETURN)
end
-- ②号效果的发动准备：检查是否能抽卡，并设置抽卡和丢弃手牌的连锁信息
function c59392529.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以从卡组抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置效果影响的玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置效果参数为2（抽2张卡）
	Duel.SetTargetParam(2)
	-- 设置连锁信息，包含抽2张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	-- 设置连锁信息，包含丢弃1张手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- ②号效果的处理：抽2张卡，然后丢弃1张手牌
function c59392529.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 尝试让目标玩家因效果抽2张卡，若成功抽到2张则继续处理
	if Duel.Draw(p,d,REASON_EFFECT)==2 then
		-- 洗切该玩家的手牌
		Duel.ShuffleHand(p)
		-- 中断当前效果处理，使后续的丢弃手牌处理不与抽卡同时进行
		Duel.BreakEffect()
		-- 让该玩家选择并因效果丢弃1张手牌
		Duel.DiscardHand(p,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
