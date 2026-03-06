--GP－スタート・エンジン
-- 效果：
-- ①：对方把怪兽召唤·特殊召唤的场合，以那1只怪兽为对象才能发动。从卡组把3只「黄金荣耀」怪兽给对方观看，对方从那之中随机选1只。那1只怪兽在自己场上特殊召唤，剩余回到卡组。那之后，作为对象的怪兽破坏。
local s,id,o=GetID()
-- 创建并注册效果，使该卡在对方怪兽召唤或特殊召唤成功时发动，效果类型为发动型，具有延迟和取对象属性
function s.initial_effect(c)
	-- ①：对方把怪兽召唤·特殊召唤的场合，以那1只怪兽为对象才能发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选对方召唤成功的怪兽（在场上且可成为效果对象）
function s.dgfilter(c,e,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation (LOCATION_MZONE) and c:IsCanBeEffectTarget(e)
end
-- 过滤函数，用于筛选卡组中可特殊召唤的「黄金荣耀」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x192) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时的判断函数，检查是否有满足条件的怪兽并设置目标和操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.dgfilter(chkc,e,tp) end
	-- 获取卡组中所有符合条件的「黄金荣耀」怪兽
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 判断是否满足发动条件：存在对方召唤成功的怪兽、卡组中有3只以上符合条件的怪兽、自己场上存在空位
	if chk==0 then return eg:IsExists(s.dgfilter,1,nil,e,tp) and #sg>=3 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local dg=eg
	if #eg>1 then
		-- 向玩家提示选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		dg=eg:FilterSelect(tp,s.dgfilter,1,1,nil,e,tp)
	end
	-- 设置当前效果的目标怪兽
	Duel.SetTargetCard(dg)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数，执行检索、确认、特殊召唤和破坏操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有符合条件的「黄金荣耀」怪兽
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 判断是否满足发动条件：卡组中符合条件的怪兽不足3只或自己场上无空位
	if #g<3 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local sg=g:Select(tp,3,3,nil)
	-- 将选中的3只怪兽展示给对方玩家
	Duel.ConfirmCards(1-tp,sg)
	-- 将卡组洗切
	Duel.ShuffleDeck(tp)
	local cg=sg:RandomSelect(1-tp,1)
	-- 将随机选中的怪兽特殊召唤到自己场上
	if Duel.SpecialSummon(cg,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取当前效果的目标怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 中断当前效果，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 将目标怪兽破坏
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
