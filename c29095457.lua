--原石の穿光
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把「原石的穿光」以外的手卡1张「原石」卡或1只通常怪兽给对方观看，以场上1张表侧表示卡为对象才能发动（除衍生物外的，通常怪兽或者5星以上的「原石」怪兽在自己场上存在的场合，也能不给人观看来发动）。作为对象的卡的效果无效并除外。
-- ②：自己场上有「原石」怪兽存在的场合，自己主要阶段才能发动。墓地的这张卡在自己场上盖放。
local s,id,o=GetID()
-- 注册卡片的两个效果：①魔法卡发动效果（展示手卡或满足条件时不展示，无效并除外场上1张表侧卡）；②墓地起动效果（自己场上有表侧「原石」怪兽时，主要阶段把墓地的这张卡盖放）。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把「原石的穿光」以外的手卡1张「原石」卡或1只通常怪兽给对方观看，以场上1张表侧表示卡为对象才能发动（除衍生物外的，通常怪兽或者5星以上的「原石」怪兽在自己场上存在的场合，也能不给人观看来发动）。作为对象的卡的效果无效并除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有「原石」怪兽存在的场合，自己主要阶段才能发动。墓地的这张卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"这张卡盖放 "
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- 筛选手卡中可作为①效果展示代价的卡：卡名不能是本卡（原石的穿光），且必须是「原石」系列卡或通常怪兽，并且当前未公开。
function s.cfilter(c)
	return not c:IsCode(id) and (c:IsSetCard(0x1b9) or c:IsType(TYPE_NORMAL)) and not c:IsPublic()
end
-- 筛选自己场上可免除手卡展示、直接发动①效果的怪兽：表侧表示、非衍生物，且为通常怪兽或5星以上的「原石」怪兽。
function s.confilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN)
		and (c:IsType(TYPE_NORMAL) or c:IsSetCard(0x1b9) and c:IsLevelAbove(5))
end
-- ①效果的cost处理：先检查手卡有无可展示卡(b1)和场上有无可免除展示的怪兽(b2)；若b1存在且b2也存在，则询问玩家是否展示手卡；若选择展示或场上不满足免除条件，则选择1张手卡给对方确认并洗切手卡；若b1和b2都不存在则cost不通过。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张符合s.cfilter的可展示卡（非本卡名的「原石」卡或通常怪兽且未公开）。
	local b1=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil)
	-- 检查自己场上是否存在至少1只符合s.confilter的怪兽（表侧、非衍生物、通常怪兽或5星以上「原石」怪兽），以决定能否不展示手卡。
	local b2=Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	if b1 then
		-- 当手卡可展示且场上也可免除展示时，让玩家选择是否展示手卡来发动；选择否则直接终止cost（不发动）。
		if b2 and not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end  --"是否展示卡来发动？"
		-- 弹出选择手卡的提示，要求玩家选择1张要展示给对方确认的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 从手卡中选择1张满足s.cfilter条件的卡作为展示的代价。
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
		-- 将选中的手卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 展示后洗切手卡，避免手卡顺序信息泄露。
		Duel.ShuffleHand(tp)
	end
end
-- 定义对象卡筛选函数：场上表侧表示、可被无效化且可被除外。
function s.nbfilter(c)
	-- 判断卡片是否为表侧表示、能否被无效化以及能否被除外，全部满足才可选为对象。
	return c:IsFaceup() and aux.NegateAnyFilter(c) and c:IsAbleToRemove()
end
-- ①效果的目标选择处理：排除发动中的本卡，选择场上1张表侧且满足s.nbfilter的卡作为对象，并写入‘除外’和‘无效’两类操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and s.nbfilter(chkc) and c~=chkc end
	-- 合法性检查：确认场上是否存在1张除发动中的本卡以外、可作为对象的表侧表示卡。
	if chk==0 then return Duel.IsExistingTarget(s.nbfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 提示玩家选择一张表侧表示的卡作为效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1张符合条件的表侧表示卡作为对象（不选择本卡自身）。
	local g=Duel.SelectTarget(tp,s.nbfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	-- 设置操作信息：本次连锁将把对象卡除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置操作信息：本次连锁将使对象卡的效果无效化。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ①效果处理：对仍与效果相关且表侧表示、可被无效化的对象卡，赋予效果无效状态（EFFECT_DISABLE），并使其效果无效（EFFECT_DISABLE_EFFECT）；若为陷阱怪兽，再追加无效陷阱怪兽状态；随后刷新无效状态、使相关连锁无效，最后将对象卡表侧表示除外。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
		local c=e:GetHandler()
		-- 使对象卡本身无效（EFFECT_DISABLE），对应原文‘作为对象的卡的效果无效’。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使对象卡的效果也无效化（EFFECT_DISABLE_EFFECT），对应原文‘作为对象的卡的效果无效’。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 若对象卡是陷阱怪兽，再使其作为陷阱怪兽的效果无效，对应原文‘作为对象的卡的效果无效’。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
		-- 立即刷新场上因无效效果产生的状态变化，使无效化即时生效。
		Duel.AdjustInstantly()
		-- 使与该对象卡相关的连锁效果无效化，防止其在无效/除外前发动。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 将对象卡以表侧表示除外，完成‘并除外’的处理。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 筛选自己场上表侧表示存在的「原石」怪兽，用于②效果的发动条件判断。
function s.setfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1b9)
end
-- ②效果的发动条件：自己场上有表侧表示的「原石」怪兽存在。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认自己场上是否存在至少1只表侧表示的「原石」怪兽。
	return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的目标检查：墓地中的这张卡可以盖放时，设置‘卡片离开墓地’的操作信息。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 设置操作信息：这张卡将从墓地离开（被盖放到场上）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- ②效果的实际处理：取得本卡，如果它仍与效果相关且未被王家长眠之谷无效，则将它从墓地盖放到自己场上。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与②效果相关且不受王家长眠之谷影响，满足则将其从墓地盖放到自己场上。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then Duel.SSet(tp,c) end
end
