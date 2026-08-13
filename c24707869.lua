--ブライト・フューチャー
-- 效果：
-- 选择从游戏中除外的2只自己的念动力族怪兽发动。选择的怪兽回到墓地，从自己卡组抽1张卡。
function c24707869.initial_effect(c)
	-- 选择从游戏中除外的2只自己的念动力族怪兽发动。选择的怪兽回到墓地，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c24707869.target)
	e1:SetOperation(c24707869.activate)
	c:RegisterEffect(e1)
end
-- 定义可选对象的筛选条件：必须是表侧表示且种族为念动力族的卡。
function c24707869.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO)
end
-- 效果发动时的合法性检查与取对象处理：需要满足能抽卡且除外区存在至少2只符合条件的自己念动力族怪兽，并选择2只作为效果对象。
function c24707869.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c24707869.filter(chkc) end
	-- 检查发动玩家是否能够抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查除外区是否存在至少2只符合条件的自己念动力族怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c24707869.filter,tp,LOCATION_REMOVED,0,2,nil) end
	-- 给发动玩家显示选择提示，提示内容是“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己除外区选择2只满足条件的念动力族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c24707869.filter,tp,LOCATION_REMOVED,0,2,2,nil)
	-- 设置操作信息，表明此效果后续会进行抽卡操作：由tp玩家抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理时：取得仍然与效果关联的对象卡，若数量不足2则效果不处理；否则将对象卡送去墓地，然后抽1张卡。
function c24707869.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象卡，并筛选出仍然与效果相关的卡（排除已经离场或失效的卡）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()~=2 then return end
	-- 将筛选出的对象卡送去墓地，送去墓地的原因为效果处理并返回墓地。
	Duel.SendtoGrave(tg,REASON_EFFECT+REASON_RETURN)
	-- 发动玩家tp因效果抽1张卡。
	Duel.Draw(tp,1,REASON_EFFECT)
end
