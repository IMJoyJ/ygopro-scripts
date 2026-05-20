--ゴゴゴゴラム
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，这张卡的表示形式变更。场上的这张卡被破坏送去墓地时，从卡组把1只名字带有「隆隆隆」的怪兽送去墓地。
function c59911557.initial_effect(c)
	-- 这张卡召唤·反转召唤·特殊召唤成功时，这张卡的表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59911557,0))  --"改变表示形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c59911557.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 场上的这张卡被破坏送去墓地时，从卡组把1只名字带有「隆隆隆」的怪兽送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(59911557,1))  --"送墓"
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c59911557.tgcon)
	e4:SetTarget(c59911557.tgtg)
	e4:SetOperation(c59911557.tgop)
	c:RegisterEffect(e4)
end
-- 召唤·反转召唤·特殊召唤成功时变更表示形式的效果处理
function c59911557.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将这张卡在表侧攻击表示和表侧守备表示之间进行变更
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
-- 判断这张卡是否是在场上被破坏并送去墓地
function c59911557.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组中可以送去墓地的「隆隆隆」怪兽
function c59911557.tgfilter(c)
	return c:IsSetCard(0x59) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 从卡组把「隆隆隆」怪兽送墓效果的发动准备
function c59911557.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理信息为从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 从卡组把「隆隆隆」怪兽送墓效果的实际处理
function c59911557.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足条件的「隆隆隆」怪兽
	local g=Duel.SelectMatchingCard(tp,c59911557.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
