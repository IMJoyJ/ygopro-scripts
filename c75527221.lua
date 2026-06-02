--Deadly Zombie Breath
-- 效果：
-- 自己场上有不死族怪兽以及「活死人的呼声」存在的场合：以对方场上1只怪兽为对象；那只怪兽送去墓地。
-- 自己场上有不死族怪兽存在的场合：可以从自己墓地把这张卡除外，以自己以及对方场上的表侧表示卡各1张为对象；那些卡送去墓地。
-- 「腐朽之吐息」的效果1回合只能有1次使用其中任意1个。
local s,id,o=GetID()
-- 初始化卡片效果：记录相关联的卡名「活死人的呼声」、注册卡片发动时的对方怪兽送墓效果、以及在墓地除外自身将双方场上表侧卡送墓的即时效果
function s.initial_effect(c)
	-- 将「活死人的呼声」（卡号：97077563）加入卡片关联代码列表中
	aux.AddCodeList(c,97077563)
	-- 自己场上有不死族怪兽以及「活死人的呼声」存在的场合：以对方场上1只怪兽为对象；那只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
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
	-- 效果②的发动代价：从自己墓地将此卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(s.condition2)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 效果①发动的条件判定：自己场上同时存在表侧表示的不死族怪兽与「活死人的呼声」
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有的表侧表示卡片
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
	return g:IsExists(Card.IsRace,1,nil,RACE_ZOMBIE) and g:IsExists(Card.IsCode,1,nil,97077563)
end
-- 过滤条件：可以送去墓地的怪兽卡
function s.tgfilter1(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果①发动的可行性检查、取对象处理及送去墓地操作信息注册
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter1(chkc) end
	-- 可行性检查：对方场上是否存在至少1只可送去墓地的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter1,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方场上1只可送去墓地的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.tgfilter1,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置送去墓地操作信息：将选中的怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果①的实际处理逻辑
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将对象怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- 效果②发动的条件判定：自己场上存在表侧表示的不死族怪兽
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有的表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	return g:IsExists(Card.IsRace,1,nil,RACE_ZOMBIE)
end
-- 过滤条件：属于指定玩家控制的、表侧表示且可以送去墓地的卡片
function s.tgfilter(c,tp)
	return c:IsFaceup() and c:IsAbleToGrave() and c:IsControler(tp)
end
-- 双卡组合资格检查：分别属于自己与对方控制
function s.gcheck(g,tp)
	-- 判断所选的一组卡中是否恰好包含我方和对方场上各一张满足条件的卡
	return aux.gffcheck(g,s.tgfilter,tp,s.tgfilter,1-tp)
end
-- 效果②发动的可行性检查、取对象处理及送去墓地操作信息注册
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取双方场上所有可以作为效果对象的表侧表示且可送去墓地的卡片
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsAbleToGrave,Card.IsCanBeEffectTarget),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return g:CheckSubGroup(s.gcheck,2,2,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tg=g:SelectSubGroup(tp,s.gcheck,false,2,2,tp)
	-- 将选中的两张卡片注册为当前效果的对象
	Duel.SetTargetCard(tg)
	-- 设置送去墓地操作信息：将选中的卡片送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tg,tg:GetCount(),0,0)
end
-- 效果②的实际处理逻辑
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②中注册的所有合法对象卡片
	local tg=Duel.GetTargetsRelateToChain()
	if tg:GetCount()>0 then
		-- 将选中的卡片送去墓地
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end
