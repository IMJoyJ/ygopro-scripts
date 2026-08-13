--エクシーズ・リベンジ・シャッフル
-- 效果：
-- 自己场上的超量怪兽被选择作为攻击对象时，选择自己墓地1只超量怪兽才能发动。成为攻击对象的超量怪兽回到持有者的额外卡组。那之后，选择的怪兽从墓地特殊召唤，把这张卡在下面重叠作为超量素材。
function c31554054.initial_effect(c)
	-- 自己场上的超量怪兽被选择作为攻击对象时，选择自己墓地1只超量怪兽才能发动。成为攻击对象的超量怪兽回到持有者的额外卡组。那之后，选择的怪兽从墓地特殊召唤，把这张卡在下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOEXTRA)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(c31554054.condition)
	e1:SetTarget(c31554054.target)
	e1:SetOperation(c31554054.activate)
	c:RegisterEffect(e1)
end
-- 判断当前攻击对象是否存在，且是己方控制的表侧表示的超量怪兽，以此作为效果发动的条件。
function c31554054.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前被选择为攻击对象的怪兽。
	local at=Duel.GetAttackTarget()
	return at and at:IsFaceup() and at:IsControler(tp) and at:IsType(TYPE_XYZ)
end
-- 过滤己方墓地的超量怪兽，要求其可以被效果特殊召唤。
function c31554054.filter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标处理：先验证选择对象合法且发动条件满足；进行卡牌选择提示；从己方墓地选择1只超量怪兽作为效果对象；将攻击对象与效果建立联系；并设置返回额外卡组和特殊召唤的操作信息。
function c31554054.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31554054.filter(chkc,e,tp) end
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE)
		and e:GetHandler():IsCanOverlay()
		-- 确认攻击对象可以返回卡组，且己方主要怪兽区有空位可供特殊召唤使用。
		and Duel.GetAttackTarget():IsAbleToDeck() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认己方墓地存在至少1只符合条件且可被特殊召唤的超量怪兽可以选择。
		and Duel.IsExistingTarget(c31554054.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向己方玩家显示提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方墓地选择1只符合条件的超量怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c31554054.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将攻击对象与当前效果建立关联，便于后续处理时判断其是否仍与效果相关。
	Duel.GetAttackTarget():CreateEffectRelation(e)
	-- 设置操作信息：攻击对象将被返回持有者的额外卡组，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,Duel.GetAttackTarget(),1,0,0)
	-- 设置操作信息：选择的墓地超量怪兽将被特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理阶段：让攻击对象返回额外卡组并洗牌；中断效果后，特殊召唤之前选择的墓地超量怪兽；若此卡仍与效果相关，则取消其送墓确定状态并将其叠放在特殊召唤的怪兽下方作为超量素材。
function c31554054.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前攻击对象，用于后续处理。
	local at=Duel.GetAttackTarget()
	-- 确认攻击对象仍与效果关联、为表侧表示，且成功返回持有者卡组后，才继续后续特殊召唤处理。
	if at:IsRelateToEffect(e) and at:IsFaceup() and Duel.SendtoDeck(at,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		-- 中断当前效果链，使后续特殊召唤不视为与返回卡组同时处理，避免错过时点。
		Duel.BreakEffect()
		-- 获取发动时选择的墓地超量怪兽。
		local tc=Duel.GetFirstTarget()
		-- 确认所选怪兽仍与效果关联，且成功特殊召唤到场上，同时此卡自身仍与效果关联，才继续处理叠放。
		if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 and c:IsRelateToEffect(e) then
			c:CancelToGrave()
			-- 将这张魔法卡作为超量素材，叠放在特殊召唤的超量怪兽下面。
			Duel.Overlay(tc,Group.FromCards(c))
		end
	end
end
