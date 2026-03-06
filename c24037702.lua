--闇の進軍
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只「光道」怪兽为对象才能发动。那只怪兽加入手卡。那之后，把加入手卡的那只怪兽的原本等级数量的卡从自己卡组上面除外。
function c24037702.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,24037702+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c24037702.target)
	e1:SetOperation(c24037702.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断目标怪兽是否满足「光道」怪兽且等级大于0且能加入手牌，并且卡组顶部的卡数量足够除外。
function c24037702.filter(c,tp)
	if not c:IsType(TYPE_MONSTER) or not c:IsSetCard(0x38) or c:GetOriginalLevel()<=0 or not c:IsAbleToHand() then return false end
	-- 规则层面作用：获取玩家卡组顶部的指定数量的卡。
	local g=Duel.GetDecktopGroup(tp,c:GetOriginalLevel())
	return g:FilterCount(Card.IsAbleToRemove,nil)==c:GetOriginalLevel()
end
-- 效果原文内容：①：以自己墓地1只「光道」怪兽为对象才能发动。
function c24037702.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c24037702.filter(chkc,tp) end
	-- 规则层面作用：检查场上是否存在符合条件的目标怪兽。
	if chk==0 then return Duel.IsExistingTarget(c24037702.filter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 规则层面作用：向玩家发送提示信息，提示选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面作用：选择符合条件的墓地怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c24037702.filter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 规则层面作用：获取玩家卡组顶部的指定数量的卡。
	local rg=Duel.GetDecktopGroup(tp,g:GetFirst():GetOriginalLevel())
	-- 规则层面作用：设置效果处理时将目标怪兽加入手牌的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 规则层面作用：设置效果处理时将卡组顶部指定数量的卡除外的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,rg:GetCount(),0,0)
end
-- 效果原文内容：那只怪兽加入手卡。那之后，把加入手卡的那只怪兽的原本等级数量的卡从自己卡组上面除外。
function c24037702.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 规则层面作用：判断目标怪兽是否仍然存在于场上并成功加入手牌。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND) then
		-- 规则层面作用：中断当前效果，使后续处理视为不同时处理。
		Duel.BreakEffect()
		local ol=tc:GetOriginalLevel()
		-- 规则层面作用：获取玩家卡组顶部的指定数量的卡。
		local rg=Duel.GetDecktopGroup(tp,ol)
		-- 规则层面作用：禁止接下来的操作进行洗切卡组的检查。
		Duel.DisableShuffleCheck()
		-- 规则层面作用：将指定数量的卡从卡组顶部除外。
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
end
