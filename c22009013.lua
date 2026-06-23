--インヴェルズ・モース
-- 效果：
-- 把名字带有「侵入魔鬼」的怪兽解放对这张卡的上级召唤成功时，可以支付1000基本分，选择对方场上存在的最多2张卡回到持有者手卡。
function c22009013.initial_effect(c)
	-- 创建一个诱发选发效果，用于上级召唤成功时的处理
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22009013,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c22009013.condition)
	e1:SetCost(c22009013.cost)
	e1:SetTarget(c22009013.target)
	e1:SetOperation(c22009013.operation)
	c:RegisterEffect(e1)
	-- 创建一个素材检查效果，用于判断是否包含「侵入魔鬼」怪兽作为召唤素材
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c22009013.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 检查当前卡片的召唤素材中是否包含名字带有「侵入魔鬼」的怪兽，若有则设置标签为1，否则为0
function c22009013.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0x100a) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判断当前卡片是否为上级召唤成功且满足条件（标签为1）
function c22009013.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE) and e:GetLabel()==1
end
-- 支付1000基本分作为效果的费用
function c22009013.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让玩家支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 选择对方场上存在的1~2张可送入手卡的卡片作为效果对象
function c22009013.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 确认场上是否存在可送入手卡的对方卡片
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要送入手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上存在的1~2张可送入手卡的卡片
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,2,nil)
	-- 设置效果处理时的操作信息，指定将卡片送入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 执行效果处理，将选定的卡片送入手卡
function c22009013.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选定的目标卡片，并筛选出与当前效果相关的卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将符合条件的卡片以效果原因送入手卡
	Duel.SendtoHand(tg,nil,REASON_EFFECT)
end
