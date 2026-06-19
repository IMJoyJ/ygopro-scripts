--エニグマスター・パックビット
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合或者被送去墓地的场合，以自己墓地或对方场上（表侧表示）1只怪兽为对象才能发动。选自己1张手卡丢弃，作为对象的怪兽当作永续陷阱卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
-- ②：这张卡是当作永续陷阱卡使用的场合，自己·对方回合可以发动。自己的魔法与陷阱区域1张表侧表示的怪兽卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：同调召唤手续、同调召唤成功或送墓时将怪兽当作永续陷阱放置、在魔陷区当作永续陷阱时将魔陷区怪兽特召
function s.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	--move
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.sumcon)
	e1:SetTarget(s.mvtg)
	e1:SetOperation(s.mvop)
	c:RegisterEffect(e1)
	--move(to grave)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_HANDES_SELF)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.mvtg)
	e2:SetOperation(s.mvop)
	c:RegisterEffect(e2)
	-- ②：这张卡是当作永续陷阱卡使用的场合，自己·对方回合可以发动。自己的魔法与陷阱区域1张表侧表示的怪兽卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.spstg)
	e3:SetOperation(s.spsop)
	c:RegisterEffect(e3)
end
-- 判定此卡是否是通过同调召唤特殊召唤的
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤满足以下条件的卡：是怪兽卡（或在怪兽区），且表侧表示存在，且其原本持有者的魔陷区有空位
function s.filter(c,tp)
	local r=LOCATION_REASON_TOFIELD
	if not c:IsControler(c:GetOwner()) then r=LOCATION_REASON_CONTROL end
	return (c:IsType(TYPE_MONSTER) or c:IsLocation(LOCATION_MZONE)) and c:IsFaceupEx()
		-- 检查该卡原本持有者的魔法与陷阱区域是否有可用的空格
		and Duel.GetLocationCount(c:GetOwner(),LOCATION_SZONE,tp,r)>0
end
-- 效果①的靶向与发动准备：检查墓地或对方场上是否有符合条件的怪兽，且自己手牌数大于0，并进行取对象和设置操作信息
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and s.filter(chkc,tp) end
	-- 检查自己墓地或对方场上是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,LOCATION_MZONE,1,nil)
		-- 检查自己手卡数量是否大于0（用于丢弃手卡的花销）
		and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,LOCATION_MZONE,1,1,nil)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 如果对象在墓地，设置操作信息：卡片离开墓地
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 效果①的处理：丢弃1张手卡，将作为对象的怪兽移动到原本持有者的魔陷区，并使其当作永续陷阱卡使用
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 让玩家选择并丢弃1张手卡，若未成功丢弃则效果处理中止
	if Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)~=1 then return false end
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e)
		-- 将对象怪兽表侧表示移动到其原本持有者的魔法与陷阱区域
		and Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
		-- 当作永续陷阱卡使用
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- 判定此卡是否当作永续陷阱卡使用
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetType()==TYPE_TRAP+TYPE_CONTINUOUS
end
-- 过滤满足以下条件的卡：位于自己的魔陷区、原本是怪兽卡、表侧表示存在，且可以特殊召唤
function s.sfilter(c,e,tp)
	return c:IsLocation(LOCATION_SZONE) and c:GetOriginalType()&TYPE_MONSTER>0
		and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的靶向与发动准备：检查自己怪兽区是否有空位，且自己魔陷区是否存在满足条件的怪兽卡，并设置特殊召唤的操作信息
function s.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的魔法与陷阱区域是否存在至少1张满足条件的表侧表示怪兽卡
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 获取自己魔法与陷阱区域所有满足特殊召唤条件的卡
	local g=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_SZONE,0,nil,e,tp)
	-- 设置操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的处理：选择自己魔陷区1张表侧表示的怪兽卡特殊召唤
function s.spsop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择自己魔法与陷阱区域1张表侧表示的怪兽卡
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	-- 将选择的卡在自己场上表侧表示特殊召唤
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
