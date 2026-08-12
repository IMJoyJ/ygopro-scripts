--ネオフレムベル・シャーマン
-- 效果：
-- 自己墓地有名字带有「炎狱」的怪兽3只以上存在，这张卡战斗破坏对方怪兽的场合，选择对方墓地存在的1张卡从游戏中除外。这个效果的发动时对方墓地没有魔法卡存在的场合，再给与对方基本分500分伤害。
function c39761138.initial_effect(c)
	-- 创建一个诱发必发效果，用于处理战斗破坏对方怪兽时的除外效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39761138,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c39761138.rmcon)
	e1:SetTarget(c39761138.rmtg)
	e1:SetOperation(c39761138.rmop)
	c:RegisterEffect(e1)
end
-- 效果条件：自己场上存在名字带有「炎狱」的怪兽3只以上，且此卡参与了战斗并破坏了对方怪兽
function c39761138.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:GetBattleTarget():IsType(TYPE_MONSTER)
		-- 检查自己墓地是否存在至少3张名字带有「炎狱」的怪兽
		and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE,0,3,nil,0x2c)
end
-- 设置效果目标：选择对方墓地1张可除外的卡作为目标
function c39761138.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	if chk==0 then return true end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方墓地中选择1张可除外的卡作为目标
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息：将选择的卡设置为本次效果要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
	-- 检查对方墓地是否存在魔法卡，若存在则标签设为0，否则设为1
	if Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_GRAVE,1,nil,TYPE_SPELL) then e:SetLabel(0)
	else
		e:SetLabel(1)
		-- 设置操作信息：若对方墓地无魔法卡，则本次效果还会对对方造成500分伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
	end
end
-- 效果处理函数：执行除外和可能的伤害处理
function c39761138.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认自己墓地是否存在至少3张名字带有「炎狱」的怪兽
	if not Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE,0,3,nil,0x2c) then return end
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡从游戏中除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		if e:GetLabel()==1 then
			-- 中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 对对方造成500分伤害
			Duel.Damage(1-tp,500,REASON_EFFECT)
		end
	end
end
