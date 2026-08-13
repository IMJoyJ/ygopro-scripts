--レスキューラット
-- 效果：
-- ←5 【灵摆】 5→
-- 「救援鼠」的灵摆效果在决斗中只能使用1次。
-- ①：把自己的灵摆区域的这张卡除外才能发动。从自己的额外卡组把2只表侧表示的同名灵摆怪兽加入手卡。
-- 【怪兽效果】
-- ①：这张卡召唤成功的回合，自己的额外卡组有表侧表示的5星以下的灵摆怪兽存在的场合，把这张卡解放才能发动。从自己的额外卡组选1只表侧表示的5星以下的灵摆怪兽，从卡组把那2只同名怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
function c50485594.initial_effect(c)
	-- 为救援鼠启用灵摆怪兽属性（具备灵摆召唤、灵摆卡发动等能力）。
	aux.EnablePendulumAttribute(c)
	-- 「救援鼠」的灵摆效果在决斗中只能使用1次。①：把自己的灵摆区域的这张卡除外才能发动。从自己的额外卡组把2只表侧表示的同名灵摆怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50485594,0))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,50485594+EFFECT_COUNT_CODE_DUEL)
	e2:SetCost(c50485594.thcost)
	e2:SetTarget(c50485594.thtg)
	e2:SetOperation(c50485594.thop)
	c:RegisterEffect(e2)
	-- 这张卡召唤成功的回合。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c50485594.regop)
	c:RegisterEffect(e3)
	-- ①：这张卡召唤成功的回合，自己的额外卡组有表侧表示的5星以下的灵摆怪兽存在的场合，把这张卡解放才能发动。从自己的额外卡组选1只表侧表示的5星以下的灵摆怪兽，从卡组把那2只同名怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(50485594,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(c50485594.spcost)
	e4:SetCondition(c50485594.spcon)
	e4:SetTarget(c50485594.sptg)
	e4:SetOperation(c50485594.spop)
	c:RegisterEffect(e4)
end
-- 作为灵摆效果发动的代价，判定并执行将自己灵摆区域的这张卡除外。
function c50485594.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将灵摆区域的这张卡以表侧表示除外，作为发动代价（REASON_COST）。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤额外卡组中表侧表示、属于灵摆怪兽且能够加入手卡的卡。
function c50485594.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 检查候选组中是否存在与当前卡卡号相同的另一张卡，以确保能凑出一对同名灵摆怪兽。
function c50485594.filter2(c,g)
	return g:IsExists(Card.IsCode,1,c,c:GetCode())
end
-- 灵摆效果发动前的条件检查：额外卡组存在至少一对符合条件的同名灵摆怪兽；并设置操作信息为从额外卡组将2张卡加入手牌。
function c50485594.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 取得我方额外卡组中满足灵摆检索条件（表侧表示、灵摆怪兽、可加入手牌）的全部卡。
		local g=Duel.GetMatchingGroup(c50485594.filter,tp,LOCATION_EXTRA,0,nil)
		return g:IsExists(c50485594.filter2,1,nil,g)
	end
	-- 设置本次效果处理时，将2张卡从额外卡组加入手牌的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_EXTRA)
end
-- 灵摆效果处理：从符合条件的额外卡组中选取1张，自动取得其同名卡（共2张），将它们加入手牌并向对方展示。
function c50485594.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得额外卡组中所有符合条件的表侧表示灵摆怪兽，用于效果处理。
	local g=Duel.GetMatchingGroup(c50485594.filter,tp,LOCATION_EXTRA,0,nil)
	local sg=g:Filter(c50485594.filter2,nil,g)
	if sg:GetCount()==0 then return end
	-- 弹出提示，让玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local hg1=sg:Select(tp,1,1,nil)
	local hg2=sg:Filter(Card.IsCode,hg1:GetFirst(),hg1:GetFirst():GetCode())
	hg1:AddCard(hg2:GetFirst())
	-- 将选中的2张同名灵摆怪兽加入其持有者的手卡。
	Duel.SendtoHand(hg1,nil,REASON_EFFECT)
	-- 向对方玩家展示这2张加入手卡的卡，完成公开确认。
	Duel.ConfirmCards(1-tp,hg1)
end
-- 本卡召唤成功时，为本卡注册一个直到回合结束的标记，记录“召唤成功的回合”这一状态。
function c50485594.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(50485594,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
end
-- 怪兽效果发动条件：本卡在本回合（召唤成功回合）内，存在对应的召唤成功标记。
function c50485594.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(50485594)~=0
end
-- 作为怪兽效果发动的代价，判定并执行解放此卡。
function c50485594.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放此卡，作为发动代价（REASON_COST）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选额外卡组中表侧表示、5星以下且为灵摆怪兽的卡，同时要求卡组中存在至少2张同卡名且可特殊召唤的怪兽。
function c50485594.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsLevelBelow(5)
		-- 确认卡组中存在至少2张与候选怪兽同卡名且能被特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c50485594.spfilter2,tp,LOCATION_DECK,0,2,nil,c:GetCode(),e,tp)
end
-- 判断卡组中的卡是否与指定卡号相同，且可以被玩家通过效果特殊召唤（不检查苏生限制）。
function c50485594.spfilter2(c,code,e,tp)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 怪兽效果发动条件判定：若青眼精灵龙的效果适用（禁止双方同时特召2只以上怪兽）则不能发动；同时需要己方主怪兽区有空格，且额外卡组存在符合条件的灵摆怪兽。
function c50485594.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查己方主怪兽区是否至少存在1个可用区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查额外卡组中是否存在至少1只满足特殊召唤筛选条件（spfilter）的灵摆怪兽。
		and Duel.IsExistingMatchingCard(c50485594.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果将从卡组特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 怪兽效果处理：先再次确认青眼精灵龙不在场且主怪兽区有2个以上空格；从额外卡组选择1只符合条件的灵摆怪兽，再从卡组选出2张其同名怪兽依次特殊召唤，并给这些怪兽附加效果无效化，同时注册结束阶段将其破坏的效果。
function c50485594.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 若己方主怪兽区的可用空格不足2个，则无法特殊召唤2只怪兽，效果处理中止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 弹出提示，让玩家选择额外卡组中表侧表示的灵摆怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从额外卡组选择1只符合条件的表侧表示灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c50485594.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()==0 then return end
	local code=g:GetFirst():GetCode()
	-- 从卡组中取得所有与所选怪兽同卡名且可被特殊召唤的怪兽（预计有2张）。
	local dg=Duel.GetMatchingGroup(c50485594.spfilter2,tp,LOCATION_DECK,0,nil,code,e,tp)
	if dg:GetCount()>1 then
		local c=e:GetHandler()
		local fid=c:GetFieldID()
		-- 弹出提示，让玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg1=dg:Select(tp,1,1,nil)
		local tc1=sg1:GetFirst()
		local sg2=dg:Filter(Card.IsCode,tc1,tc1:GetCode())
		local tc2=sg2:GetFirst()
		-- 连续特殊召唤的一步：将第一只同名怪兽以表侧攻击表示特殊召唤到己方场上。
		Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP)
		-- 连续特殊召唤的一步：将第二只同名怪兽以表侧攻击表示特殊召唤到己方场上。
		Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)
		tc1:RegisterFlagEffect(50485594,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		tc2:RegisterFlagEffect(50485594,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 结束连续特殊召唤的处理，完成本次特殊召唤。
		Duel.SpecialSummonComplete()
		sg1:Merge(sg2)
		sg1:KeepAlive()
		-- 结束阶段破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(sg1)
		e1:SetCondition(c50485594.descon)
		e1:SetOperation(c50485594.desop)
		-- 将上述结束阶段破坏的诱发效果注册到场上的效果列表中，使其在结束阶段判定并执行。
		Duel.RegisterEffect(e1,tp)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e2)
		local e3=e2:Clone()
		tc2:RegisterEffect(e3)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_DISABLE_EFFECT)
		e4:SetValue(RESET_TURN_SET)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e4)
		local e5=e4:Clone()
		tc2:RegisterEffect(e5)
	end
end
-- 判断怪兽是否带有本次特殊召唤时赋予的标记（字段ID），用于锁定本效果处理的对象。
function c50485594.desfilter(c,fid)
	return c:GetFlagEffectLabel(50485594)==fid
end
-- 结束阶段的破坏条件判定：若场上仍存在带有对应标记的特召怪兽，则执行破坏；否则终止并清除该效果。
function c50485594.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c50485594.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段破坏处理：取出所有带有对应标记的特召怪兽，将其破坏。
function c50485594.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c50485594.desfilter,nil,e:GetLabel())
	-- 以效果破坏这些被本效果特殊召唤的怪兽。
	Duel.Destroy(tg,REASON_EFFECT)
end
