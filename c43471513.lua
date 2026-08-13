--コンベックス・ナイト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，场上有机械族怪兽存在的场合才能发动。这张卡守备表示特殊召唤。那之后，可以把这张卡的等级变成和场上1只机械族怪兽的等级·阶级的数值相同。
-- ②：自己主要阶段才能发动。从卡组把1只机械族·地属性怪兽送去墓地。那之后，这张卡的攻击力直到回合结束时上升送去墓地的怪兽的等级×100。
local s,id,o=GetID()
-- 为钢卷尺骑士注册两个起动效果：效果1在手牌发动，将自己表侧守备特殊召唤并可选变更等级；效果2在场上发动，从卡组把机械族·地属性怪兽送去墓地并提升攻击力，两个效果1回合各能使用1次。
function s.initial_effect(c)
	-- ①：这张卡在手卡存在，场上有机械族怪兽存在的场合才能发动。这张卡守备表示特殊召唤。那之后，可以把这张卡的等级变成和场上1只机械族怪兽的等级·阶级的数值相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从卡组把1只机械族·地属性怪兽送去墓地。那之后，这张卡的攻击力直到回合结束时上升送去墓地的怪兽的等级×100。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选场上表侧表示、机械族、怪兽卡，并且在传入等级lv时，该怪兽的等级或阶级中至少有一个与lv不同（用于选择可变更等级的目标）。
function s.mcmfilter(c,lv)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_MONSTER)
		and (not lv or c:GetLevel()>0 and c:GetLevel()~=lv or c:GetRank()>0 and c:GetRank()~=lv)
end
-- 效果1的发动条件：场上存在至少1只表侧表示的机械族怪兽（不要求等级与lv不同，因为此处未传lv）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方怪兽区是否存在至少1只表侧表示的机械族怪兽，以满足“场上有机械族怪兽存在”的发动条件。
	return Duel.IsExistingMatchingCard(s.mcmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 效果1的目标条件：发起发动时，检查自己场上是否有可用怪兽区，并且手牌中的这张卡能否以表侧守备表示被特殊召唤（不无视召唤条件和苏生限制）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区空格，作为特殊召唤的前提条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：声明本次效果处理将把这张卡进行特殊召唤，对象确定为本卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果1处理：先确认本卡仍与连锁相关且在手牌，然后将其表侧守备特殊召唤；若成功，则从场上表侧机械族怪兽中选出等级/阶级与本卡当前等级不同的怪兽，经玩家确认后选择1只，通过中断效果处理将本卡等级变为所选怪兽的等级（超量怪兽则变为阶级）。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 将手牌中的这张卡以表侧守备表示特殊召唤到自己场上，若特殊召唤成功（返回值不为0）则继续后续处理。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 获取场上表侧机械族怪兽中，等级或阶级与本卡当前等级不同的怪兽集合，作为可选变更等级的目标。
		local g=Duel.GetMatchingGroup(s.mcmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,c:GetLevel())
		-- 若存在可选目标且玩家选择“是”，则询问玩家是否要变更等级。
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否改变等级？"
			-- 显示卡片选择提示，让玩家从表侧表示怪兽中选择1张。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
			local tg=g:Select(tp,1,1,nil)
			if tg:GetCount()>0 then
				-- 中断当前效果处理，使后续的等级变更作为不同的处理时机，避免错过特殊召唤成功时的时点。
				Duel.BreakEffect()
				-- 手动显示所选怪兽被选中的动画，并记录该卡被选择为对象（广义）。
				Duel.HintSelection(tg)
				local tc=tg:GetFirst()
				local lv=tc:GetLevel()
				if tc:IsType(TYPE_XYZ) then
					lv=tc:GetRank()
				end
				-- 那之后，可以把这张卡的等级变成和场上1只机械族怪兽的等级·阶级的数值相同。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetValue(lv)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
				c:RegisterEffect(e1)
			end
		end
	end
end
-- 过滤函数：筛选卡组中为机械族、地属性、怪兽卡且能够送去墓地的卡片，用于效果2的送墓对象。
function s.tgfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果2的目标条件：发动时检查卡组是否存在至少1张符合条件的机械族·地属性怪兽；满足则设置操作信息，预宣告本次效果将把卡组1张卡送去墓地。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张机械族·地属性且能送去墓地的怪兽卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：声明本次效果处理将会把卡组中的1张卡送去墓地（处理时选择，不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果2处理：从卡组选择1只机械族·地属性怪兽送去墓地；若成功且本卡仍在场上表侧表示且与连锁相关，则中断效果处理，为本卡附加攻击力上升效果，上升数值为送墓怪兽等级×100直到回合结束。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示选择提示，让玩家选择1张要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1张满足条件的机械族·地属性怪兽送去墓地。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选择的卡以效果原因送去墓地；若实际送入成功且该卡在墓地，则继续处理攻击力上升。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		local lv=tc:GetLevel()
		if lv>0 and c:IsFaceup() and c:IsRelateToChain() then
			-- 中断当前效果处理，使攻击力上升作为独立处理步骤，避免时点问题。
			Duel.BreakEffect()
			-- 那之后，这张卡的攻击力直到回合结束时上升送去墓地的怪兽的等级×100。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(lv*100)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end
