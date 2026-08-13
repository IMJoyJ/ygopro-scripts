--ドラグニティナイト－アスカロン
-- 效果：
-- 「龙骑兵团」调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：从自己墓地把1只「龙骑兵团」怪兽除外，以对方场上1只怪兽为对象才能发动。那只怪兽除外。
-- ②：同调召唤的这张卡被对方破坏的场合才能发动。从额外卡组把1只攻击力3000以下的「龙骑兵团」同调怪兽当作同调召唤作特殊召唤。
function c48891960.initial_effect(c)
	-- 为这张卡添加同调召唤手续（对应素材：『龙骑兵团』调整＋调整以外的怪兽1只以上）：以1只「龙骑兵团」调整为调整素材，加上1只以上调整以外的怪兽作为同调素材进行同调召唤。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x29),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：从自己墓地把1只「龙骑兵团」怪兽除外，以对方场上1只怪兽为对象才能发动。那只怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48891960,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c48891960.rmcost)
	e1:SetTarget(c48891960.rmtg)
	e1:SetOperation(c48891960.rmop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：同调召唤的这张卡被对方破坏的场合才能发动。从额外卡组把1只攻击力3000以下的「龙骑兵团」同调怪兽当作同调召唤作特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48891960,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,48891960)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c48891960.spcon)
	e2:SetTarget(c48891960.sptg)
	e2:SetOperation(c48891960.spop)
	c:RegisterEffect(e2)
end
-- 定义从墓地选择代价卡的过滤条件：卡名含有「龙骑兵团」字段的怪兽，并且可以作为代价除外。
function c48891960.cfilter(c)
	return c:IsSetCard(0x29) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- ①效果的发动代价处理：先检查自己墓地是否有可除外的「龙骑兵团」怪兽；若有则提示玩家选择1张，并将该卡表侧表示除外作为代价。
function c48891960.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价合法性检查（chk==0）时，确认自己墓地存在至少1张满足过滤条件的「龙骑兵团」怪兽，可供除外作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c48891960.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 发送选择提示消息，提示玩家选择要除外的卡（HINTMSG_REMOVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己墓地选择1只满足过滤条件的「龙骑兵团」怪兽作为除外代价。
	local g=Duel.SelectMatchingCard(tp,c48891960.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡表侧表示除外，除外原因记为代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的发动条件和取对象处理：确认对方场上存在可除外的怪兽后，选择对方场上1只怪兽作为对象，并设置将除外的操作信息。
function c48891960.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 在对象合法性检查时，确认对方场上存在至少1只可以被除外的怪兽（能够成为本效果的对象）。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 发送选择提示消息，提示玩家选择要除外的对象卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方场上选择1只可以被除外的怪兽作为效果对象（SelectTarget会将所选卡登记为当前连锁的对象）。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理的操作信息：本效果将把对象怪兽除外（CATEGORY_REMOVE），处理数量为1张。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ①效果的处理：获取发动时选择的对象怪兽，若该卡仍与效果保持关联（未离场或未被无效），则将其表侧表示除外。
function c48891960.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁登记的第一个对象卡（即①效果选择的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽表侧表示除外，除外原因为效果处理（REASON_EFFECT）。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 定义②效果可特殊召唤的怪兽过滤函数：从额外卡组选择1只攻击力3000以下的「龙骑兵团」同调怪兽，且该怪兽可以进行同调召唤，并确保自己有可用的额外怪兽区域空格。
function c48891960.spfilter(c,e,tp)
	return c:IsSetCard(0x29) and c:IsAttackBelow(3000) and c:IsType(TYPE_SYNCHRO)
		-- 追加过滤条件：该额外卡组怪兽能够被当作同调召唤特殊召唤（IsCanBeSpecialSummoned），并且自己场上拥有足够空间让额外怪兽出场（GetLocationCountFromEx>0）。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ②效果的发动条件：这张卡是以同调召唤方式出场后，被对方（rp==1-tp）破坏，且破坏时该卡在我方怪兽区域，才满足发动条件。
function c48891960.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- ②效果的发动目标与合法性检查：确认不存在『必须作为同调素材』的限制效果，并且额外卡组中存在符合特殊召唤条件的「龙骑兵团」同调怪兽；最后设置特殊召唤的操作信息。
function c48891960.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查时，确认当前玩家没有受到『必须作为同调素材』相关效果的限制（若存在则不能正常发动②效果）。
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 并确认额外卡组存在至少1只满足spfilter过滤条件的「龙骑兵团」同调怪兽可供特殊召唤。
		and Duel.IsExistingMatchingCard(c48891960.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息：效果处理时从额外卡组特殊召唤1只符合条件的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理：再次检查不存在『必须作为同调素材』限制后，从额外卡组选择1只符合条件的「龙骑兵团」同调怪兽，将其当作同调召唤特殊召唤，并完成同调召唤手续（CompleteProcedure）。
function c48891960.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查『必须作为同调素材』限制，若检查未通过（存在限制）则中止特殊召唤处理。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 发送选择提示消息，提示玩家选择要特殊召唤的怪兽（HINTMSG_SPSUMMON）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足过滤条件的「龙骑兵团」同调怪兽，并取得这一张卡作为特殊召唤对象。
	local tc=Duel.SelectMatchingCard(tp,c48891960.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 以同调召唤的方式将选中的怪兽特殊召唤到我方场上（表侧表示）；若召唤成功（返回值>0），则继续执行CompleteProcedure完成特殊召唤手续。
		if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	end
end
