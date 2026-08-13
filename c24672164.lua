--幻奏の華歌聖ブルーム・プリマ
-- 效果：
-- 「幻奏的音姬」怪兽＋「幻奏」怪兽1只以上
-- ①：这张卡的攻击力上升作为这张卡的融合素材的怪兽数量×300。
-- ②：这张卡在同1次的战斗阶段中可以作2次攻击。
-- ③：融合召唤的这张卡被送去墓地的场合，以自己墓地1只「幻奏」怪兽为对象才能发动。那只怪兽加入手卡。
function c24672164.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以1只「幻奏的音姬」怪兽作为指定素材，另加1只以上（代码上限127只）「幻奏」怪兽作为融合素材进行融合召唤。
	aux.AddFusionProcFunFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x109b),aux.FilterBoolFunction(Card.IsFusionSetCard,0x9b),1,127,true)
	-- 这张卡的攻击力上升作为这张卡的融合素材的怪兽数量×300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c24672164.matcheck)
	c:RegisterEffect(e2)
	-- 这张卡在同1次的战斗阶段中可以作2次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 融合召唤的这张卡被送去墓地的场合，以自己墓地1只「幻奏」怪兽为对象才能发动。那只怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(24672164,0))  --"加入手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCondition(c24672164.thcon)
	e4:SetTarget(c24672164.thtg)
	e4:SetOperation(c24672164.thop)
	c:RegisterEffect(e4)
end
-- 在融合召唤素材确定时，根据作为融合素材的怪兽数量，为这张卡赋予攻击力上升“素材数×300”的效果。
function c24672164.matcheck(e,c)
	local ct=c:GetMaterialCount()
	-- 这张卡的攻击力上升作为这张卡的融合素材的怪兽数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(ct*300)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- ③的发动条件：这张卡是融合召唤的怪兽，并且从场上（主要怪兽区/额外怪兽区）送去墓地。
function c24672164.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- ③的对象筛选条件：自己墓地中的「幻奏」怪兽，并且能够加入手卡。
function c24672164.filter(c)
	return c:IsSetCard(0x9b) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ③的发动与取对象处理：如果存在合法对象，则从自己墓地选择1只「幻奏」怪兽作为对象，并将本次操作信息设定为回手牌。
function c24672164.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c24672164.filter(chkc) end
	-- 发动合法性检查：确认自己墓地是否存在至少1只可作为对象的「幻奏」怪兽，没有则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c24672164.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家显示选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只符合条件的「幻奏」怪兽，并将其设置为这个效果的对象。
	local g=Duel.SelectTarget(tp,c24672164.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁的操作信息：本次效果分类为回手牌（CATEGORY_TOHAND），处理对象为已选择的目标卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ③的效果处理：把作为对象的「幻奏」怪兽加入持有者的手卡。
function c24672164.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这个效果发动时选择的对象卡（只有1张）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽加入其持有者的手卡，加入原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
