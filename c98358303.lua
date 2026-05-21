--静寂のサイコウィッチ
-- 效果：
-- ①：场上的这张卡被破坏送去墓地时才能发动。从卡组把1只攻击力2000以下的念动力族怪兽除外。
-- ②：这张卡的①的效果把怪兽除外的场合，下次的准备阶段在墓地发动。那只除外状态的怪兽特殊召唤。
function c98358303.initial_effect(c)
	-- ①：场上的这张卡被破坏送去墓地时才能发动。从卡组把1只攻击力2000以下的念动力族怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98358303,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c98358303.rmcon)
	e1:SetTarget(c98358303.rmtg)
	e1:SetOperation(c98358303.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果把怪兽除外的场合，下次的准备阶段在墓地发动。那只除外状态的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(98358303,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c98358303.spcon)
	e2:SetTarget(c98358303.sptg)
	e2:SetOperation(c98358303.spop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 检查发动条件：场上的这张卡被破坏并送去墓地
function c98358303.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：攻击力2000以下且可以除外的念动力族怪兽
function c98358303.filter(c)
	return c:IsAttackBelow(2000) and c:IsRace(RACE_PSYCHO) and c:IsAbleToRemove()
end
-- 效果①的发动准备：检查卡组中是否存在符合条件的怪兽，并设置除外操作信息
function c98358303.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c98358303.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理：从卡组将1只符合条件的怪兽除外，并为自身和该怪兽注册Flag标记以建立关联
function c98358303.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从卡组选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c98358303.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	if tc then
		-- 因效果将选择的怪兽表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		if c:IsRelateToEffect(e) then
			c:RegisterFlagEffect(98358303,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
			tc:RegisterFlagEffect(98358303,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
			e:SetLabelObject(tc)
		end
	end
end
-- 检查效果②的发动条件：确认被除外的怪兽存在、不是在当前回合除外，且双方的Flag标记均有效
function c98358303.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject():GetLabelObject()
	local c=e:GetHandler()
	-- 确认被除外的怪兽存在，且当前回合不是该怪兽被除外的回合（即“下次的准备阶段”）
	return tc and Duel.GetTurnCount()~=tc:GetTurnID()
		and c:GetFlagEffect(98358303)~=0 and tc:GetFlagEffect(98358303)~=0
end
-- 效果②的发动准备：检查被除外的怪兽是否可以特殊召唤，建立效果联系并设置特殊召唤操作信息
function c98358303.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject():GetLabelObject()
	if chk==0 then return tc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	tc:CreateEffectRelation(e)
	-- 设置操作信息：将该除外的怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
-- 效果②的处理：如果该怪兽与效果仍有关联，则将其特殊召唤
function c98358303.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject():GetLabelObject()
	if tc:IsRelateToEffect(e) then
		-- 将该怪兽以表侧表示特殊召唤到自身场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
