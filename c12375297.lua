--燿ける聖詩の獄神精
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：自己·对方的主要阶段，以自己的中央的主要怪兽区域1只怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升3星。那之后，可以进行1只「耀圣」同调怪兽或「调狱神 朱诺拉」的同调召唤。
-- ③：这张卡作为同调素材送去墓地的场合才能发动。从卡组把1张「耀圣」卡加入手卡。
local s,id,o=GetID()
-- 为这张卡注册三个效果：①额外卡组不能特殊召唤非同调怪兽；②主要阶段指定自己中央主要怪兽区域的1只怪兽发动，使其等级到回合结束时上升3星，那之后可选进行「耀圣」同调怪兽或「调狱神 朱诺拉」的同调召唤；③这张卡作为同调素材送去墓地的场合，从卡组把1张「耀圣」卡加入手卡。
function s.initial_effect(c)
	-- 将卡名中记载的「调狱神 朱诺拉」(5914858)加入代码列表，用于相关效果的联动判定。
	aux.AddCodeList(c,5914858)
	-- ①：自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段，以自己的中央的主要怪兽区域1只怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升3星。那之后，可以进行1只「耀圣」同调怪兽或「调狱神 朱诺拉」的同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"等级改变"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.lvcon)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	-- ③：这张卡作为同调素材送去墓地的场合才能发动。从卡组把1张「耀圣」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"检索"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- ①效果的过滤条件：不是同调怪兽且位于额外卡组的怪兽不能特殊召唤。
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- ②效果的发动条件：当前必须处于主要阶段（自己或对方的主要阶段）。
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前是否为主要阶段，用于②效果的发动条件。
	return Duel.IsMainPhase()
end
-- ②效果选择对象的过滤条件：位于自己中央的主要怪兽区域（第3个主要怪兽区）、表侧表示、等级1以上且能成为效果对象的怪兽。
function s.lvfilter(c,e)
	return c:GetSequence()==2 and c:IsFaceup() and c:IsLevelAbove(1)
		and c:IsCanBeEffectTarget(e)
end
-- ②效果发动时选择对象：从自己中央主要怪兽区域选1只符合条件的怪兽；若只有1只则自动设为目标，否则由自己选择1只。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件检测：确认自己场上中央主要怪兽区存在至少1只可选的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,nil,e) end
	-- 取得满足选择条件的所有候选怪兽组成的组。
	local g=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE,0,nil,e)
	if g:GetCount()==1 then
		-- 当候选只有1只时，直接将该卡设为效果对象。
		Duel.SetTargetCard(g)
	else
		-- 显示“请选择表侧表示的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 让玩家从符合条件的怪兽中选择1只，并将其设为效果对象。
		Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil,e)
	end
end
-- 额外卡组中可进行同调召唤的过滤条件：卡名含「耀圣」字段或是「调狱神 朱诺拉」的同调怪兽，且满足同调召唤手续条件。
function s.syncfilter(c,tp)
	return (c:IsSetCard(0x1d8) or c:IsCode(5914858)) and c:IsType(TYPE_SYNCHRO) and c:IsSynchroSummonable(nil)
end
-- ②效果处理：对象怪兽等级上升3星；之后可进行1只「耀圣」同调怪兽或「调狱神 朱诺拉」的同调召唤。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() and not tc:IsImmuneToEffect(e) then
		-- 那只怪兽的等级直到回合结束时上升3星。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(3)
		tc:RegisterEffect(e1)
		-- 立即刷新场地信息，使后续同调召唤条件基于已上升后的等级进行判断。
		Duel.AdjustAll()
		-- 检查额外卡组是否存在可同调召唤的符合条件的怪兽，并询问玩家是否进行同调召唤。
		if Duel.IsExistingMatchingCard(s.syncfilter,tp,LOCATION_EXTRA,0,1,nil,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否同调召唤？"
			-- 中断当前效果处理，使之后的同调召唤视为独立处理（避免错过时点）。
			Duel.BreakEffect()
			-- 显示“请选择要特殊召唤的卡”的选择提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家从额外卡组选择1张满足条件的同调怪兽。
			local g=Duel.SelectMatchingCard(tp,s.syncfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
			-- 对选择的同调怪兽执行同调召唤（以场上怪兽为素材）。
			Duel.SynchroSummon(tp,g:GetFirst(),nil)
		end
	end
end
-- ③效果发动条件：这张卡作为同调素材被送去墓地且当前位于墓地。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- ③效果的检索过滤条件：卡组中的「耀圣」卡且能够加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x1d8) and c:IsAbleToHand()
end
-- ③效果发动时检查卡组是否存在「耀圣」卡，并设置将1张卡从卡组加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：确认卡组中存在至少1张「耀圣」卡可以加入手卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：效果处理时将从卡组把1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：从卡组选择1张「耀圣」卡加入手卡，并让对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张符合条件的「耀圣」卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
