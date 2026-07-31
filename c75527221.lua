--朽ち果ての吐息
-- 效果：
-- 自己场上有不死族怪兽以及「活死人的呼声」存在的场合：以对方场上1只怪兽为对象；那只怪兽送去墓地。
-- 自己场上有不死族怪兽存在的场合：可以从自己墓地把这张卡除外，以自己以及对方场上的表侧表示卡各1张为对象；那些卡送去墓地。
-- 「腐朽之吐息」的效果1回合只能有1次使用其中任意1个。
local s,id,o=GetID()
-- 初始化卡片效果：注册①场上对象送墓效果、②墓地除外双场对象送墓效果
function s.initial_effect(c)
	-- 关联卡片密码：97077563（「活死人的呼声」）
	aux.AddCodeList(c,97077563)
	-- ①：自己场上有不死族怪兽以及「活死人的呼声」存在的场合，以对方场上1只怪兽为对象才能发动。那只怪兽送去墓地。
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
	-- ②：自己场上有不死族怪兽存在的场合，把墓地的这张卡除外，以自己以及对方场上的表侧表示卡各1张为对象才能发动。那些卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id)
	-- ②效果发动Cost：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(s.condition2)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- ①效果发动条件：自己场上有不死族怪兽以及「活死人的呼声」存在
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的卡
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
	return g:IsExists(Card.IsRace,1,nil,RACE_ZOMBIE) and g:IsExists(Card.IsCode,1,nil,97077563)
end
-- ①效果目标过滤条件：怪兽卡且可送去墓地
function s.tgfilter1(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ①效果发动准备：以对方场上1只怪兽为对象，设置送去墓地的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter1(chkc) end
	-- 检查对方场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter1,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方场上1只怪兽作为对象
	local g=Duel.SelectTarget(tp,s.tgfilter1,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：将选中的卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- ①效果处理：将对象怪兽送去墓地
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁发动的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将目标怪兽因效果送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- ②效果发动条件：自己场上有不死族怪兽存在
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	return g:IsExists(Card.IsRace,1,nil,RACE_ZOMBIE)
end
-- 过滤条件：表侧表示、可送去墓地且属于指定玩家
function s.tgfilter(c,tp)
	return c:IsFaceup() and c:IsAbleToGrave() and c:IsControler(tp)
end
-- 组合检查条件：检查选择的组合是否由双方场地各1张卡构成
function s.gcheck(g,tp)
	-- 检验卡片组合是否刚好包含己方和对方场地各1张满足条件的卡
	return aux.gffcheck(g,s.tgfilter,tp,s.tgfilter,1-tp)
end
-- ②效果发动准备：以自己及对方场上表侧表示卡各1张为对象，设置送去墓地的操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取双方场上所有可作为效果对象的表侧表示且可送去墓地的卡
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsAbleToGrave,Card.IsCanBeEffectTarget),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return g:CheckSubGroup(s.gcheck,2,2,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tg=g:SelectSubGroup(tp,s.gcheck,false,2,2,tp)
	-- 将选中的2张卡设为效果对象
	Duel.SetTargetCard(tg)
	-- 设置连锁操作信息：将选中的卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tg,tg:GetCount(),0,0)
end
-- ②效果处理：将选中的对象卡送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中依然有效的对象卡
	local tg=Duel.GetTargetsRelateToChain()
	if tg:GetCount()>0 then
		-- 将有效的对象卡因效果送去墓地
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end
