--魔轟神レヴュアタン
-- 效果：
-- 「魔轰神」调整＋调整以外的怪兽1只以上
-- ①：场上的这张卡被破坏送去墓地时，以自己墓地最多3只「魔轰神」怪兽为对象才能发动。那些怪兽加入手卡。
function c39477584.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整（且属于魔轰神）和1只以上调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x35),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：场上的这张卡被破坏送去墓地时，以自己墓地最多3只「魔轰神」怪兽为对象才能发动。那些怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39477584,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c39477584.con)
	e1:SetTarget(c39477584.tg)
	e1:SetOperation(c39477584.op)
	c:RegisterEffect(e1)
end
-- 效果发动条件：该卡因破坏而送去墓地且之前在场上
function c39477584.con(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_DESTROY)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤满足条件的「魔轰神」怪兽（必须是怪兽卡且能加入手牌）
function c39477584.filter(c)
	return c:IsSetCard(0x35) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果目标：选择自己墓地1~3只满足条件的「魔轰神」怪兽
function c39477584.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39477584.filter(chkc) end
	-- 检查阶段：确认场上是否存在满足条件的墓地怪兽
	if chk==0 then return Duel.IsExistingTarget(c39477584.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地怪兽作为效果对象，数量为1~3只
	local g=Duel.SelectTarget(tp,c39477584.filter,tp,LOCATION_GRAVE,0,1,3,nil)
	-- 设置效果处理信息：将选中的怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理函数：将符合条件的怪兽加入手牌并确认对方查看
function c39477584.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的效果对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将符合条件的怪兽以效果原因加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认查看加入手牌的怪兽
		Duel.ConfirmCards(1-tp,sg)
	end
end
