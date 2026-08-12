--エクシーズ・リベンジ・シャッフル
-- 效果：
-- 自己场上的超量怪兽被选择作为攻击对象时，选择自己墓地1只超量怪兽才能发动。成为攻击对象的超量怪兽回到持有者的额外卡组。那之后，选择的怪兽从墓地特殊召唤，把这张卡在下面重叠作为超量素材。
function c31554054.initial_effect(c)
	-- 创建效果，设置效果类别为特殊召唤和送入额外卡组，设置为取对象效果，类型为发动效果，触发时点为被选为攻击对象时，条件为c31554054.condition，目标为c31554054.target，发动效果为c31554054.activate
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
-- 当自己场上的超量怪兽被选为攻击对象时
function c31554054.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击对象怪兽
	local at=Duel.GetAttackTarget()
	return at and at:IsFaceup() and at:IsControler(tp) and at:IsType(TYPE_XYZ)
end
-- 过滤墓地中的超量怪兽，满足可以特殊召唤的条件
function c31554054.filter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标，判断是否满足发动条件，包括自身可以叠放、攻击对象可以送入卡组、自己场上存在空位、墓地存在满足条件的超量怪兽
function c31554054.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31554054.filter(chkc,e,tp) end
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE)
		and e:GetHandler():IsCanOverlay()
		-- 攻击对象可以送入卡组且自己场上存在空位
		and Duel.GetAttackTarget():IsAbleToDeck() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 墓地存在满足条件的超量怪兽
		and Duel.IsExistingTarget(c31554054.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地超量怪兽作为目标
	local g=Duel.SelectTarget(tp,c31554054.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将攻击对象怪兽与当前效果建立关系
	Duel.GetAttackTarget():CreateEffectRelation(e)
	-- 设置操作信息，将攻击对象怪兽送入额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,Duel.GetAttackTarget(),1,0,0)
	-- 设置操作信息，将选择的墓地怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 发动效果，将攻击对象怪兽送入卡组，然后将选择的墓地怪兽特殊召唤，并将自身叠放于该怪兽下方作为超量素材
function c31554054.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前攻击对象怪兽
	local at=Duel.GetAttackTarget()
	-- 攻击对象怪兽存在且正面表示，且成功将攻击对象怪兽送入卡组
	if at:IsRelateToEffect(e) and at:IsFaceup() and Duel.SendtoDeck(at,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		-- 中断当前效果处理，防止错时点
		Duel.BreakEffect()
		-- 获取当前效果的目标怪兽
		local tc=Duel.GetFirstTarget()
		-- 目标怪兽存在且成功特殊召唤，且自身存在
		if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 and c:IsRelateToEffect(e) then
			c:CancelToGrave()
			-- 将自身叠放于特殊召唤的怪兽下方作为超量素材
			Duel.Overlay(tc,Group.FromCards(c))
		end
	end
end
