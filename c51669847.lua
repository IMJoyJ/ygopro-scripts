--絶無なる獄神界－ヴィードリア
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把额外卡组1只「狱神」怪兽给对方观看才能发动。选自己1张手卡里侧除外。那之后，从卡组选有给人观看的怪兽的卡名记述的1只怪兽加入手卡或特殊召唤。
-- ②：对方场上的怪兽的攻击力下降除外状态的卡数量×100。
-- ③：只要自己场上有「创狱神 涅瓦」「坏狱神 朱庇特」「调狱神 朱诺拉」全部存在，对方不能把墓地的卡的效果发动。
local s,id,o=GetID()
-- 注册该卡全部效果：魔法卡发动的框架效果、①的除外手卡并检索/特召效果、②降低对方怪兽攻击力的永续效果、③封锁对方墓地效果发动的永续效果。
function s.initial_effect(c)
	-- 将「创狱神 涅瓦」「坏狱神 朱庇特」「调狱神 朱诺拉」的卡号登记为这张卡文本中记述的卡名，用于③效果中判定场上是否存在这三只怪兽。
	aux.AddCodeList(c,53589300,68231287,5914858)
	-- （对应『①：把额外卡组1只「狱神」怪兽给对方观看才能发动。』中的发动动作；此处注册场地魔法卡自身的发动）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：把额外卡组1只「狱神」怪兽给对方观看才能发动。选自己1张手卡里侧除外。那之后，从卡组选有给人观看的怪兽的卡名记述的1只怪兽加入手卡或特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：对方场上的怪兽的攻击力下降除外状态的卡数量×100。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(s.value1)
	c:RegisterEffect(e3)
	-- ③：只要自己场上有「创狱神 涅瓦」「坏狱神 朱庇特」「调狱神 朱诺拉」全部存在，对方不能把墓地的卡的效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(0,1)
	e4:SetCondition(s.actcon)
	e4:SetValue(s.aclimit)
	c:RegisterEffect(e4)
end
-- 计算对方场上怪兽攻击力下降的数值：以该怪兽控制者为视角的双方除外区卡牌总数乘以-100，返回负值表示下降。
function s.value1(e,c)
	-- 取以该怪兽控制者为视角的双方除外区卡牌总数并乘以-100，作为攻击力下降数值。
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_REMOVED,LOCATION_REMOVED)*(-100)
end
-- 筛选额外卡组中可展示的「狱神」怪兽，要求卡组中存在“记述该怪兽卡名”且能满足加入手卡或特殊召唤条件的怪兽，作为①效果发动的展示候选。
function s.cfilter(c,e,tp)
	-- 判断该额外怪兽属于「狱神」字段，并确认卡组中存在以该怪兽卡名为记述的、可检索或特殊召唤的怪兽。
	return c:IsSetCard(0x1ce) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
-- 定义①效果中卡组的检索/特召目标：必须满足文本中记载了展示怪兽的卡名、是怪兽卡，且能够加入手卡或特殊召唤。
function s.thfilter(c,e,tp,cid)
	-- 若目标卡不是怪兽或文本中没有记载展示怪兽的卡名，则排除该目标。
	if not (aux.IsCodeListed(c,cid) and c:IsType(TYPE_MONSTER)) then return false end
	-- 获取自己场上可用的主要怪兽区域数量，用于判断目标怪兽能否特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 筛选自己手卡中可被里侧除外的卡（满足里侧除外条件）。
function s.rmfilter(c,tp)
	return c:IsAbleToRemove(tp,POS_FACEDOWN)
end
-- 效果发动条件检查：额外卡组存在可展示的「狱神」怪兽，且手卡存在可里侧除外的卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动条件检查的第一部分：额外卡组中是否存在满足展示条件的「狱神」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		-- 效果发动条件检查的第二部分：手卡中是否存在可里侧除外的卡。
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 取得额外卡组中所有满足条件的「狱神」怪兽集合，供玩家选择一张进行展示。
	local exg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	-- 显示选择提示“请选择给对方确认的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local fc=exg:Select(tp,1,1,nil):GetFirst()
	e:SetLabel(fc:GetCode())
	-- 将玩家选择的「狱神」怪兽给对方玩家确认。
	Duel.ConfirmCards(1-tp,fc)
	-- 设置操作信息：本次效果将要把手卡中的1张卡里侧除外，用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
end
-- ①效果处理：先从手卡选1张里侧除外；成功后从卡组选1只“记述展示怪兽卡名”的怪兽，让玩家选择加入手卡或特殊召唤。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local cid=e:GetLabel()
	-- 显示选择提示“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从手卡中选择1张满足里侧除外条件的卡。
	local rg=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	local rc=rg:GetFirst()
	-- 若选择的卡已被里侧除外成功且当前位于除外区，则继续后续检索/特召处理。
	if rc and Duel.Remove(rc,POS_FACEDOWN,REASON_EFFECT)>0 and rc:IsLocation(LOCATION_REMOVED) then
		-- 显示选择提示“请选择要操作的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 从卡组中选择1张满足条件的怪兽（文本中记述了展示怪兽卡名且可加入手卡或特殊召唤）。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,cid)
		local tc=g:GetFirst()
		-- 获取可用怪兽区域数量，用于判断能否特殊召唤。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if tc then
			-- 中断当前效果处理，使后续的加入手卡/特殊召唤处理与前一步除外处理错开时点，避免错过时点。
			Duel.BreakEffect()
			local spchk=tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and ft>0
			-- 若目标怪兽可加入手卡，并且（不能特殊召唤或玩家选择“加入手卡”选项），则选择加入手卡；否则进入特殊召唤分支。
			if tc:IsAbleToHand() and (not spchk or Duel.SelectOption(tp,1190,1152)==0) then
				-- 将目标怪兽加入手卡。
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				-- 向对方确认加入手卡的怪兽。
				Duel.ConfirmCards(1-tp,tc)
			elseif spchk then
				-- 将目标怪兽以表侧表示特殊召唤到自己场上。
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 筛选场上表侧表示且卡号等于指定卡号的怪兽，用于③条件中检测特定怪兽。
function s.cofilter(c,cid)
	return c:IsFaceup() and c:IsCode(cid)
end
-- ③效果适用条件：自己场上同时存在「创狱神 涅瓦」「坏狱神 朱庇特」「调狱神 朱诺拉」三只怪兽。
function s.actcon(e)
	-- 检测自己场上是否存在表侧表示的「创狱神 涅瓦」（卡号53589300）。
	return Duel.IsExistingMatchingCard(s.cofilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil,53589300)
		-- 检测自己场上是否存在表侧表示的「坏狱神 朱庇特」（卡号68231287）。
		and Duel.IsExistingMatchingCard(s.cofilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil,68231287)
		-- 检测自己场上是否存在表侧表示的「调狱神 朱诺拉」（卡号5914858）。
		and Duel.IsExistingMatchingCard(s.cofilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil,5914858)
end
-- ③效果的禁止条件：对方发动效果的位置为墓地，即禁止对方从墓地发动卡的效果。
function s.aclimit(e,re,tp)
	return re:GetActivateLocation()==LOCATION_GRAVE
end
