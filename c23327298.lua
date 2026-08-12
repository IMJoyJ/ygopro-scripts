--パラレル・セレクト
-- 效果：
-- 自己场上存在的同调怪兽被对方破坏送去墓地时，选择从游戏中除外的1张自己的魔法卡发动。选择的魔法卡加入手卡。
function c23327298.initial_effect(c)
	-- 效果设置：将效果分类设为回手牌，属性设为取对象且可在伤害步骤发动，类型为发动效果，触发事件为送去墓地时
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c23327298.condition)
	e1:SetTarget(c23327298.target)
	e1:SetOperation(c23327298.operation)
	c:RegisterEffect(e1)
end
-- 条件过滤函数：检查怪兽是否为同调怪兽、之前在场上、正面表示、控制者为自己、之前控制者为自己、破坏来源为自己对手
function c23327298.cfilter(c,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsControler(tp) and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 发动条件判断：确认是否有满足条件的怪兽被破坏送入墓地
function c23327298.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c23327298.cfilter,1,nil,tp)
end
-- 目标过滤函数：检查魔法卡是否正面表示、为魔法卡类型、能加入手牌
function c23327298.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果处理目标设定：选择一张自己除外区的魔法卡作为效果对象
function c23327298.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c23327298.filter(chkc) end
	-- 检查是否满足发动条件：确认场上是否存在满足条件的魔法卡
	if chk==0 then return Duel.IsExistingTarget(c23327298.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示选择：向玩家发送提示信息“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标：从除外区选择一张满足条件的魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c23327298.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息：将本次效果操作的分类设为回手牌，目标为选中的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理函数：将选中的魔法卡加入手牌并确认对方能看到该卡
function c23327298.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标卡：获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡送入手牌：以效果原因将目标卡送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 确认对方能看到该卡：向对方玩家展示该卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
