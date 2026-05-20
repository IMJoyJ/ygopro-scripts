--魁炎星－シーブ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤成功时，丢弃1张手卡，以自己场上1张「炎舞」魔法·陷阱卡为对象才能发动。从卡组选和那张卡卡名不同的1张「炎舞」魔法·陷阱卡在自己场上盖放。
-- ②：这张卡用「炎星」怪兽的效果特殊召唤成功的场合才能发动。从卡组选同名卡不在自己墓地存在的1张「炎舞」魔法·陷阱卡在自己场上盖放。
function c62694833.initial_effect(c)
	-- ①：这张卡召唤成功时，丢弃1张手卡，以自己场上1张「炎舞」魔法·陷阱卡为对象才能发动。从卡组选和那张卡卡名不同的1张「炎舞」魔法·陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62694833,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,62694833)
	e1:SetCost(c62694833.setcost1)
	e1:SetTarget(c62694833.settg1)
	e1:SetOperation(c62694833.setop1)
	c:RegisterEffect(e1)
	-- ②：这张卡用「炎星」怪兽的效果特殊召唤成功的场合才能发动。从卡组选同名卡不在自己墓地存在的1张「炎舞」魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62694833,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,62694834)
	e2:SetCondition(c62694833.setcon2)
	e2:SetTarget(c62694833.settg2)
	e2:SetOperation(c62694833.setop2)
	c:RegisterEffect(e2)
end
-- 效果①的代价：丢弃1张手卡
function c62694833.setcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除这张卡以外的可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择并丢弃1张手卡
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：自己场上表侧表示的「炎舞」魔法·陷阱卡，且卡组中存在与其卡名不同的「炎舞」魔法·陷阱卡
function c62694833.setfilter1(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP)
		-- 检查卡组中是否存在与该卡卡名不同的「炎舞」魔法·陷阱卡
		and Duel.IsExistingMatchingCard(c62694833.setfilter2,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
-- 过滤条件：卡组中与指定卡名不同且可以盖放的「炎舞」魔法·陷阱卡
function c62694833.setfilter2(c,code)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(code) and c:IsSSetable()
end
-- 效果①的目标选择：选择自己场上1张表侧表示的「炎舞」魔法·陷阱卡为对象
function c62694833.settg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c62694833.setfilter1(chkc,tp) end
	-- 检查场上是否存在满足过滤条件1的、可作为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(c62694833.setfilter1,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择1张满足过滤条件1的卡作为效果对象
	Duel.SelectTarget(tp,c62694833.setfilter1,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
end
-- 效果①的操作：从卡组选和对象卡卡名不同的1张「炎舞」魔法·陷阱卡在自己场上盖放
function c62694833.setop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 玩家从卡组选择1张与对象卡卡名不同的「炎舞」魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,c62694833.setfilter2,tp,LOCATION_DECK,0,1,1,nil,tc:GetCode())
		if g:GetCount()>0 then
			-- 将选中的卡在自己场上盖放
			Duel.SSet(tp,g:GetFirst())
		end
	end
end
-- 效果②的发动条件：这张卡是用「炎星」怪兽的效果特殊召唤成功
function c62694833.setcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x79)
end
-- 过滤条件：卡组中可以盖放的「炎舞」魔法·陷阱卡，且同名卡不在自己墓地存在
function c62694833.setfilter3(c,tp)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
		-- 检查自己墓地中是否存在与该卡同名的卡
		and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
end
-- 效果②的目标选择：检查卡组中是否存在满足过滤条件3的卡
function c62694833.settg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足过滤条件3的、可盖放的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c62694833.setfilter3,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 效果②的操作：从卡组选同名卡不在自己墓地存在的1张「炎舞」魔法·陷阱卡在自己场上盖放
function c62694833.setop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 玩家从卡组选择1张同名卡不在自己墓地存在的「炎舞」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c62694833.setfilter3,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g:GetCount()>0 then
		-- 将选中的卡在自己场上盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
