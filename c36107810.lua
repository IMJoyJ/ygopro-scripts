--ナイトエンド・ソーサラー
-- 效果：
-- ①：这张卡特殊召唤成功时，以对方墓地最多2张卡为对象才能发动。那些卡除外。
function c36107810.initial_effect(c)
	-- ①：这张卡特殊召唤成功时，以对方墓地最多2张卡为对象才能发动。那些卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36107810,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c36107810.rmtg)
	e1:SetOperation(c36107810.rmop)
	c:RegisterEffect(e1)
end
-- 该效果发动时的目标选择处理：从对方墓地选择1~2张可以除外的卡作为对象，并设置本次连锁的除外操作信息。
function c36107810.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 发动合法性检查：确认对方墓地是否存在至少1张可以被除外的卡，以判断效果能否发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向当前玩家显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让当前玩家从对方墓地选择1~2张可以被除外的卡作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,2,nil)
	-- 将本次连锁的操作信息设置为“除外”，记录对象卡组、数量、持有者及所在区域，供后续效果处理与连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),1-tp,LOCATION_GRAVE)
end
-- 效果处理时的执行操作：取得本连锁的对象卡，过滤出仍与该效果相关的卡，然后将其除外。
function c36107810.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁信息中取出效果对象，并筛选出仍与这张卡效果相关的对象（对象仍然存在于墓地且未被无效或脱离关系）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()~=0 then
		-- 将筛选出的对象卡以表侧表示从墓地除外。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
