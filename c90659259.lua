--D・コンバートユニット
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只机械族怪兽为对象才能发动。那只怪兽的表示形式的以下效果适用。
-- ●攻击表示：和作为对象的怪兽卡名不同的1只「变形斗士」怪兽从卡组特殊召唤。那之后，作为对象的怪兽回到持有者卡组最上面。
-- ●守备表示：作为对象的怪兽变成攻击表示，从手卡把1只4星以下的机械族怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，定义该卡的发动效果
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只机械族怪兽为对象才能发动。那只怪兽的表示形式的以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查场上是否存在可以作为效果对象的表侧表示机械族怪兽（若为攻击表示，则需能回卡组且卡组有不同名「变形斗士」怪兽可特召；若为守备表示，则需手牌有4星以下机械族怪兽可特召）
function s.tgfilter(c,e,tp)
	if not (c:IsFaceup() and c:IsRace(RACE_MACHINE)) then return false end
	if c:IsAttackPos() then
		return c:IsAbleToDeck()
			-- 检查卡组中是否存在与该怪兽卡名不同的、可特殊召唤的「变形斗士」怪兽
			and Duel.IsExistingMatchingCard(s.atkspfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
	else
		-- 检查手牌中是否存在可特殊召唤的4星以下机械族怪兽
		return Duel.IsExistingMatchingCard(s.defspfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
end
-- 过滤函数：卡组中与对象怪兽卡名不同且可以特殊召唤的「变形斗士」怪兽
function s.atkspfilter(c,e,tp,code)
	return c:IsSetCard(0x26) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数：手牌中可以特殊召唤的4星以下机械族怪兽
function s.defspfilter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性检查（处理成为效果对象的情况）
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp)
		and chkc:IsFaceup() and chkc:IsRace(RACE_MACHINE) and chkc:IsPosition(e:GetLabel()) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在满足条件的可选择为对象的机械族怪兽
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要作为效果对象的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择1只满足条件的机械族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	e:SetLabel(tc:GetPosition()|POS_FACEUP)
	if tc:IsAttackPos() then
		-- 设置连锁信息：包含将对象怪兽送回卡组的操作
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
		-- 设置连锁信息：包含从卡组特殊召唤怪兽的操作
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	else
		-- 设置连锁信息：包含改变对象怪兽表示形式的操作
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
		-- 设置连锁信息：包含从手牌特殊召唤怪兽的操作
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	end
end
-- 效果处理的函数，根据对象怪兽的表示形式适用对应的效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if tc:IsAttackPos() and tc:IsFaceup()
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只与对象怪兽卡名不同的「变形斗士」怪兽
		local g=Duel.SelectMatchingCard(tp,s.atkspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetCode())
		if g:GetCount()>0 then
			-- 将选择的「变形斗士」怪兽表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			-- 洗切卡组
			Duel.ShuffleDeck(tp)
			-- 划分效果处理阶段，使后续的回到卡组最上面不与特殊召唤同时处理
			Duel.BreakEffect()
			-- 将作为对象的怪兽回到持有者卡组最上面
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	-- 若对象怪兽为守备表示，则将其变成表侧攻击表示
	elseif tc:IsDefensePos() and Duel.ChangePosition(tc,POS_FACEUP_ATTACK)~=0
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌选择1只4星以下的机械族怪兽
		local g2=Duel.SelectMatchingCard(tp,s.defspfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g2:GetCount()>0 then
			-- 将选择的机械族怪兽表侧表示特殊召唤
			Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
