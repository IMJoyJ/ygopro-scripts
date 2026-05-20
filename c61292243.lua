--EMERGENCY！
-- 效果：
-- 这个卡名在规则上也当作「救援ACE队」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1只「救援ACE队」怪兽守备表示特殊召唤。那之后，自己的手卡·场上1只「救援ACE队」怪兽解放。
-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1张「救援ACE队」陷阱卡为对象才能发动。那张卡在自己场上盖放。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①的特召并解放效果，以及②的墓地除外盖放陷阱效果
function s.initial_effect(c)
	-- ①：从卡组把1只「救援ACE队」怪兽守备表示特殊召唤。那之后，自己的手卡·场上1只「救援ACE队」怪兽解放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1张「救援ACE队」陷阱卡为对象才能发动。那张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置效果②的发动代价为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 过滤条件：检索卡组中可以守备表示特殊召唤的「救援ACE队」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x18b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的发动准备与合法性检测函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可特召的「救援ACE队」怪兽，且玩家当前状态允许进行解放操作
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.IsPlayerCanRelease(tp) end
	-- 设置连锁信息，表明此效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：检索手卡或场上的「救援ACE队」怪兽（用于后续的解放处理）
function s.rfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x18b)
end
-- ①效果的处理函数：从卡组特召怪兽，之后解放手卡或场上的一只「救援ACE队」怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已无可用怪兽区域，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足特召条件的「救援ACE队」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 若成功选出怪兽，则将其以表侧守备表示特殊召唤
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 产生时点中断，使后续的解放处理与特殊召唤不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要解放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 让玩家从手卡或场上选择1只可解放的「救援ACE队」怪兽
		local rg=Duel.SelectReleaseGroupEx(tp,s.rfilter,1,1,REASON_EFFECT,true,nil)
		if rg:GetCount()>0 then
			-- 闪烁显示被选择解放的怪兽
			Duel.HintSelection(rg)
			-- 将选中的怪兽因效果解放
			Duel.Release(rg,REASON_EFFECT)
		end
	end
end
-- 过滤条件：检索墓地中可以盖放的「救援ACE队」陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x18b) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- ②效果的发动准备与目标选择函数
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.setfilter(chkc) end
	-- 检查自己墓地是否存在可盖放的「救援ACE队」陷阱卡
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家选择墓地中1张符合条件的「救援ACE队」陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁信息，表明此效果包含卡片离开墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ②效果的处理函数：将作为对象的陷阱卡在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果处理中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
