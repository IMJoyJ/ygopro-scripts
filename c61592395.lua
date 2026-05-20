--アルマの魔導書
-- 效果：
-- 选择「蜡板之魔导书」以外的从游戏中除外的1张自己的名字带有「魔导书」的魔法卡加入手卡。「蜡板之魔导书」在1回合只能发动1张。
function c61592395.initial_effect(c)
	-- 选择「蜡板之魔导书」以外的从游戏中除外的1张自己的名字带有「魔导书」的魔法卡加入手卡。「蜡板之魔导书」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,61592395+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c61592395.target)
	e1:SetOperation(c61592395.activate)
	c:RegisterEffect(e1)
end
-- 过滤除外区中除「蜡板之魔导书」以外的表侧表示的「魔导书」魔法卡，且该卡能加入手卡
function c61592395.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and not c:IsCode(61592395) and c:IsAbleToHand()
end
-- 效果发动的目标选择与操作信息注册
function c61592395.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c61592395.filter(chkc) end
	-- 在发动阶段，检查自己除外区是否存在至少1张满足条件的卡
	if chk==0 then return Duel.IsExistingTarget(c61592395.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向玩家发送提示信息，要求选择加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己除外区1张满足条件的卡作为效果的对象
	local g=Duel.SelectTarget(tp,c61592395.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果处理信息，表明此效果包含将选定卡片加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理的执行函数，将选中的对象卡片加入手牌并给对方确认
function c61592395.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
