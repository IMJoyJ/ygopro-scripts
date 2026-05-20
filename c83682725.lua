--テールスイング
-- 效果：
-- 选择自己场上表侧表示存在的1只5星以上的恐龙族怪兽发动。选择对方场上存在的合计最多2只里侧表示怪兽或者比选择的恐龙族怪兽的等级低的怪兽回到持有者手卡。
function c83682725.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只5星以上的恐龙族怪兽发动。选择对方场上存在的合计最多2只里侧表示怪兽或者比选择的恐龙族怪兽的等级低的怪兽回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c83682725.target)
	e1:SetOperation(c83682725.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示、5星以上且存在可返回手牌的对方怪兽的恐龙族怪兽
function c83682725.filter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR) and c:IsLevelAbove(5)
		-- 检查对方场上是否存在至少1只里侧表示或等级低于该怪兽且能回到手牌的怪兽
		and Duel.IsExistingMatchingCard(c83682725.dfilter,tp,0,LOCATION_MZONE,1,nil,c:GetLevel())
end
-- 过滤对方场上里侧表示或等级低于指定等级，且能回到手牌的怪兽
function c83682725.dfilter(c,lv)
	return (c:IsFacedown() or c:IsLevelBelow(lv-1)) and c:IsAbleToHand()
end
-- 效果发动的目标选择，选择自己场上1只5星以上的恐龙族怪兽作为对象
function c83682725.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c83682725.filter(chkc,tp) end
	-- 在发动阶段检查自己场上是否存在符合条件的、可作为对象的5星以上恐龙族怪兽
	if chk==0 then return Duel.IsExistingTarget(c83682725.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择作为效果对象的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的5星以上恐龙族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c83682725.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 获取对方场上所有满足条件（里侧表示或等级低于所选怪兽）的怪兽组，用于后续操作信息设置
	local sg=Duel.GetMatchingGroup(c83682725.dfilter,tp,0,LOCATION_MZONE,nil,g:GetFirst():GetLevel())
	-- 设置效果处理信息，表示该效果包含将对方场上的怪兽送回手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
end
-- 效果处理，使对方场上最多2只满足条件的怪兽回到持有者手牌
function c83682725.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的作为对象的自己场上的恐龙族怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsRace(RACE_DINOSAUR) then
		-- 提示玩家选择要返回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 让玩家选择对方场上合计最多2只里侧表示或等级低于该恐龙族怪兽的怪兽
		local sg=Duel.SelectMatchingCard(tp,c83682725.dfilter,tp,0,LOCATION_MZONE,1,2,nil,tc:GetLevel())
		-- 将选择的对方怪兽送回持有者的手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
