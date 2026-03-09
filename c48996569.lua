--E・HERO グラン・ネオス
-- 效果：
-- 「元素英雄 新宇侠」＋「新空间侠·大地鼹鼠」
-- 让自己场上的上记的卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」魔法卡）。1回合1次，可以选择对方场上1只怪兽回到持有者手卡。此外，结束阶段时，这张卡回到额外卡组。
function c48996569.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为89943723和80344569的两只怪兽作为融合素材
	aux.AddFusionProcCode2(c,89943723,80344569,false,false)
	-- 添加接触融合特殊召唤规则，要求自己场上的符合条件的卡回到卡组作为召唤条件
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- 设置该卡不能从额外卡组特殊召唤（即必须通过接触融合方式特殊召唤）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c48996569.splimit)
	c:RegisterEffect(e1)
	-- 注册结束阶段返回卡组效果，使该卡在结束阶段回到额外卡组
	aux.EnableNeosReturn(c,c48996569.retop)
	-- 1回合1次，可以选择对方场上1只怪兽回到持有者手卡
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(48996569,1))  --"返回手牌"
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetTarget(c48996569.thtg)
	e5:SetOperation(c48996569.thop)
	c:RegisterEffect(e5)
end
c48996569.material_setcode=0x8
-- 限制该卡不能从额外卡组特殊召唤，必须通过接触融合方式特殊召唤
function c48996569.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 结束阶段时，若该卡存在且为表侧表示，则将其送回卡组
function c48996569.retop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	-- 将该卡送回卡组并洗牌
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 定义返回手牌的过滤函数，判断目标怪兽是否可以回到手牌
function c48996569.filter(c)
	return c:IsAbleToHand()
end
-- 设置效果目标选择函数，选择对方场上一只可回到手牌的怪兽
function c48996569.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c48996569.filter(chkc) end
	-- 检查是否有符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c48996569.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要送回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上一只可回到手牌的怪兽作为目标
	local g=Duel.SelectTarget(tp,c48996569.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，指定将目标怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 设置效果处理函数，将选中的怪兽送回手牌
function c48996569.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
