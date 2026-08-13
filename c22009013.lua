--インヴェルズ・モース
-- 效果：
-- 把名字带有「侵入魔鬼」的怪兽解放对这张卡的上级召唤成功时，可以支付1000基本分，选择对方场上存在的最多2张卡回到持有者手卡。
function c22009013.initial_effect(c)
	-- 可以支付1000基本分，选择对方场上存在的最多2张卡回到持有者手卡。
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
	-- 把名字带有「侵入魔鬼」的怪兽解放对这张卡的上级召唤成功时。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c22009013.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 检查上级召唤素材中是否存在名字带有「侵入魔鬼」的怪兽，并将判定结果存入e1的Label（存在为1，不存在为0），供发动条件使用。
function c22009013.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0x100a) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 发动条件判定：这张卡必须是上级召唤成功，且e1的Label为1，即解放素材中含名字带有「侵入魔鬼」的怪兽。
function c22009013.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE) and e:GetLabel()==1
end
-- 发动代价：需要支付1000基本分（含检查与实际支付）。
function c22009013.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：在cost的chk==0阶段，确认当前玩家能够支付1000基本分，若能则效果可以发动。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 代价执行：实际扣除当前玩家1000基本分。
	Duel.PayLPCost(tp,1000)
end
-- 效果发动时的目标选择处理：确认对方场上有可回手卡的场合，提示玩家选择其中最多2张作为对象，并设置回手牌的操作信息。
function c22009013.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 目标存在性检查：确认对方场上至少存在1张能够加入手卡的卡（满足对象条件），否则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 弹出回手牌选择提示，将HINTMSG_RTOHAND写入选择消息缓存，使玩家选择卡时显示对应提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家从对方场上选择1~2张满足‘能够回手牌’的卡作为本效果的对象（取对象）。选中卡会自动与该连锁建立关联。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,2,nil)
	-- 设置操作信息：宣告本连锁将执行CATEGORY_TOHAND，目标组为g，数量为g:GetCount()，用于系统记录与后续效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：取得当前连锁中选择的对象卡，过滤出仍与本效果关联的卡，并将它们返回持有者手卡。
function c22009013.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象卡组，并筛选出仍与效果e相关联的卡（未被移除或重置关联）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将筛选后的卡送回持有者手卡；player参数为nil表示回到卡的原持有者手卡，原因是效果处理。
	Duel.SendtoHand(tg,nil,REASON_EFFECT)
end
