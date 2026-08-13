--蹴神－VARefar
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己场上的怪兽成为对方场上的怪兽的效果的对象时或者被选择作为对方怪兽的攻击对象时才能发动。这张卡从手卡特殊召唤。那之后，可以选那1只对方怪兽并把1张手卡给对方观看。那个场合，再让给人观看的卡种类的以下效果对选的怪兽适用。
-- ●怪兽：变成守备表示。
-- ●魔法：攻击力变成2倍。
-- ●陷阱：除外。
local s,id,o=GetID()
-- 创建并注册该卡的两个诱发即时效果：e1对应被对方怪兽选为攻击对象时发动，e2对应自己场上怪兽成为对方场上怪兽效果对象时发动；均从手卡发动，设定同卡名效果1回合只能使用1次，并分别设置条件、发动时处理和效果处理函数。
function s.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：自己场上的怪兽成为对方场上的怪兽的效果的对象时或者被选择作为对方怪兽的攻击对象时才能发动。这张卡从手卡特殊召唤。那之后，可以选那1只对方怪兽并把1张手卡给对方观看。那个场合，再让给人观看的卡种类的以下效果对选的怪兽适用。●怪兽：变成守备表示。●魔法：攻击力变成2倍。●陷阱：除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 判定是否满足“自己场上的怪兽被对方怪兽选择为攻击对象”的发动条件。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前被攻击的怪兽（攻击对象）。
	local at=Duel.GetAttackTarget()
	-- 返回判定结果：攻击方为对方怪兽且攻击对象为自己场上的怪兽。
	return Duel.GetAttacker():IsControler(1-tp) and at:IsControler(tp)
end
-- 定义过滤器：筛选位于自己场怪兽区且由自己控制的怪兽，即己方场上的怪兽。
function s.cfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 判定是否满足“自己场上的怪兽成为对方场上的怪兽的效果的对象”的发动条件：对方发动的是取对象的怪兽效果，且对象中包含己方场上怪兽，且该效果在场上发动。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	if rp~=1-tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 取得对方那次效果的取对象卡片组（被作为对象的所有卡）。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 取得对方那次效果的发动位置。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return (loc&LOCATION_ONFIELD)~=0 and re:IsActiveType(TYPE_MONSTER) and g and g:IsExists(s.cfilter,1,nil,tp)
end
-- 诱发即时效果发动时点检查：自己场上怪兽区有空位，且此卡可从手卡特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 获取攻击怪兽（对方怪兽），作为本效果选定的对象。
	local ac=Duel.GetAttacker()
	-- 将那只攻击怪兽设置为本效果的对象（取对象）。
	Duel.SetTargetCard(ac)
	-- 设置操作信息，预告本效果将把此卡特殊召唤，用于连锁检测等。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义可展示手卡的过滤器：手牌非公开，且根据卡种类（怪兽/魔法/陷阱）能对对象怪兽产生对应效果（变守备/翻倍攻击/除外）时才可选。
function s.cfilter2(c,ac)
	return not c:IsPublic()
		and (c:IsType(TYPE_MONSTER) and ac:IsCanChangePosition() and ac:IsPosition(POS_ATTACK)
		or c:IsType(TYPE_SPELL) and ac:IsFaceup()
		or c:IsType(TYPE_TRAP) and ac:IsAbleToRemove())
end
-- 处理攻击对象时效果：特殊召唤此卡；成功后取得对象怪兽并进入展示手卡及适用分支效果的共通处理。
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡仍与连锁相关且特殊召唤成功，才继续后续处理。
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 取得效果对象（那只攻击怪兽）。
		local ac=Duel.GetFirstTarget()
		if ac and ac:IsRelateToChain() and ac:IsType(TYPE_MONSTER) then
			s.cfop(e,tp,eg,ep,ev,re,r,rp,ac)
		end
	end
end
-- 诱发即时效果发动时点检查（取对象触发分支）：自己场上怪兽区有空位，且此卡可从手卡特殊召唤。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将对方发动效果的那只怪兽设置为本效果的对象（即“那1只对方怪兽”）。
	Duel.SetTargetCard(re:GetHandler())
	-- 设置操作信息，预告本效果将把此卡特殊召唤，用于连锁检测等。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理对方怪兽效果取对象时发动：特殊召唤此卡；成功后取得对象怪兽并进入共用后续处理。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡仍与连锁相关且特殊召唤成功，才继续后续处理。
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 取得效果对象（那只对方怪兽）。
		local ac=Duel.GetFirstTarget()
		if ac and ac:IsRelateToChain() and ac:IsType(TYPE_MONSTER) then
			s.cfop(e,tp,eg,ep,ev,re,r,rp,ac)
		end
	end
end
-- 共用后续处理：从手卡选择一张符合条件的卡给对方观看，并依据其卡片种类对对象怪兽适用对应效果（怪兽→表侧守备、魔法→攻击力变为2倍、陷阱→除外）。
function s.cfop(e,tp,eg,ep,ev,re,r,rp,ac)
	-- 从自己手卡中筛选出所有能对对象怪兽适用分支效果的卡。
	local g=Duel.GetMatchingGroup(s.cfilter2,tp,LOCATION_HAND,0,nil,ac)
	if not ac:IsLocation(LOCATION_MZONE) or not ac:IsControler(1-tp) then return end
	-- 若存在可选手卡，则询问玩家是否选择给对方观看手卡。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否给对方观看手卡？"
		-- 中断当前效果处理，使后续展示手卡与效果适用按不同时点处理，避免错过时点。
		Duel.BreakEffect()
		-- 展示对象怪兽被选中/处理的动画提示，并记录该卡为本效果处理中的对象。
		Duel.HintSelection(Group.FromCards(ac))
		-- 给出选择手卡提示，要求玩家选择一张手卡给对方确认。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local tc=g:Select(tp,1,1,nil):GetFirst()
		-- 将选择的手卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
		-- 洗切自己的手卡，避免对方从手牌顺序获知信息。
		Duel.ShuffleHand(tp)
		if tc:IsType(TYPE_MONSTER) then
			-- 将对象怪兽变为表侧守备表示（对应展示怪兽卡的场合）。
			Duel.ChangePosition(ac,POS_FACEUP_DEFENSE)
		elseif tc:IsType(TYPE_SPELL) then
			-- ●魔法：攻击力变成2倍。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(ac:GetAttack()*2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			ac:RegisterEffect(e1)
		elseif tc:IsType(TYPE_TRAP) then
			-- 将对象怪兽表侧除外（对应展示陷阱卡的场合）。
			Duel.Remove(ac,POS_FACEUP,REASON_EFFECT)
		end
	end
end
