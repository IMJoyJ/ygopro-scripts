--タイム・ディメンションホール
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己卡组洗切。那之后，自己卡组最上面的卡翻开。翻开的卡是可以通常召唤的怪兽的场合，那只怪兽特殊召唤。不是的场合或者不能特殊召唤的场合，翻开的卡回到卡组最上面或最下面。
local s,id,o=GetID()
-- 初始化「时间次元洞会馆」(90615639)：注册1回合只能发动1张的通常陷阱效果，洗切卡组后翻开卡组顶1张卡并根据是否为可通常召唤怪兽决定特召或放回卡组顶/底
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己卡组洗切。那之后，自己卡组最上面的卡翻开。翻开的卡是可以通常召唤的怪兽的场合，那只怪兽特殊召唤。不是的场合或者不能特殊召唤的场合，翻开的卡回到卡组最上面或最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 效果Target函数：检测己方卡组中是否至少有1张卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认己方卡组至少有1张卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=1 end
end
-- 效果处理函数：洗切己方卡组后翻开卡组最上方1张卡，若是可通常召唤的怪兽且可特召则特殊召唤到场上，否则选择放回卡组最上面或最下面
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若效果处理时己方卡组没有卡则返回false中止处理
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<1 then return false end
	-- 手动洗切己方玩家的卡组
	Duel.ShuffleDeck(tp)
	-- 中断当前处理步骤，使后续翻开卡组顶卡片与洗切卡组视为不同时处理（“那之后”）
	Duel.BreakEffect()
	-- 翻开并确认己方卡组最上方的1张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取己方卡组最上方这1张卡组成的卡片组
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	-- 禁用紧接着操作后的自动洗切卡组检测，以保持放回卡组顶或底的位置不触发系统洗牌
	Duel.DisableShuffleCheck()
	-- 检查翻开的卡是否为可通常召唤的怪兽且己方主要怪兽区有可用空位
	if tc:IsSummonableCard() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		-- 将翻开的怪兽以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 在不特召而放回卡组的分支中，检查己方卡组数量是否大于1张（大于1张才需要区分最上面或最下面）
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1
			-- 让己方玩家在“回到卡组最上面”和“回到卡组最下面”两个选项之间进行选择
			and Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))==1 then  --"回到卡组最上面/回到卡组最下面"
			-- 当玩家选择回到卡组最下面时，将该卡移动到己方卡组最下面（参数1对应SEQ_DECKBOTTOM）
			Duel.MoveSequence(tc,1)
		end
	end
end
