--プティカの蟲惑魔
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤成功时才能发动。从卡组把1张「虫惑之园」加入手卡。
-- ②：这张卡特殊召唤成功的场合，以对方场上1只特殊召唤的怪兽为对象才能发动。那只怪兽除外。下次的准备阶段，对方可以选除外的1只自身怪兽特殊召唤。
-- ③：这张卡只要在怪兽区域存在，不受「洞」通常陷阱卡以及「落穴」通常陷阱卡的效果影响。
local s,id,o=GetID()
-- 定义普蒂卡之虫惑魔的初始化函数：向卡注册③的陷阱免疫效果、①的召唤检索效果、②的特殊召唤除外并附加准备阶段特殊召唤效果。
function s.initial_effect(c)
	-- 记录这张卡文本中记载了卡名「虫惑之园」（12801833），供关联判定使用。
	aux.AddCodeList(c,12801833)
	-- ③：这张卡只要在怪兽区域存在，不受「洞」通常陷阱卡以及「落穴」通常陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤成功时才能发动。从卡组把1张「虫惑之园」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：这张卡特殊召唤成功的场合，以对方场上1只特殊召唤的怪兽为对象才能发动。那只怪兽除外。下次的准备阶段，对方可以选除外的1只自身怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"怪兽除外"
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
-- 免疫效果的判定函数：检查来源卡是通常陷阱卡，且其字段属于「洞」（0x89）或「落穴」（0x4c），满足条件则本卡不受该效果影响。
function s.efilter(e,te)
	local c=te:GetHandler()
	return c:GetType()==TYPE_TRAP and c:IsSetCard(0x4c,0x89)
end
-- 检索用过滤函数：卡名必须是「虫惑之园」（12801833），且是可以加入手卡的卡。
function s.thfilter(c)
	return c:IsCode(12801833) and c:IsAbleToHand()
end
-- ①效果的发动条件与操作信息设定：发动时确认卡组存在符合条件的「虫惑之园」，并设置将检索卡加入手卡的处理信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前合法性检查（chk==0）时，确认我方卡组存在至少1张可加入手卡的「虫惑之园」，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本连锁的操作信息：本次效果处理将从卡组把1张「虫惑之园」加入持有者手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：让玩家从卡组选择1张「虫惑之园」加入手卡，并向对方展示确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给当前玩家显示选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从玩家卡组中选出1张满足s.thfilter（即「虫惑之园」）的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因送回持有者手卡（nil表示送入持有者手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将刚刚加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果对象过滤：对方怪兽必须是曾通过特殊召唤出场的怪兽，并且可以除外。
function s.rmfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsAbleToRemove()
end
-- ②效果的发动条件与目标选择：选择对方场上1只特殊召唤的怪兽为对象，并设置除外该卡的操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.rmfilter(chkc) end
	-- 发动前合法性检查：确认对方场上存在至少1只可被选为对象的特殊召唤怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择提示：请选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1只满足条件的特殊召唤怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次处理将把1只对象怪兽除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ②效果的处理：先除外取对象怪兽，再为对方注册一个在下次准备阶段可特殊召唤那张除外怪兽的延迟效果。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 把对象怪兽以表侧表示除外，除外原因视为效果。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
	-- 下次的准备阶段，对方可以选除外的1只自身怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	-- 判断当前阶段是否为准备阶段。若是，则延迟效果要延后到下一个准备阶段，避免当回合立即适用。
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 将当前回合数写入延迟效果的标签，用于在准备阶段判断是否已跨过当回合。
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetReset(RESET_PHASE+PHASE_STANDBY,2)
	else
		e1:SetLabel(0)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY)
	end
	-- 将这个准备阶段触发的延迟效果注册给对方玩家（1-tp）。
	Duel.RegisterEffect(e1,1-tp)
end
-- 特殊召唤的过滤函数：检查除外怪兽是否可以被对方玩家特殊召唤（不检查召唤条件与苏生限制）。
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 准备阶段延迟效果的触发条件：不是发动当回合、对方场上有空位、且对方除外区存在可特殊召唤的自身怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件前半：当前回合数不是记录回合数（已到下一个准备阶段），并且对方场上的怪兽区域有空位。
	return Duel.GetTurnCount()~=e:GetLabel() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 条件后半：对方除外区存在至少1张满足s.spfilter的怪兽，确保有可特殊召唤的对象。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
end
-- 延迟效果处理：询问对方是否特殊召唤除外怪兽，并选择1只自身怪兽特殊召唤到其场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方展示普蒂卡之虫惑魔的卡片动画，提示这是该卡效果的进一步处理。
	Duel.Hint(HINT_CARD,0,id)
	-- 询问对方玩家：是否选除外的1只怪兽特殊召唤？
	if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否选除外的1只怪兽特殊召唤？"
		-- 提示对方选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从对方除外区选择1张满足s.spfilter的怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到对方场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
