--ファーニマル・オクト
-- 效果：
-- 「毛绒动物·章鱼」的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功时，以自己墓地1只「毛绒动物」怪兽或者「锋利小鬼」怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：这张卡成为「魔玩具」融合怪兽的融合召唤的素材送去墓地的场合，以除外的最多2只自己怪兽为对象才能发动。那些怪兽回到墓地。
function c87246309.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功时，以自己墓地1只「毛绒动物」怪兽或者「锋利小鬼」怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87246309,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,87246309)
	e1:SetTarget(c87246309.target)
	e1:SetOperation(c87246309.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡成为「魔玩具」融合怪兽的融合召唤的素材送去墓地的场合，以除外的最多2只自己怪兽为对象才能发动。那些怪兽回到墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(87246309,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,87246310)
	e3:SetCondition(c87246309.tgcon)
	e3:SetTarget(c87246309.tgtg)
	e3:SetOperation(c87246309.tgop)
	c:RegisterEffect(e3)
end
-- 过滤自己墓地中属于「毛绒动物」或「锋利小鬼」字段且能加入手牌的怪兽
function c87246309.thfilter(c)
	return c:IsSetCard(0xa9,0xc3) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动准备（检查墓地目标、选择对象并设置操作信息）
function c87246309.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c87246309.thfilter(chkc) end
	-- 检查自己墓地是否存在至少1只符合条件的「毛绒动物」或「锋利小鬼」怪兽
	if chk==0 then return Duel.IsExistingTarget(c87246309.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c87246309.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息为“将选中的1张卡加入手牌”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果的处理（将选中的对象怪兽加入手牌）
function c87246309.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②效果的发动条件判定（作为「魔玩具」融合怪兽的融合素材送去墓地）
function c87246309.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_FUSION and c:GetReasonCard():IsSetCard(0xad)
end
-- 过滤除外区表侧表示的怪兽
function c87246309.tgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- ②效果的发动准备（检查除外区目标、选择最多2个对象并设置操作信息）
function c87246309.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c87246309.tgfilter(chkc) end
	-- 检查除外区是否存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c87246309.tgfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择除外区最多2只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c87246309.tgfilter,tp,LOCATION_REMOVED,0,1,2,nil)
	-- 设置当前连锁的操作信息为“将选中的怪兽送去墓地”
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- ②效果的处理（将选中的对象怪兽送回墓地）
function c87246309.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的所有卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将仍适用于效果的对象怪兽送回墓地
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_RETURN)
	end
end
