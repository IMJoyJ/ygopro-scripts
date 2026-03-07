--ナイトエンド・ソーサラー
-- 效果：
-- ①：这张卡特殊召唤成功时，以对方墓地最多2张卡为对象才能发动。那些卡除外。
function c36107810.initial_effect(c)
	-- 效果原文内容：①：这张卡特殊召唤成功时，以对方墓地最多2张卡为对象才能发动。那些卡除外。
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
-- 效果作用：选择对方墓地1~2张可除外的卡作为对象
function c36107810.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 效果作用：检查对方墓地是否存在可除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 效果作用：向玩家提示“请选择要除外的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 效果作用：选择对方墓地1~2张可除外的卡
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,2,nil)
	-- 效果作用：设置连锁操作信息为除外效果
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),1-tp,LOCATION_GRAVE)
end
-- 效果作用：处理除外效果
function c36107810.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：筛选出与当前效果相关的对象卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()~=0 then
		-- 效果作用：以效果为原因，正面表示除外对象卡
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
