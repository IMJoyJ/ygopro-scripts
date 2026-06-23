--ワーム・ゼクス
-- 效果：
-- 这张卡召唤成功时，可以从自己卡组把1只名字带有「异虫」的爬虫类族怪兽送去墓地。自己场上有「亚冈异虫」表侧表示存在的场合，这张卡不会被战斗破坏。
function c11722335.initial_effect(c)
	-- 这张卡召唤成功时，可以从自己卡组把1只名字带有「异虫」的爬虫类族怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11722335,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c11722335.target)
	e1:SetOperation(c11722335.operation)
	c:RegisterEffect(e1)
	-- 自己场上有「亚冈异虫」表侧表示存在的场合，这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(c11722335.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检索满足条件的卡：名字带有「异虫」且属于爬虫类族且可以送去墓地
function c11722335.tgfilter(c)
	return c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE) and c:IsAbleToGrave()
end
-- 效果处理时的处理目标函数，用于判断是否可以发动此效果
function c11722335.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在自己卡组中是否存在至少1张满足tgfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c11722335.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要处理1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的处理函数，用于执行效果内容
function c11722335.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 从自己卡组选择1张满足tgfilter条件的卡
	local g=Duel.SelectMatchingCard(tp,c11722335.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤函数，用于检索场上的「亚冈异虫」
function c11722335.indfilter(c)
	return c:IsFaceup() and c:IsCode(47111934)
end
-- 判断是否满足效果发动条件的函数
function c11722335.indcon(e)
	-- 检查自己场上是否存在至少1张「亚冈异虫」
	return Duel.IsExistingMatchingCard(c11722335.indfilter,e:GetOwnerPlayer(),LOCATION_MZONE,0,1,nil)
end
