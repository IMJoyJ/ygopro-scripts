--エンペラー・ストゥム
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，自己对怪兽的上级召唤成功时，双方玩家可以选择各自墓地存在的1张卡回到卡组最上面。
function c21672573.initial_effect(c)
	-- 只要这张卡在自己场上表侧表示存在，自己对怪兽的上级召唤成功时，双方玩家可以选择各自墓地存在的1张卡回到卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21672573,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c21672573.tdcon1)
	e1:SetTarget(c21672573.tdtg)
	e1:SetOperation(c21672573.tdop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_MSET)
	e2:SetCondition(c21672573.tdcon2)
	c:RegisterEffect(e2)
end
-- 当前连锁触发的怪兽不是这张卡自身，且是这张卡的控制者成功进行的表侧上级召唤（召唤类型为上级召唤），才满足发动条件。
function c21672573.tdcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst()~=e:GetHandler() and ep==tp
		and eg:GetFirst():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 当前连锁触发的怪兽是以解放素材进行的里侧上级召唤（放置怪兽），且召唤者是这张卡的控制者，才满足发动条件（用素材数非0排除无解放的普通放置）。
function c21672573.tdcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():GetMaterialCount()~=0 and ep==tp
end
-- 效果发动时的目标选择：选择自己墓地1张可返回卡组的卡为对象；若对方墓地也有可返回卡组的卡，则询问对方是否选择，对方同意后再选择对方墓地1张卡，并与自己选择的卡合并为对象组。
function c21672573.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 效果发动条件检查：自己墓地存在至少1张可以被返回卡组的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给自己显示“请选择要返回卡组的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 作为发动方，从自己的墓地选择1张可返回卡组的卡，并将其设为效果对象。
	local g1=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 检查对方墓地是否存在至少1张可返回卡组的卡（以决定是否给对方选择机会）。
	if Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil)
		-- 若对方墓地存在可返回卡组的卡，则询问对方玩家是否要选择墓地1张卡回到卡组最上面；对方选“是”才继续。
		and Duel.SelectYesNo(1-tp,aux.Stringid(21672573,1)) then  --"是否要选择墓地一张卡回到卡组最上面？"
		-- 给对方显示“请选择要返回卡组的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 作为对方玩家，从对方自己的墓地选择1张可返回卡组的卡，并将其加入效果对象组。
		local g2=Duel.SelectTarget(1-tp,Card.IsAbleToDeck,1-tp,LOCATION_GRAVE,0,1,1,nil)
		g1:Merge(g2)
	end
	-- 设置操作信息：本次效果将把对象组g1中的卡返回卡组，数量为g1的卡数，用于后续判定。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,g1:GetCount(),0,0)
end
-- 效果处理：若这张卡仍存在于场上且与效果关联（未被无效/离场），则把仍与效果关联的所有对象卡返回持有者卡组最上面；若本卡已不在场上或里侧表示，则不处理。
function c21672573.tdop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	-- 取得连锁中记录的对象卡组，并筛选出仍然与效果有联系的卡（未离场、未被无效等）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将筛选出的卡以效果原因送回各自持有者卡组的最顶端。
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
end
