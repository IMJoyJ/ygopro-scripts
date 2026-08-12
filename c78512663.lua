--E・HERO マグマ・ネオス
-- 效果：
-- 「元素英雄 新宇侠」＋「新空间侠·火焰甲虫」＋「新空间侠·大地鼹鼠」
-- 把自己场上存在的上记的卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。这张卡的攻击力上升场上的卡的数量×400的数值。结束阶段时这张卡回到额外卡组。这个效果回到额外卡组时，场上存在的全部卡回到持有者手卡。
function c78512663.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为「元素英雄 新宇侠」、「新空间侠·火焰甲虫」和「新空间侠·大地鼹鼠」
	aux.AddFusionProcCode3(c,89943723,89621922,80344569,false,false)
	-- 添加接触融合的特殊召唤规则，要求将自己场上的素材卡回到卡组
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- 把自己场上存在的上记的卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c78512663.splimit)
	c:RegisterEffect(e1)
	-- 注册新宇侠系列怪兽共通的结束阶段返回额外卡组效果
	local e3,e4=aux.EnableNeosReturn(c,c78512663.retop)
	-- 这张卡的攻击力上升场上的卡的数量×400的数值。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(c78512663.atkval)
	c:RegisterEffect(e5)
	-- 这个效果回到额外卡组时，场上存在的全部卡回到持有者手卡。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(78512663,1))  --"返回手牌"
	e6:SetCategory(CATEGORY_TOHAND)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_TO_DECK)
	e6:SetCondition(c78512663.thcon)
	e6:SetTarget(c78512663.thtg)
	e6:SetOperation(c78512663.thop)
	c:RegisterEffect(e6)
	e3:SetLabelObject(e6)
	e4:SetLabelObject(e6)
end
c78512663.material_setcode=0x8
-- 限制该卡从额外卡组特殊召唤只能通过其自身召唤手续进行
function c78512663.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 计算攻击力上升值的函数
function c78512663.atkval(e,c)
	-- 返回双方场上的卡片总数乘以400的数值
	return Duel.GetFieldGroupCount(0,LOCATION_ONFIELD,LOCATION_ONFIELD)*400
end
-- 结束阶段将自身送回额外卡组的操作函数
function c78512663.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 通过效果将自身送回额外卡组并洗牌
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 判定是否是由自身结束阶段返回额外卡组的效果触发
function c78512663.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetLabelObject()==e
end
-- 场上全部卡片回到手卡效果的发动准备与目标确认
function c78512663.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上所有可以回到手卡的卡片
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置效果处理信息为将场上的卡片送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 场上全部卡片回到手卡效果的执行函数
function c78512663.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前双方场上所有可以回到手卡的卡片
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将场上的这些卡片全部送回持有者手卡
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
