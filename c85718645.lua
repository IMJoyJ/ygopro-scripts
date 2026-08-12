--闇帝ディルグ
-- 效果：
-- 这张卡召唤·特殊召唤成功时，可以把对方墓地存在的最多2张卡从游戏中除外。并且，再把除外数量的卡从对方卡组上面送去墓地。这张卡在召唤·特殊召唤的回合不能攻击。
function c85718645.initial_effect(c)
	-- 这张卡召唤·特殊召唤成功时，可以把对方墓地存在的最多2张卡从游戏中除外。并且，再把除外数量的卡从对方卡组上面送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85718645,0))  --"把对方墓地存在的最多2张卡从游戏中除外"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c85718645.target)
	e1:SetOperation(c85718645.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 这张卡在召唤·特殊召唤的回合不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetOperation(c85718645.disatt)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 效果发动的对象选择与可行性检查（选择对方墓地最多2张卡为对象）
function c85718645.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 在发动阶段，检查对方墓地是否存在至少1张可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1到2张可以除外的卡作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,2,nil)
	-- 设置连锁操作信息，表示该效果包含将对方墓地的这些卡除外的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),1-tp,LOCATION_GRAVE)
end
-- 效果处理阶段，将选择的对象卡片除外，并根据除外数量将对方卡组上方的卡送去墓地
function c85718645.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为对象的所有卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
	-- 将仍与效果相关的对象卡片表侧表示除外，并记录实际除外的卡片数量
	local count=Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	-- 若有卡片被成功除外，则将相同数量的卡片从对方卡组最上方送去墓地
	if count>0 then Duel.DiscardDeck(1-tp,count,REASON_EFFECT) end
end
-- 在召唤·特殊召唤成功时，为自身添加本回合不能攻击的效果
function c85718645.disatt(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡在召唤·特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
