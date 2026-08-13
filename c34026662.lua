--進化の奇跡
-- 效果：
-- 选择名字带有「进化虫」的怪兽的效果特殊召唤的1只怪兽发动。这个回合，选择的怪兽不会被战斗以及卡的效果破坏。
function c34026662.initial_effect(c)
	-- 选择名字带有「进化虫」的怪兽的效果特殊召唤的1只怪兽发动。这个回合，选择的怪兽不会被战斗以及卡的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c34026662.target)
	e1:SetOperation(c34026662.activate)
	c:RegisterEffect(e1)
end
-- 筛选满足“由名字带有「进化虫」的怪兽的效果特殊召唤”的怪兽：要求表侧表示，且其特殊召唤信息符合进化虫相关条件（召唤类型为进化虫，或特殊召唤来源卡名包含进化虫系列字段）。
function c34026662.filter(c)
	local typ=c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)
	return c:IsFaceup() and c:IsSummonType(SUMMON_VALUE_EVOLTILE) or (typ&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x304e))
end
-- 效果发动时的取对象处理：确认选择对象位于主要怪兽区且满足filter；若发动时存在合法对象，则提示玩家选择1只符合条件且表侧表示的怪兽作为对象。
function c34026662.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c34026662.filter(chkc) end
	-- 在效果发动合法性检查阶段，确认场上存在至少1只满足筛选条件的表侧表示怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c34026662.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向当前玩家显示“请选择表侧表示的卡”的提示信息，用于引导选择怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己或对方场上选择1只满足filter的表侧表示怪兽作为效果对象，并将该对象与当前发动效果建立关联。
	local g=Duel.SelectTarget(tp,c34026662.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理阶段：取得被选择的对象怪兽，若其仍与该效果相关，则赋予其“不会被战斗破坏”和“不会被卡的效果破坏”的保护效果，持续到这个回合结束。
function c34026662.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，选择的怪兽不会被战斗破坏（与后续e2配合实现“不会被战斗以及卡的效果破坏”）。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end
