--不知火流 燕の太刀
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只不死族怪兽解放，以场上2张卡为对象才能发动。那些卡破坏。那之后，从卡组把1只「不知火」怪兽除外。
function c4333086.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己场上1只不死族怪兽解放，以场上2张卡为对象才能发动。那些卡破坏。那之后，从卡组把1只「不知火」怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,4333086+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c4333086.cost)
	e1:SetTarget(c4333086.target)
	e1:SetOperation(c4333086.activate)
	c:RegisterEffect(e1)
end
-- 定义「不知火」怪兽的筛选条件：持有「不知火」字段、是怪兽且可以被除外。
function c4333086.filter(c)
	return c:IsSetCard(0xd9) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 代价函数：将Label置为1，标记本次发动需要支付“解放1只不死族怪兽”的代价，返回true表示可以发动；实际解放操作由target函数中的对应分支执行。
function c4333086.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 破坏对象的附加过滤条件：对象不是发动卡c、不是将被解放的cost怪兽，并且不是装备在发动卡上的装备卡。
function c4333086.desfilter(c,tc,ec)
	return c:GetEquipTarget()~=tc and c~=ec
end
-- 解放素材的过滤条件：自身是不死族怪兽，且场上存在2张满足破坏对象条件的卡，保证发动时能够正常选择对象。
function c4333086.costfilter(c,ec,tp)
	if not c:IsRace(RACE_ZOMBIE) then return false end
	-- 检查场上是否存在至少2张可被选择为破坏对象的卡（排除发动卡、即将解放的怪兽及装备在发动卡上的卡）。
	return Duel.IsExistingTarget(c4333086.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,c,c,ec)
end
-- 目标函数：判定发动条件，若需要解放cost则先选择并解放1只不死族怪兽，然后选择场上2张卡作为破坏对象，并设置破坏与除外的操作信息。
function c4333086.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查我方场上是否存在1只满足costfilter条件的不死族怪兽可以作为解放素材。
			return Duel.CheckReleaseGroup(tp,c4333086.costfilter,1,c,c,tp)
				-- 并检查卡组中是否存在1只可以除外的「不知火」怪兽。
				and Duel.IsExistingMatchingCard(c4333086.filter,tp,LOCATION_DECK,0,1,nil)
		else
			-- 检查场上是否存在2张可以成为效果对象的卡（排除发动卡本身）。
			return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,c)
				-- 并检查卡组中是否存在1只可以除外的「不知火」怪兽。
				and Duel.IsExistingMatchingCard(c4333086.filter,tp,LOCATION_DECK,0,1,nil)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 选择1只满足costfilter条件的不死族怪兽作为解放素材。
		local sg=Duel.SelectReleaseGroup(tp,c4333086.costfilter,1,1,c,c,tp)
		-- 将选择的怪兽解放，作为发动效果的费用。
		Duel.Release(sg,REASON_COST)
	end
	-- 向玩家显示“请选择要破坏的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上2张卡作为效果对象（排除发动卡本身），并登记为连锁对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,c)
	-- 设置操作信息：破坏对象为选中的2张卡，破坏分类为破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	-- 设置操作信息：从卡组除外1张卡，具体卡在效果处理时选择。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：先破坏已选择的2张对象卡，若破坏成功，再从卡组选择1只「不知火」怪兽除外。
function c4333086.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的2张对象卡，并筛选出仍与本次效果关联的卡（过滤掉离场或失去关联的卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将筛选后的对象卡以效果破坏；若至少破坏了1张，则继续执行后续除外处理。
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 向玩家显示“请选择要除外的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从卡组选择1只满足filter条件的「不知火」怪兽用于除外。
		local rg=Duel.SelectMatchingCard(tp,c4333086.filter,tp,LOCATION_DECK,0,1,1,nil)
		if rg:GetCount()>0 then
			-- 中断当前效果处理，使后续除外操作与前面的破坏处理视为不同时进行（对应“那之后”）。
			Duel.BreakEffect()
			-- 将选择的「不知火」怪兽以表侧表示除外。
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
