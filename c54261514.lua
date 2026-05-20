--超獸の咆哮
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只怪兽和对方场上1张卡为对象才能发动。那些卡破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只怪兽和对方场上1张卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义用于筛选自己场上可破坏怪兽的过滤函数
function s.desfilter(c,tp,ec)
	-- 判定卡片是否为怪兽，且对方场上是否存在至少1张可作为对象的卡（排除自身和本卡）
	return c:IsType(TYPE_MONSTER) and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,Group.FromCards(c,ec))
end
-- 定义效果发动时的对象选择与操作信息设置函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	-- 在发动检查阶段，判定自己场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,0,1,nil,tp,c) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只满足条件的怪兽作为对象
	local g1=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,c)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为对象（排除已选择的自己怪兽和本卡）
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,Group.FromCards(g1:GetFirst(),c))
	g1:Merge(g2)
	-- 设置破坏2张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 定义效果处理的执行函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象且仍与效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 因效果破坏这些卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
