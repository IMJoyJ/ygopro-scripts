--ホルスの黒炎神
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「荷鲁斯」怪兽以及「王之棺」存在的场合，把手卡的这张卡给对方观看，把自己的手卡·场上1张卡送去墓地才能发动。场上1张卡送去墓地。
-- ②：「荷鲁斯之黑炎神」以外的自己场上的表侧表示的「荷鲁斯」怪兽或「王之棺」因对方的效果从场上离开的场合才能发动。这张卡从手卡特殊召唤。那之后，可以把场上的其他怪兽全部送去墓地。
local s,id,o=GetID()
-- 为这张卡注册效果：包含①的起动效果（将场上1张卡送去墓地）和②的诱发效果（从手卡特殊召唤并可选清场），并登记其记载的卡名「王之棺」。
function s.initial_effect(c)
	-- 记录这张卡的效果文本中记载的「王之棺」（卡号16528181），用于关联判定。
	aux.AddCodeList(c,16528181)
	-- ①：自己场上有「荷鲁斯」怪兽以及「王之棺」存在的场合，把手卡的这张卡给对方观看，把自己的手卡·场上1张卡送去墓地才能发动。场上1张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.tgcon)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.tgcost)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ②：「荷鲁斯之黑炎神」以外的自己场上的表侧表示的「荷鲁斯」怪兽或「王之棺」因对方的效果从场上离开的场合才能发动。这张卡从手卡特殊召唤。那之后，可以把场上的其他怪兽全部送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"这张卡特殊召唤"
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.sscon)
	e2:SetTarget(s.sstg)
	e2:SetOperation(s.ssop)
	c:RegisterEffect(e2)
end
-- 定义过滤器：表侧表示的「荷鲁斯」怪兽（种族系列0x19d）。
function s.tgcfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x19d)
end
-- 定义过滤器：表侧表示的「王之棺」（卡号16528181）。
function s.tgcfilter2(c)
	return c:IsFaceup() and c:IsCode(16528181)
end
-- ①效果的发动条件：自己场上同时存在表侧表示的「荷鲁斯」怪兽和「王之棺」各至少1张。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「荷鲁斯」怪兽。
	return Duel.IsExistingMatchingCard(s.tgcfilter1,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己场上是否存在至少1张表侧表示的「王之棺」。
		and Duel.IsExistingMatchingCard(s.tgcfilter2,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 定义可作为①效果发动代价的卡：该卡本身能被送去墓地，且除该卡外场上还存在至少1张能被效果送去墓地的卡。
function s.costfilter(c)
	return c:IsAbleToGraveAsCost()
		-- 检查除这张候选代价卡外，双方场上存在至少1张可以被效果送去墓地的卡。
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- ①效果发动代价的合法性检查：手牌的这张卡未公开（需给对方观看），且能从自己的手卡·场上选出1张卡作为代价送去墓地。
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 确认从自己的手卡·场上存在至少1张满足代价条件的卡可供选择。
		and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,nil) end
	-- 在代价选择阶段，向操作者显示提示消息“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己的手卡·场上选择1张满足代价条件的卡作为发动代价。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡以代价（REASON_COST）送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ①效果处理：从双方场上选择1张能被效果送去墓地的卡，将其送去墓地；若选择成功，则展示该卡并送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理阶段，提示双方场上的选择消息“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从双方场上的所有卡中选择1张可以被效果送去墓地的卡（不取对象时在效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡向玩家展示，并记录该卡被选为（广义）对象。
		Duel.HintSelection(g)
		-- 将选中的卡以效果（REASON_EFFECT）送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 定义离场卡过滤器：该卡原本由自己控制，因对方的效果被从场上表侧表示离场，且离场前是「荷鲁斯」怪兽（不是本卡）或「王之棺」。
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousPosition(POS_FACEUP)
		and ((c:IsPreviousSetCard(0x19d) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousCodeOnField()~=id) or c:GetPreviousCodeOnField()==16528181)
end
-- ②效果的发动条件：本次因对方的效果从场上离场的卡中，存在满足条件（上述过滤器）的卡。
function s.sscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- ②效果发动时的目标合法性检查：自己场上主要怪兽区有空位，且手牌的这张卡能够特殊召唤。
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的主要怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将特殊召唤效果的操作信息注入连锁，使后续处理（如星尘龙时点等）能正确感知到特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果处理：若这张卡仍与效果相关且成功特殊召唤，则获取场上其他所有怪兽；若存在且玩家选择是，则将这些怪兽全部送去墓地。
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与此效果关联（未被离场/无效），并尝试将其特殊召唤；若特殊召唤成功则继续。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取场上除这张卡以外的所有怪兽（作为可被清场的对象集合）。
		local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,c)
		-- 若场上存在其他怪兽，则询问玩家是否要把它们全部送去墓地。
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把场上的其他怪兽全部送去墓地？"
			-- 中断当前效果处理，使后续的送墓处理作为新的一步进行，以避免错过时点。
			Duel.BreakEffect()
			-- 将选定的其他怪兽全部以效果（REASON_EFFECT）送去墓地。
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end
