--竜魔人 クィーンドラグーン
-- 效果：
-- 4星怪兽×2
-- 只要这张卡在场上表侧表示存在，「龙魔人 龙骑士女王」以外的自己的龙族怪兽不会被战斗破坏。此外，1回合1次，可以把这张卡1个超量素材取除，选择自己墓地1只5星以上的龙族怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，这个回合那只怪兽不能攻击。
function c90726340.initial_effect(c)
	-- 设置XYZ召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 只要这张卡在场上表侧表示存在，「龙魔人 龙骑士女王」以外的自己的龙族怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTarget(c90726340.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，可以把这张卡1个超量素材取除，选择自己墓地1只5星以上的龙族怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，这个回合那只怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90726340,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c90726340.spcost)
	e2:SetTarget(c90726340.sptg)
	e2:SetOperation(c90726340.spop)
	c:RegisterEffect(e2)
end
-- 过滤战斗破坏抗性的适用对象：自己场上「龙魔人 龙骑士女王」以外的龙族怪兽
function c90726340.indtg(e,c)
	return c:IsRace(RACE_DRAGON) and not c:IsCode(90726340)
end
-- 效果发动代价：取除这张卡的1个超量素材
function c90726340.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤特殊召唤的目标：自己墓地5星以上的龙族怪兽
function c90726340.spfilter(c,e,tp)
	-- 过滤条件：等级在5星以上、龙族、且能被特殊召唤
	return c:IsLevelAbove(5) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,aux.DragonXyzSpSummonType(c))
end
-- 效果发动准备：检查怪兽区域空位、是否存在合法目标，并选择目标
function c90726340.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c90726340.spfilter(chkc,e,tp) end
	-- 检查发动条件：自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查发动条件：自己墓地是否存在满足条件的龙族怪兽
		and Duel.IsExistingTarget(c90726340.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的龙族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c90726340.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：特殊召唤所选的1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：特殊召唤目标怪兽，并使其效果无效化、本回合不能攻击
function c90726340.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽仍符合条件，并尝试将其以表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) and Duel.SpecialSummonStep(tc,0,tp,tp,false,aux.DragonXyzSpSummonType(tc),POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		-- 这个回合那只怪兽不能攻击。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3,true)
		-- 检查被特殊召唤的怪兽是否为特定的超量怪兽（用于判定是否需要完成正规出场程序）
		if aux.DragonXyzSpSummonType(tc) then
			tc:CompleteProcedure()
		end
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
