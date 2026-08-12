--時空のペンデュラムグラフ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，对方不能把自己场上的魔法师族怪兽作为陷阱卡的效果的对象。
-- ②：以自己的怪兽区域·灵摆区域1张「魔术师」灵摆怪兽卡和对方场上1张卡为对象才能发动。那些卡破坏。没能因这个效果把2张卡破坏的场合，可以把场上1张卡送去墓地。
function c1344018.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，对方不能把自己场上的魔法师族怪兽作为陷阱卡的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为对方场上的魔法师族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_SPELLCASTER))
	e2:SetValue(c1344018.evalue)
	c:RegisterEffect(e2)
	-- ②：以自己的怪兽区域·灵摆区域1张「魔术师」灵摆怪兽卡和对方场上1张卡为对象才能发动。那些卡破坏。没能因这个效果把2张卡破坏的场合，可以把场上1张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1344018,0))  --"卡片破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,1344018)
	e3:SetTarget(c1344018.destg)
	e3:SetOperation(c1344018.desop)
	c:RegisterEffect(e3)
end
-- 当对方陷阱卡发动时，该效果不能成为其对象
function c1344018.evalue(e,re,rp)
	return re:IsActiveType(TYPE_TRAP) and rp==1-e:GetHandlerPlayer()
end
-- 筛选满足条件的「魔术师」灵摆怪兽，用于效果发动的取对象
function c1344018.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM)
end
-- 判断是否满足发动条件：己方场上有「魔术师」灵摆怪兽，对方场上存在可破坏的卡
function c1344018.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断己方场上有「魔术师」灵摆怪兽
	if chk==0 then return Duel.IsExistingTarget(c1344018.desfilter,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,nil)
		-- 判断对方场上存在可破坏的卡
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择己方场上的「魔术师」灵摆怪兽
	local g1=Duel.SelectTarget(tp,c1344018.desfilter,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,1,nil)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择对方场上的卡
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理信息，准备破坏2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 处理效果发动后的破坏操作
function c1344018.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被选择的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 尝试破坏目标卡，若未成功破坏2张卡则进入后续处理
	if Duel.Destroy(g,REASON_EFFECT)~=2 then
		-- 获取场上所有卡的集合
		local g2=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
		-- 若场上存在卡且玩家选择发动，则进入墓地处理流程
		if g2:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(1344018,1)) then  --"是否选场上1张卡送去墓地？"
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
			-- 提示玩家选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local sg=g2:Select(tp,1,1,nil)
			-- 显示被选为对象的卡
			Duel.HintSelection(sg)
			-- 将选中的卡送去墓地
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end
