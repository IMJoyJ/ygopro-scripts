--ネオフレムベル・シャーマン
-- 效果：
-- 自己墓地有名字带有「炎狱」的怪兽3只以上存在，这张卡战斗破坏对方怪兽的场合，选择对方墓地存在的1张卡从游戏中除外。这个效果的发动时对方墓地没有魔法卡存在的场合，再给与对方基本分500分伤害。
function c39761138.initial_effect(c)
	-- 自己墓地有名字带有「炎狱」的怪兽3只以上存在，这张卡战斗破坏对方怪兽的场合，选择对方墓地存在的1张卡从游戏中除外。这个效果的发动时对方墓地没有魔法卡存在的场合，再给与对方基本分500分伤害。
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
-- 效果发动条件的判定：自身必须仍与本次战斗相关联、战斗对象为怪兽，且自己墓地存在3只以上名字带有「炎狱」的怪兽。
function c39761138.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:GetBattleTarget():IsType(TYPE_MONSTER)
		-- 检查自己墓地是否存在3只以上名字带有「炎狱」的怪兽，作为效果发动条件的一部分。
		and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE,0,3,nil,0x2c)
end
-- 效果发动时的目标处理：选择对方墓地1张可以除外的卡作为对象，并判断对方墓地是否有魔法卡，以决定是否追加伤害。
function c39761138.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	if chk==0 then return true end
	-- 给操作者弹出“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方墓地选择1张可以除外的卡作为本效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 将“除外选择的那张对象卡”写入当前连锁的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
	-- 检查对方墓地是否存在魔法卡；若存在，则将标签标记为0（表示不追加伤害）。
	if Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_GRAVE,1,nil,TYPE_SPELL) then e:SetLabel(0)
	else
		e:SetLabel(1)
		-- 设置连锁操作信息：将给与对方500点伤害的信息写入当前连锁。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
	end
end
-- 效果处理：再次确认自己墓地有3只以上「炎狱」怪兽后，将选中的对方墓地卡片除外；若之前判定对方墓地没有魔法卡，再给予对方500点伤害。
function c39761138.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理开始时再次检查自己墓地是否有3只以上名字带有「炎狱」的怪兽；若不满足则不进行后续处理。
	if not Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE,0,3,nil,0x2c) then return end
	-- 取得发动时选择的那张对方墓地卡片作为处理对象。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将选择的卡片以表侧表示除外（除外原因为效果）。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		if e:GetLabel()==1 then
			-- 中断当前效果处理，使追加伤害与前面除外处理作为不同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 给予对方玩家500点效果伤害。
			Duel.Damage(1-tp,500,REASON_EFFECT)
		end
	end
end
