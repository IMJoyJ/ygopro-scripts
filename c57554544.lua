--炎王の孤島
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己主要阶段才能发动。自己的手卡·场上1只怪兽破坏，从卡组把1只「炎王」怪兽加入手卡。
-- ②：自己场上没有怪兽存在的场合才能发动。从手卡把1只鸟兽族·炎属性怪兽特殊召唤。
-- ③：场地区域的表侧表示的这张卡被送去墓地的场合或者被除外的场合发动。自己场上的怪兽全部破坏。
function c57554544.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。自己的手卡·场上1只怪兽破坏，从卡组把1只「炎王」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(57554544,0))  --"怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,57554544)
	e2:SetTarget(c57554544.target)
	e2:SetOperation(c57554544.operation)
	c:RegisterEffect(e2)
	-- ②：自己场上没有怪兽存在的场合才能发动。从手卡把1只鸟兽族·炎属性怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(57554544,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,57554544)
	e3:SetCondition(c57554544.spcon)
	e3:SetTarget(c57554544.sptg)
	e3:SetOperation(c57554544.spop)
	c:RegisterEffect(e3)
	-- ③：场地区域的表侧表示的这张卡被送去墓地的场合或者被除外的场合发动。自己场上的怪兽全部破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(57554544,2))  --"怪兽破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c57554544.descon)
	e4:SetTarget(c57554544.destg)
	e4:SetOperation(c57554544.desop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e5)
end
-- 过滤条件：怪兽卡
function c57554544.filter1(c)
	return c:IsType(TYPE_MONSTER)
end
-- 过滤条件：卡组中可以加入手牌的「炎王」怪兽卡
function c57554544.filter2(c)
	return c:IsSetCard(0x81) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动准备与合法性检测
function c57554544.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡或场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c57554544.filter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
		-- 并且检查卡组中是否存在至少1只「炎王」怪兽
		and Duel.IsExistingMatchingCard(c57554544.filter2,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置破坏操作的信息，预计破坏自己手卡或场上的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	-- 设置检索操作的信息，预计从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理逻辑（破坏手卡/场上怪兽并检索「炎王」怪兽）
function c57554544.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择卡片时的提示信息为“选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己的手卡或场上选择1只怪兽
	local g=Duel.SelectMatchingCard(tp,c57554544.filter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	-- 如果成功选择并破坏了该怪兽
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 设置选择卡片时的提示信息为“选择要加入手牌的卡”
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1只「炎王」怪兽
		local g=Duel.SelectMatchingCard(tp,c57554544.filter2,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡片
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 效果②的发动条件（自己场上没有怪兽存在）
function c57554544.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤条件：手牌中可以特殊召唤的鸟兽族·炎属性怪兽
function c57554544.spfilter(c,e,tp)
	return c:IsRace(RACE_WINDBEAST) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与合法性检测
function c57554544.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手牌中是否存在满足特殊召唤条件的鸟兽族·炎属性怪兽
		and Duel.IsExistingMatchingCard(c57554544.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向对方玩家提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置特殊召唤操作的信息，预计从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的处理逻辑（从手牌特殊召唤1只鸟兽族·炎属性怪兽）
function c57554544.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果此时自己场上没有可用的怪兽区域空格，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 设置选择卡片时的提示信息为“选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1只满足条件的鸟兽族·炎属性怪兽
	local g=Duel.SelectMatchingCard(tp,c57554544.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果③的发动条件（场地区域表侧表示的这张卡被送去墓地或除外）
function c57554544.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_FZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 效果③的发动准备与合法性检测
function c57554544.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	-- 设置破坏操作的信息，预计破坏自己场上的全部怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果③的处理逻辑（破坏自己场上的全部怪兽）
function c57554544.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	-- 破坏获取到的所有怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
