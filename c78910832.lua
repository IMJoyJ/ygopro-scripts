--ビック・バイパー Type－L
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己战斗阶段开始时，可以从以下效果选择1个发动。
-- ●从手卡把1只机械族怪兽特殊召唤。
-- ●从卡组把1只4星以下的机械族·光属性怪兽送去墓地。
-- ②：这张卡被破坏的场合，以自己墓地1只机械族·光属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果把原本攻击力是1200以下的怪兽特殊召唤的场合，那个攻击力上升1200。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（战斗阶段开始时选择发动）和②效果（被破坏时特殊召唤墓地怪兽）。
function s.initial_effect(c)
	-- ①：自己战斗阶段开始时，可以从以下效果选择1个发动。●从手卡把1只机械族怪兽特殊召唤。●从卡组把1只4星以下的机械族·光属性怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"选择效果"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被破坏的场合，以自己墓地1只机械族·光属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果把原本攻击力是1200以下的怪兽特殊召唤的场合，那个攻击力上升1200。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定函数，检查当前是否为自己的回合。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己。
	return Duel.GetTurnPlayer()==tp
end
-- 过滤手卡中可以特殊召唤的机械族怪兽。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤卡组中可以送去墓地的4星以下的机械族·光属性怪兽。
function s.tgfilter(c)
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c:IsAbleToGrave()
end
-- ①效果的发动准备与目标选择函数，让玩家选择要发动的子效果并设置相应的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在可以特殊召唤的机械族怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	-- 检查卡组中是否存在可以送去墓地的4星以下机械族·光属性怪兽。
	local b2=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家从可用的选项中选择一个效果发动。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"特殊召唤"
			{b2,aux.Stringid(id,3),2})  --"送去墓地"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		end
		-- 设置连锁信息，表示该效果包含从手卡特殊召唤1只怪兽的操作。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TOGRAVE)
		end
		-- 设置连锁信息，表示该效果包含从卡组将1张卡送去墓地的操作。
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end
end
-- ①效果的处理函数，根据玩家选择的子效果，执行特殊召唤或送去墓地的操作。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 检查自己场上是否有可用的怪兽区域空格。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 提示玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家从手卡选择1只满足条件的机械族怪兽。
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家从卡组选择1只满足条件的4星以下机械族·光属性怪兽。
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽因效果送去墓地。
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
-- 过滤墓地中可以特殊召唤的机械族·光属性怪兽。
function s.spfilter2(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动准备与目标选择函数，确认墓地中存在合法的机械族·光属性怪兽并将其作为效果对象。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter2(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以作为效果对象的机械族·光属性怪兽。
		and Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己墓地1只满足条件的机械族·光属性怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表示该效果包含特殊召唤所选对象怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的处理函数，将作为对象的怪兽特殊召唤，若其原本攻击力在1200以下，则使其攻击力上升1200。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与连锁相关，且不受王家长眠之谷的影响。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc)
		-- 尝试将对象怪兽以表侧表示特殊召唤到自己场上。
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)~=0
		and tc:GetBaseAttack()<=1200 then
		-- 这个效果把原本攻击力是1200以下的怪兽特殊召唤的场合，那个攻击力上升1200。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤的后续处理。
	Duel.SpecialSummonComplete()
end
