--アラドヴァルの影霊衣
-- 效果：
-- 「影灵衣」仪式魔法卡降临
-- 这张卡若非以只使用除10星以外的怪兽来作的仪式召唤则不能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。自己的手卡·场上最多2只「影灵衣」怪兽解放，把那个数量的「影灵衣」卡从卡组送去墓地。
-- ②：怪兽的效果发动时，把自己的手卡·场上1只怪兽解放才能发动。那个发动无效并除外。
function c39468724.initial_effect(c)
	c:EnableReviveLimit()
	-- 「影灵衣」仪式魔法卡降临；这张卡若非以只使用除10星以外的怪兽来作的仪式召唤则不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件的判定逻辑：非仪式召唤不能特殊召唤，即禁止通过仪式召唤以外的方式将这张卡特殊召唤，配合EnableReviveLimit实现只能以仪式召唤方式从手牌出场的限制。
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- ①：把这张卡从手卡丢弃才能发动。自己的手卡·场上最多2只「影灵衣」怪兽解放，把那个数量的「影灵衣」卡从卡组送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39468724,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,39468724)
	e2:SetCost(c39468724.tgcost)
	e2:SetTarget(c39468724.tgtg)
	e2:SetOperation(c39468724.tgop)
	c:RegisterEffect(e2)
	-- ②：怪兽的效果发动时，把自己的手卡·场上1只怪兽解放才能发动。那个发动无效并除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(39468724,1))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,39468725)
	e3:SetCondition(c39468724.negcon)
	e3:SetCost(c39468724.negcost)
	-- 设置②效果的发动目标判定函数为aux.nbtg，用于选择并声明“无效并除外”的目标怪兽效果，若目标在墓地发动还会自动追加墓地操作分类。
	e3:SetTarget(aux.nbtg)
	e3:SetOperation(c39468724.negop)
	c:RegisterEffect(e3)
end
-- 仪式召唤素材的过滤条件：素材怪兽不能是10星，即只能使用除10星以外的怪兽作为仪式召唤素材。
function c39468724.mat_filter(c)
	return not c:IsLevel(10)
end
-- ①效果的发动代价函数：从手卡丢弃这张卡本身作为COST，先检查这张卡能否丢弃，可以则将其从手卡送去墓地。
function c39468724.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将这张卡以“代价+丢弃”的原因从手卡送去墓地，完成丢弃自身作为发动①效果的COST。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- ①效果中用于选择解放对象的过滤器：必须是「影灵衣」（0xb4）字段的怪兽卡。
function c39468724.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xb4)
end
-- ①效果中用于选择卡组送墓对象的过滤器：必须是「影灵衣」（0xb4）字段且可以被送去墓地的卡。
function c39468724.tgfilter(c)
	return c:IsSetCard(0xb4) and c:IsAbleToGrave()
end
-- ①效果的发动条件判定：在发动时要求卡组存在至少1张可送去墓地的「影灵衣」卡，且自己手卡·场上存在至少1只可解放的「影灵衣」怪兽，满足条件才可发动。
function c39468724.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张符合条件的「影灵衣」卡可以被送去墓地，以确认效果发动的可行性。
	if chk==0 then return Duel.IsExistingMatchingCard(c39468724.tgfilter,tp,LOCATION_DECK,0,1,nil)
		-- 同时检查自己手卡·场上是否存在至少1只可解放的「影灵衣」怪兽（排除这张卡自身），用于后续解放并决定送墓数量。
		and Duel.CheckReleaseGroupEx(tp,c39468724.filter,1,REASON_EFFECT,true,e:GetHandler()) end
	-- 设置操作信息，宣告此效果涉及从卡组把卡送去墓地（CATEGORY_TOGRAVE），供连锁判定与相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：统计卡组可送墓的「影灵衣」卡数量并限制在1~2之间，玩家选择解放1~ct只「影灵衣」怪兽，再选择相同数量的「影灵衣」卡从卡组送去墓地。
function c39468724.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 统计卡组中可送去墓地的「影灵衣」卡的数量；若为0则视为1（实际发动时不会为0），若超过2则取2，决定最多解放/送墓的数量。
	local ct=Duel.GetMatchingGroupCount(c39468724.tgfilter,tp,LOCATION_DECK,0,nil)
	if ct==0 then ct=1 end
	if ct>2 then ct=2 end
	-- 让玩家从手卡·场上选择1~ct只符合条件的「影灵衣」怪兽作为解放对象，解放数量将决定后续从卡组送墓的张数。
	local g=Duel.SelectReleaseGroupEx(tp,c39468724.filter,1,ct,REASON_EFFECT,true,nil)
	if g:GetCount()>0 then
		-- 解放所选的怪兽，得到实际解放数量rct，作为接下来从卡组选择送墓卡数量的依据。
		local rct=Duel.Release(g,REASON_EFFECT)
		-- 发送“请选择要送去墓地的卡”的选择提示，供玩家在接下来的选择界面中确认要送往墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组选择rct张符合条件的「影灵衣」卡（数量等于实际解放的怪兽数量）。
		local tg=Duel.SelectMatchingCard(tp,c39468724.tgfilter,tp,LOCATION_DECK,0,rct,rct,nil)
		-- 将选择的「影灵衣」卡以效果原因送去墓地。
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end
-- ②效果的发动条件判定：这张卡未被战斗破坏、当前连锁可以被无效、且引发连锁的效果是怪兽效果时才能发动。
function c39468724.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体条件：这张卡未处于“被战斗破坏”状态；该连锁可以被无效；且被无效的效果为怪兽效果（re:IsActiveType(TYPE_MONSTER)）。
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and re:IsActiveType(TYPE_MONSTER)
end
-- ②效果的发动代价函数：解放自己手卡·场上1只怪兽作为COST；先检查是否存在可解放的怪兽，再选择并解放。
function c39468724.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动前检查自己手卡·场上是否存在至少1只任意可解放的怪兽，以支付②效果的解放COST。
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,nil,1,REASON_COST,true,nil,tp) end
	-- 发送“请选择要解放的卡”的提示消息，引导玩家选择要解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从自己手卡·场上选择1只任意怪兽作为②效果的解放代价。
	local g=Duel.SelectReleaseGroupEx(tp,nil,1,1,REASON_COST,true,nil,tp)
	-- 以COST原因解放所选怪兽，完成代价支付。
	Duel.Release(g,REASON_COST)
end
-- ②效果处理：如果该怪兽效果的发动被无效成功，且效果来源的怪兽仍与那个效果关联，则将其除外。
function c39468724.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使连锁发动无效；若无效成功且发动效果的怪兽仍存在/与连锁关联，则继续执行除外处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将发动被无效效果的那只怪兽（eg）以表侧表示除外。
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
