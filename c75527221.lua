--朽ち果ての吐息
-- 效果：
-- 自己场上有不死族怪兽以及「活死人的呼声」存在的场合：以对方场上1只怪兽为对象；那只怪兽送去墓地。
-- 自己场上有不死族怪兽存在的场合：可以从自己墓地把这张卡除外，以自己以及对方场上的表侧表示卡各1张为对象；那些卡送去墓地。
-- 「腐朽之吐息」的效果1回合只能有1次使用其中任意1个。
local s,id,o=GetID()
-- 注册效果（初始化卡片）
function s.initial_effect(c)
	-- 记录该卡片效果中记载了「活死人的呼声」
	aux.AddCodeList(c,97077563)
	-- 自己场上有不死族怪兽以及「活死人的呼声」存在的场合：以对方场上1只怪兽为对象；那只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 自己场上有不死族怪兽存在的场合：可以从自己墓地把这张卡除外，以自己以及对方场上的表侧表示卡各1张为对象；那些卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id)
	-- 可以从自己墓地把这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(s.condition2)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 检查自己场上是否有不死族怪兽以及「活死人的呼声」
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的卡
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
	return g:IsExists(Card.IsRace,1,nil,RACE_ZOMBIE) and g:IsExists(Card.IsCode,1,nil,97077563)
end
-- 检查卡片是否是怪兽且可以送去墓地
function s.tgfilter1(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 检查对方场上是否有可以送去墓地的怪兽并选定作为效果对象，设定送去墓地的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter1(chkc) end
	-- 检查对方场上是否至少存在1只可以送去墓地的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter1,tp,0,LOCATION_MZONE,1,nil) end
	-- 发送选择要送去墓地的卡片的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 以对方场上1只怪兽为对象
	local g=Duel.SelectTarget(tp,s.tgfilter1,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：预计将选定的怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 将选定的对方怪兽送去墓地
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 那只怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- 检查自己场上是否有不死族怪兽
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的卡
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	return g:IsExists(Card.IsRace,1,nil,RACE_ZOMBIE)
end
-- 检查卡片是否在指定玩家场上表侧表示存在且可以送去墓地
function s.tgfilter(c,tp)
	return c:IsFaceup() and c:IsAbleToGrave() and c:IsControler(tp)
end
-- 检查选定的2张卡是否满足一张在自己场上，另一张在对方场上
function s.gcheck(g,tp)
	-- 检查选定的2张卡是否满足一张在自己场上，另一张在对方场上
	return aux.gffcheck(g,s.tgfilter,tp,s.tgfilter,1-tp)
end
-- 检查自己和对方场上是否都有可以送去墓地的表侧表示卡并选定作为对象，设定送去墓地的操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取双方场上所有表侧表示且可以成为对象和送去墓地的卡
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsAbleToGrave,Card.IsCanBeEffectTarget),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return g:CheckSubGroup(s.gcheck,2,2,tp) end
	-- 发送选择要送去墓地的卡片的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tg=g:SelectSubGroup(tp,s.gcheck,false,2,2,tp)
	-- 把选定的两张卡设置成对象
	Duel.SetTargetCard(tg)
	-- 设置操作信息：预计将这2张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tg,tg:GetCount(),0,0)
end
-- 将选定的双方卡片送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被作为对象且还在场上的卡片
	local tg=Duel.GetTargetsRelateToChain()
	if tg:GetCount()>0 then
		-- 那些卡送去墓地
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end
