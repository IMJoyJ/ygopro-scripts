--雲魔物－ストーム・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。把自己墓地1只名字带有「云魔物」的怪兽从游戏中除外特殊召唤。这张卡不会被战斗破坏。这张卡表侧守备示在场上存在的场合，这张卡破坏。1回合只有1次，可以给场上1只怪兽放置1个雾指示物。
function c13474291.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不会被战斗破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这张卡表侧守备示在场上存在的场合，这张卡破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c13474291.sdcon)
	c:RegisterEffect(e2)
	-- 把自己墓地1只名字带有「云魔物」的怪兽从游戏中除外特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c13474291.spcon)
	e3:SetTarget(c13474291.sptg)
	e3:SetOperation(c13474291.spop)
	c:RegisterEffect(e3)
	-- 1回合只有1次，可以给场上1只怪兽放置1个雾指示物
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(13474291,0))  --"放置指示物"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c13474291.cttg)
	e4:SetOperation(c13474291.ctop)
	c:RegisterEffect(e4)
end
c13474291.mentioned_counter={
	[0x1019]=true,
}
-- 判断当前卡片是否处于表侧守备表示
function c13474291.sdcon(e)
	return e:GetHandler():IsPosition(POS_FACEUP_DEFENSE)
end
-- 过滤满足条件的墓地云魔物怪兽（可除外作为特殊召唤cost）
function c13474291.cfilter(c)
	return c:IsSetCard(0x18) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 判断是否满足特殊召唤条件（场上有空位且墓地有云魔物怪兽）
function c13474291.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上主怪兽区是否有可用空间
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家墓地是否存在至少1只名字带有「云魔物」的怪兽
		and Duel.IsExistingMatchingCard(c13474291.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 选择并标记要除外的墓地云魔物怪兽
function c13474291.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的墓地云魔物怪兽组
	local g=Duel.GetMatchingGroup(c13474291.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行将选中的卡从游戏中除外的操作
function c13474291.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标卡片从游戏中除外（特殊召唤原因）
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 设置指示物效果的目标选择逻辑
function c13474291.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanAddCounter(0x1019,1) end
	-- 检查场上是否存在可放置指示物的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0x1019,1) end
	-- 提示玩家选择要放置指示物的表侧表示怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上一只可放置指示物的表侧表示怪兽
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,0x1019,1)
end
-- 执行放置雾指示物的操作
function c13474291.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x1019,1)
	end
end
