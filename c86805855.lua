--闇魔界の竜騎士 ダークソード
-- 效果：
-- 「暗魔界的战士 暗黑之剑」＋「漆黑的斗龙」
-- 每次这张卡给与对方战斗伤害，可以选择对方的墓地的最多3张怪兽卡，从游戏中除外。
function c86805855.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，素材为「暗魔界的战士 暗黑之剑」和「漆黑的斗龙」
	aux.AddFusionProcCode2(c,11321183,47415292,true,true)
	-- 每次这张卡给与对方战斗伤害，可以选择对方的墓地的最多3张怪兽卡，从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86805855,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c86805855.rmcon)
	e1:SetTarget(c86805855.rmtg)
	e1:SetOperation(c86805855.rmop)
	c:RegisterEffect(e1)
end
-- 判定给与对方玩家战斗伤害作为效果发动条件
function c86805855.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤出可以被除外的怪兽卡
function c86805855.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 效果发动的靶向处理，检查并选择对方墓地中最多3张怪兽卡作为对象，并设置操作信息
function c86805855.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c86805855.filter(chkc) end
	-- 在效果发动阶段，检查对方墓地是否存在至少1张满足条件的怪兽卡
	if chk==0 then return Duel.IsExistingTarget(c86805855.filter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1到3张满足条件的怪兽卡作为效果对象
	local g=Duel.SelectTarget(tp,c86805855.filter,tp,0,LOCATION_GRAVE,1,3,nil)
	-- 设置当前连锁的操作信息，准备将所选的对象卡片除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),1-tp,LOCATION_GRAVE)
end
-- 效果处理，获取选中的对象卡片，并将仍存在且符合条件的卡片除外
function c86805855.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将选中的卡片以表侧表示因效果除外
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
