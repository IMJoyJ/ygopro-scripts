--EMショーダウン
-- 效果：
-- ①：以最多有自己场上的表侧表示的魔法卡数量的对方场上的表侧表示怪兽为对象才能发动。那些怪兽变成里侧守备表示。
function c92958307.initial_effect(c)
	-- ①：以最多有自己场上的表侧表示的魔法卡数量的对方场上的表侧表示怪兽为对象才能发动。那些怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(TIMING_BATTLE_PHASE,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_PHASE)
	e1:SetTarget(c92958307.target)
	e1:SetOperation(c92958307.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：自己场上表侧表示的魔法卡
function c92958307.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
-- 过滤函数：对方场上表侧表示且可以变成里侧表示的怪兽
function c92958307.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果①的发动准备（检查是否满足发动条件、选择对象并设置操作信息）
function c92958307.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上表侧表示的魔法卡数量
	local sc=Duel.GetMatchingGroupCount(c92958307.cfilter,tp,LOCATION_ONFIELD,0,nil)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c92958307.filter(chkc) end
	-- 发动条件判定：自己场上必须有表侧表示的魔法卡，且对方场上存在至少1只可以变成里侧表示的表侧怪兽
	if chk==0 then return sc>0 and Duel.IsExistingTarget(c92958307.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择最多等同于自己场上表侧表示魔法卡数量的对方场上的表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c92958307.filter,tp,0,LOCATION_MZONE,1,sc,nil)
	-- 设置操作信息：表示形式变更，对象为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果①的效果处理（将作为对象的怪兽变成里侧守备表示）
function c92958307.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍与此效果关联的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将目标怪兽变成里侧守备表示
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
