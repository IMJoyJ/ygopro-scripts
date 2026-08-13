--迎撃準備
-- 效果：
-- 场上的1只表侧表示存在的战士族或魔法师族怪兽变成里侧守备表示。
function c31785398.initial_effect(c)
	-- 场上的1只表侧表示存在的战士族或魔法师族怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_PHASE,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_PHASE)
	e1:SetTarget(c31785398.target)
	e1:SetOperation(c31785398.activate)
	c:RegisterEffect(e1)
end
-- 筛选效果可选择的对象：怪兽须为表侧表示、可以转变为里侧守备表示，且种族为战士族或魔法师族。
function c31785398.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet() and c:IsRace(RACE_WARRIOR+RACE_SPELLCASTER)
end
-- 效果发动时的目标选择处理：确认对象为场上表侧表示且符合 filter 的怪兽；在发动时检查是否存在合法对象；存在则提示玩家选择1只对象，并将其注册为效果对象，同时设置操作信息为表示形式变更。
function c31785398.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c31785398.filter(chkc) end
	-- 若是在效果发动时点（chk==0），检查双方怪兽区域是否存在至少1只满足 filter 条件的表侧表示战士族或魔法师族怪兽，若没有则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c31785398.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向发动玩家弹出选择提示，提示内容为“请选择表侧表示的卡”，用于配合后续的选择操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己或对方的主要怪兽区域选择1只满足 filter 条件的表侧表示怪兽作为效果对象，并自动将其与本连锁建立关联（取对象）。
	local g=Duel.SelectTarget(tp,c31785398.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设定当前连锁的操作信息：将进行1张卡的表示形式变更（CATEGORY_POSITION），供后续处理及连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理时的操作：取得发动时选择的对象卡；若该卡仍与效果相关且仍为表侧表示，则将其变为里侧守备表示。
function c31785398.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中取得效果发动时选择的那张对象卡（本效果只选1张，因此取第一张）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将对象怪兽的表示形式变为里侧守备表示。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
