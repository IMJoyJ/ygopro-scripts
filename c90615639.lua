--タイム・ディメンションホール
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己卡组洗切。那之后，自己卡组最上面的卡翻开。翻开的卡是可以通常召唤的怪兽的场合，那只怪兽特殊召唤。不是的场合或者不能特殊召唤的场合，翻开的卡回到卡组最上面或最下面。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己卡组洗切。那之后，自己卡组最上面的卡翻开。翻开的卡是可以通常召唤的怪兽的场合，那只怪兽特殊召唤。不是的场合或者不能特殊召唤的场合，翻开的卡回到卡组最上面或最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的靶向与合法性检测函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 作为发动时的可行性检测：自己卡组必须有至少1张卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=1 end
end
-- 效果处理的核心逻辑函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若卡组没有卡则不处理
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<1 then return false end
	-- 洗切自己卡组
	Duel.ShuffleDeck(tp)
	-- 中断当前效果处理，使后续的翻开卡片处理视为不同时处理
	Duel.BreakEffect()
	-- 确认（翻开）自己卡组最上方的一张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取卡组最上方的一张卡
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	-- 关闭洗卡检测，防止后续操作导致系统自动洗牌
	Duel.DisableShuffleCheck()
	-- 判断翻开的卡是否是可以通常召唤的怪兽，且自己场上有可用的怪兽区域
	if tc:IsSummonableCard() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		-- 将该怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 如果卡组中还有其他卡（即卡组卡片数量大于1，放回最上面和最下面有区别）
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1
			-- 让玩家选择将卡放回卡组最上面还是最下面，并判断是否选择了放回最下面（选项1）
			and Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))==1 then  --"回到卡组最上面/回到卡组最下面"
			-- 将该卡移动到卡组最下面
			Duel.MoveSequence(tc,1)
		end
	end
end
