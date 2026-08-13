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
-- 过滤条件：卡组中满足卡名含有「异虫」、种族为爬虫类族且能被送去墓地的怪兽。
function c11722335.tgfilter(c)
	return c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE) and c:IsAbleToGrave()
end
-- 效果发动合法性的判定与操作信息预设定：若发动时己方卡组存在符合条件的怪兽则可发动，并将本次效果处理信息设置为从卡组送去墓地1张卡。
function c11722335.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- check==0时检查己方卡组是否存在至少1张满足「异虫」爬虫类族且能送去墓地的卡，作为效果能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c11722335.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 预设定本次连锁的处理信息：效果分类为送去墓地，预计处理己方卡组1张卡。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的实际执行：由玩家从己方卡组选择1张符合条件的「异虫」爬虫类族怪兽，将其送去墓地。
function c11722335.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示选择提示，提示消息为“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从己方卡组选择1张满足「异虫」爬虫类族且能送去墓地的卡。
	local g=Duel.SelectMatchingCard(tp,c11722335.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 判断场上是否存在满足条件的「亚冈异虫」：该卡必须表侧表示且卡号为47111934。
function c11722335.indfilter(c)
	return c:IsFaceup() and c:IsCode(47111934)
end
-- 免疫战斗破坏的条件：己方场上有表侧表示的「亚冈异虫」存在。
function c11722335.indcon(e)
	-- 检索己方主要怪兽区是否存在至少1张表侧表示的「亚冈异虫」。
	return Duel.IsExistingMatchingCard(c11722335.indfilter,e:GetOwnerPlayer(),LOCATION_MZONE,0,1,nil)
end
