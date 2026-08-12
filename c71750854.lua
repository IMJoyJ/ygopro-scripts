--ボンバー・プレイス
-- 效果：
-- ①：自己·对方回合，可以支付600基本分，从以下选择1个发动（同一连锁上最多1次）。
-- ●自己场上有1～6星的怪兽全部存在的场合才能发动。选对方场上1只表侧表示怪兽，等级·阶级·连接的数值和那个等级相同的除选的怪兽以外的对方场上的怪兽全部破坏。
-- ●选自己场上1只表侧表示怪兽，等级·阶级·连接的数值和那个等级相同的位于选的怪兽的正对面的对方怪兽全部破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：自己·对方回合，可以支付600基本分，从以下选择1个发动（同一连锁上最多1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"选对方怪兽"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
-- 效果发动Cost：检查并支付600基本分
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付600基本分
	if chk==0 then return Duel.CheckLPCost(tp,600) end
	-- 扣除玩家600基本分
	Duel.PayLPCost(tp,600)
end
-- 检查自己场上是否全部存在1～6星的怪兽
function s.descon1(tp)
	-- 获取自己场上所有表侧表示且等级在6以下的怪兽
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsLevelBelow),tp,LOCATION_MZONE,0,nil,6)
	local lvc=0
	-- 遍历这些怪兽，用二进制位记录它们各自的等级
	for tc in aux.Next(g) do
		lvc=lvc|(1<<(tc:GetLevel()-1))
	end
	return lvc==0x3f
end
-- 效果1的过滤条件：对方场上表侧表示、有等级，且存在其他等级/阶级/连接数值与该等级相同的怪兽
function s.tgfilter1(c,tp)
	return c:IsFaceup() and c:IsLevelAbove(1)
		-- 检查对方场上是否存在除该怪兽以外，等级/阶级/连接数值与该怪兽等级相同的怪兽
		and Duel.IsExistingMatchingCard(s.desfilter1,tp,0,LOCATION_MZONE,1,c,c:GetLevel())
end
-- 效果1的破坏目标过滤条件：表侧表示，且等级、阶级或连接数值与指定数值相同
function s.desfilter1(c,lv)
	return c:IsFaceup() and (c:IsLevel(lv) or c:IsRank(lv) or c:IsLink(lv))
end
-- 效果2的过滤条件：自己场上表侧表示、有等级，且其正对面存在等级/阶级/连接数值与该等级相同的对方怪兽
function s.tgfilter2(c,tp)
	return c:IsFaceup() and c:IsLevelAbove(1)
		and c:GetColumnGroup():FilterCount(s.desfilter2,nil,tp,c:GetLevel())>0
end
-- 效果2的破坏目标过滤条件：对方场上表侧表示的怪兽，且等级、阶级或连接数值与指定数值相同
function s.desfilter2(c,tp,lv)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsControler(1-tp) and (c:IsLevel(lv) or c:IsRank(lv) or c:IsLink(lv))
end
-- 效果发动时的Target处理：检查可发动的效果分支，让玩家选择其中一个发动，并设置破坏的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足效果1的发动条件（自己场上有1~6星怪兽全部存在，且对方场上有可选择的怪兽）
	local b1=s.descon1(tp) and Duel.IsExistingMatchingCard(s.tgfilter1,tp,0,LOCATION_MZONE,1,nil,tp)
	-- 检查是否满足效果2的发动条件（自己场上有可选择的怪兽，且其正对面有可破坏的对方怪兽）
	local b2=Duel.IsExistingMatchingCard(s.tgfilter2,tp,LOCATION_MZONE,0,1,nil,tp)
	if chk==0 then return b1 or b2 end
	-- 让玩家从满足条件的选项中选择一个效果分支发动
	local label=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,0),1},  --"选对方怪兽"
		{b2,aux.Stringid(id,1),2})  --"选自己怪兽"
	e:SetLabel(label)
	-- 获取对方场上所有的怪兽，用于设置操作信息
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置破坏操作的信息，预估破坏对方场上的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理的Operation函数：根据玩家选择的分支，执行对应的破坏效果
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local label=e:GetLabel()
	if label==1 then
		-- 提示玩家选择一张卡（效果1：选对方场上1只表侧表示怪兽）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)  --"请选择"
		-- 让玩家选择对方场上1只表侧表示怪兽
		local g=Duel.SelectMatchingCard(tp,s.tgfilter1,tp,0,LOCATION_MZONE,1,1,nil,tp)
		if g:GetCount()>0 then
			-- 为选择的怪兽显示被选为对象的动画效果
			Duel.HintSelection(g)
			-- 获取对方场上除被选怪兽以外，等级/阶级/连接数值与被选怪兽等级相同的全部怪兽
			local sg=Duel.GetMatchingGroup(s.desfilter1,tp,0,LOCATION_MZONE,g,g:GetFirst():GetLevel())
			-- 将这些怪兽全部破坏
			Duel.Destroy(sg,POS_FACEUP,REASON_EFFECT)
		end
	elseif label==2 then
		-- 提示玩家选择一张卡（效果2：选自己场上1只表侧表示怪兽）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)  --"请选择"
		-- 让玩家选择自己场上1只表侧表示怪兽
		local g=Duel.SelectMatchingCard(tp,s.tgfilter2,tp,LOCATION_MZONE,0,1,1,nil,tp)
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			-- 为选择的自己怪兽显示被选为对象的动画效果
			Duel.HintSelection(g)
			local dg=tc:GetColumnGroup():Filter(s.desfilter2,nil,tp,tc:GetLevel())
			-- 将位于选的怪兽的正对面的、等级/阶级/连接数值与那个等级相同的对方怪兽全部破坏
			Duel.Destroy(dg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
