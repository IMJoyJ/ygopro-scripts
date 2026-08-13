--冥界流傀儡術
-- 效果：
-- 选择自己墓地的1只恶魔族怪兽。在自己场上选择合计等级和选择的那只怪兽的等级相同的怪兽从游戏中除外。之后，选择的那只怪兽特殊召唤。
function c40703393.initial_effect(c)
	-- 选择自己墓地的1只恶魔族怪兽。在自己场上选择合计等级和选择的那只怪兽的等级相同的怪兽从游戏中除外。之后，选择的那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c40703393.target)
	e1:SetOperation(c40703393.activate)
	c:RegisterEffect(e1)
end
-- 判定墓地1只恶魔族怪兽能否作为特殊召唤对象：等级大于0、种族为恶魔、满足特殊召唤条件，且自己场上存在合计等级与其等级相同的表侧怪兽子集可用于除外。
function c40703393.spfilter(c,e,tp,ft,rg)
	local lv=c:GetLevel()
	return lv>0 and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and rg:CheckWithSumEqual(Card.GetLevel,lv,ft,99)
end
-- 判定场上怪兽是否可作为除外的候选：需要表侧表示、等级大于0、且能被除外。
function c40703393.rmfilter(c)
	return c:GetLevel()>0 and c:IsAbleToRemove() and c:IsFaceup()
end
-- 效果发动时的目标处理：先拒绝非取对象调用；计算可用怪兽区空位数；在合法性检查阶段确认墓地存在符合条件的恶魔族怪兽；随后选择1只墓地恶魔族怪兽作为对象，并设置特殊召唤的操作信息。
function c40703393.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己主要怪兽区的可用空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then ft=-ft+1 else ft=1 end
	if chk==0 then
		-- 获取自己场上表侧表示且等级大于0、能除外的怪兽集合，作为可选的除外候选。
		local rg=Duel.GetMatchingGroup(c40703393.rmfilter,tp,LOCATION_MZONE,0,nil)
		-- 检查墓地是否存在1只满足spfilter条件的恶魔族怪兽可作为效果对象。
		return Duel.IsExistingTarget(c40703393.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,ft,rg)
	end
	-- 再次获取自己场上可被除外的表侧表示怪兽集合，用于后续选择除外怪兽时使用。
	local rg=Duel.GetMatchingGroup(c40703393.rmfilter,tp,LOCATION_MZONE,0,nil)
	-- 向玩家显示选择要特殊召唤的卡片的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地的恶魔族怪兽中选择1只作为效果对象，且该怪兽必须满足spfilter条件。
	local g=Duel.SelectTarget(tp,c40703393.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,ft,rg)
	-- 设置本次效果处理的特殊召唤操作信息，声明将特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理阶段：获取对象卡并检查其是否仍与效果相关且可特殊召唤；重新取得可除外怪兽组；若场上存在等级合计等于对象等级的怪兽子集，则选择并除外它们，然后中断效果处理，再将对象特殊召唤。
function c40703393.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的墓地怪兽对象。
	local tc=Duel.GetFirstTarget()
	-- 获取自己主要怪兽区的可用空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then ft=-ft+1 else ft=1 end
	if not tc:IsRelateToEffect(e) or not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	-- 获取自己场上表侧表示且等级大于0、能除外的怪兽集合。
	local rg=Duel.GetMatchingGroup(c40703393.rmfilter,tp,LOCATION_MZONE,0,nil)
	local lv=tc:GetLevel()
	if rg:CheckWithSumEqual(Card.GetLevel,lv,ft,99) then
		-- 向玩家显示选择要除外的卡片的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local rm=rg:SelectWithSumEqual(tp,Card.GetLevel,lv,ft,99)
		-- 将选择的怪兽以表侧表示从游戏中除外。
		Duel.Remove(rm,POS_FACEUP,REASON_EFFECT)
		-- 中断当前效果处理，使除外和特殊召唤不在同一时点处理，防止错失时点。
		Duel.BreakEffect()
		-- 将选择的对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
