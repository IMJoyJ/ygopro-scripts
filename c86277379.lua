--ガスタ・ヴェズル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，场上的表侧表示的「薰风」怪兽被战斗破坏的场合或者被送去自己墓地的场合才能发动。这张卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只「薰风」怪兽送去墓地。那之后，可以从手卡把1只「薰风」怪兽特殊召唤。
function c86277379.initial_effect(c)
	-- ①：这张卡在手卡存在，场上的表侧表示的「薰风」怪兽被战斗破坏的场合或者被送去自己墓地的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86277379,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_CUSTOM+86277379)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,86277379)
	e1:SetCondition(c86277379.spcon)
	e1:SetTarget(c86277379.sptg)
	e1:SetOperation(c86277379.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只「薰风」怪兽送去墓地。那之后，可以从手卡把1只「薰风」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86277379,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,86277380)
	e2:SetTarget(c86277379.tgtg)
	e2:SetOperation(c86277379.tgop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	if not c86277379.global_check then
		c86277379.global_check=true
		-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡在手卡存在，场上的表侧表示的「薰风」怪兽被战斗破坏的场合或者被送去自己墓地的场合才能发动。这张卡特殊召唤。②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只「薰风」怪兽送去墓地。那之后，可以从手卡把1只「薰风」怪兽特殊召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DESTROYED)
		ge1:SetCondition(c86277379.regcon)
		ge1:SetOperation(c86277379.regop)
		-- 注册全局环境效果，用于监测场上表侧表示怪兽被战斗破坏的事件
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_TO_GRAVE)
		ge2:SetCondition(c86277379.regcon2)
		-- 注册全局环境效果，用于监测怪兽被送去墓地的事件
		Duel.RegisterEffect(ge2,0)
	end
end
-- 过滤条件：原在怪兽区域表侧表示存在的「薰风」卡片
function c86277379.cfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(0x10)
end
-- 战斗破坏事件的触发条件：检查是否有满足过滤条件的卡片被战斗破坏，并记录受影响的玩家
function c86277379.regcon(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c86277379.cfilter,1,nil) then
		e:SetLabel(PLAYER_ALL)
		return true
	end
	e:SetLabel(PLAYER_NONE)
	return false
end
-- 过滤条件：非因战斗原因被送去玩家p墓地的原场上表侧表示「薰风」怪兽
function c86277379.cfilter2(c,p)
	return not c:IsReason(REASON_BATTLE) and c:IsControler(p) and c86277379.cfilter(c)
end
-- 送去墓地事件的触发条件：检查是否有满足条件的卡片送去双方墓地，并用二进制标志记录受影响的玩家
function c86277379.regcon2(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(c86277379.cfilter2,1,nil,0) then v=v+1 end
	if eg:IsExists(c86277379.cfilter2,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
-- 触发自定义事件，将受影响的玩家作为参数传递给后续效果
function c86277379.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 手动触发自定义事件，传入被破坏/送墓的卡片组以及受影响的玩家标志
	Duel.RaiseEvent(eg,EVENT_CUSTOM+86277379,re,r,rp,ep,e:GetLabel())
end
-- 效果①的发动条件：触发自定义事件的玩家包含自己
function c86277379.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ev==tp or ev==PLAYER_ALL
end
-- 效果①的发动准备：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function c86277379.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动阶段（chk==0）检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示此效果会特殊召唤1张自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的处理：若自身仍在手卡，则将自身特殊召唤
function c86277379.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：卡组中可以送去墓地的「薰风」怪兽
function c86277379.tgfilter(c)
	return c:IsSetCard(0x10) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果②的发动准备：检查卡组中是否存在可送墓的「薰风」怪兽，并设置送墓的操作信息
function c86277379.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查卡组中是否存在至少1只满足条件的「薰风」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c86277379.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置送去墓地的操作信息，表示此效果会将卡组的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：手卡中可以特殊召唤的「薰风」怪兽
function c86277379.spfilter(c,e,tp)
	return c:IsSetCard(0x10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的处理：从卡组将1只「薰风」怪兽送去墓地，之后可选择是否从手卡特殊召唤1只「薰风」怪兽
function c86277379.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，要求选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组中选择1只满足过滤条件的「薰风」怪兽
	local g=Duel.SelectMatchingCard(tp,c86277379.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选中的怪兽因效果送去墓地，并确认其已成功到达墓地
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		-- 检查自己场上是否有空余的怪兽区域，作为后续特殊召唤的先决条件
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在可以特殊召唤的「薰风」怪兽
		and Duel.IsExistingMatchingCard(c86277379.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 询问玩家是否选择进行后续的特殊召唤操作
		and Duel.SelectYesNo(tp,aux.Stringid(86277379,2)) then  --"是否特殊召唤？"
		-- 中断当前效果处理，使前后的送墓与特殊召唤不视为同时处理（会造成错时点）
		Duel.BreakEffect()
		-- 向玩家发送提示信息，要求选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡中选择1只满足过滤条件的「薰风」怪兽
		local sg=Duel.SelectMatchingCard(tp,c86277379.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 将选中的怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
