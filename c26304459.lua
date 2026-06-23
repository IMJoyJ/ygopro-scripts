--エンシェント・ゴッド・フレムベル
-- 效果：
-- 炎属性调整＋调整以外的炎族怪兽1只以上
-- 这张卡同调召唤成功时，选择最多有对方手卡数量的对方墓地存在的卡从游戏中除外。这张卡的攻击力上升这个效果除外的卡数量×200的数值。
function c26304459.initial_effect(c)
	-- 添加同调召唤手续，要求1只炎属性调整和1只以上炎族调整以外的怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE),aux.NonTuner(Card.IsRace,RACE_PYRO),1)
	c:EnableReviveLimit()
	-- 这张卡同调召唤成功时，选择最多有对方手卡数量的对方墓地存在的卡从游戏中除外。这张卡的攻击力上升这个效果除外的卡数量×200的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26304459,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c26304459.remcon)
	e1:SetTarget(c26304459.remtg)
	e1:SetOperation(c26304459.remop)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：此卡为同调召唤成功
function c26304459.remcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果的发动时点处理：设置将要除外的卡的类别信息
function c26304459.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为除外效果，目标为对方墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)
end
-- 效果处理时的主逻辑：获取对方手卡数量作为除外上限，提示选择除外的卡，选择并除外这些卡，然后根据除外卡数量提升自身攻击力
function c26304459.remop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡数量作为除外卡数量上限
	local ht=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	if ht==0 then return end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方墓地选择1到上限数量的卡进行除外
	local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,ht,nil)
	local c=e:GetHandler()
	if rg:GetCount()>0 then
		-- 将选中的卡从游戏中除外
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
		-- 这张卡的攻击力上升这个效果除外的卡数量×200的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(rg:GetCount()*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
