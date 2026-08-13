--竜葬主－ヴィブリアル
-- 效果：
-- ①：怪兽在主要阶段从对方场上送去墓地的场合，可以把以这张卡在哪里存在来对应的以下效果发动（这个卡名的以下效果1回合各能使用1次）。
-- ●手卡：这张卡特殊召唤。
-- ●场上：对方场上1只效果怪兽的攻击力下降1500。这个效果让攻击力变成0的场合，可以再把那只怪兽破坏。
-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
local s,id,o=GetID()
-- 注册②战斗破坏耐性效果e1，以及①对应的两个位置触发效果：e2为手卡时特殊召唤自身，e3为场上时降低对方效果怪兽攻击力并可追加破坏；e2和e3共用同一触发条件但分别限定在各自位置，且各1回合1次。
function s.initial_effect(c)
	-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ●手卡：这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ●场上：对方场上1只效果怪兽的攻击力下降1500。这个效果让攻击力变成0的场合，可以再把那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.adtg)
	e3:SetOperation(s.adop)
	c:RegisterEffect(e3)
end
-- ②效果的目标筛选：只有这张卡自身以及这张卡进行战斗的对方怪兽，才适用不会被那次战斗破坏的耐性。
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- 筛选用于触发①的怪兽：该怪兽之前位于怪兽区，且之前的控制者是对方玩家（即从对方场上送去墓地）。
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(1-tp)
end
-- ①效果的触发条件：当前处于主要阶段1或主要阶段2，且本次送去墓地的怪兽中存在满足s.cfilter的卡。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于判断是否为主要阶段。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and eg:IsExists(s.cfilter,1,nil,tp)
end
-- 手卡效果的发动条件：自己场上主要怪兽区有空位，且这张卡本身可以被特殊召唤（不检查苏生限制）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认自己主要怪兽区是否有空余格子，若没有则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，声明本效果包含特殊召唤，对象为发动效果的手卡中的这张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 手卡效果处理：若这张卡仍与效果关联（未离场或其他原因导致联系重置），则将其特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧攻击表示特殊召唤到自己的主要怪兽区，不经过召唤手续且无视苏生限制。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 场上效果选择对象的筛选条件：怪兽必须是表侧表示且为效果怪兽。
function s.adfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 场上效果的发动条件：对方场上存在至少1只满足adfilter的表侧效果怪兽可选。
function s.adtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查对方场上是否存在表侧表示的效果怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.adfilter,tp,0,LOCATION_MZONE,1,nil) end
end
-- 场上效果处理：选择对方场上1只表侧效果怪兽，令其攻击力下降1500；若该怪兽原攻击力不为0且下降后攻击力变为0，则询问玩家是否将其破坏，确认后破坏。
function s.adop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送选择提示消息，让玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从对方场上选择1只表侧表示的效果怪兽作为效果对象。
	local g=Duel.SelectMatchingCard(tp,s.adfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		-- 为选中的怪兽显示被选为对象的动画，并记录其作为本次效果的对象。
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		local preatk=tc:GetAttack()
		-- 对方场上1只效果怪兽的攻击力下降1500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 判断是否满足追加破坏条件：所选怪兽的原攻击力不为0，且效果处理后攻击力变为0，同时玩家选择“是”才进行破坏。
		if preatk~=0 and tc:IsAttack(0) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把那只怪兽破坏？"
			-- 中断当前效果处理，使后续的破坏作为另一次独立处理（错开时点，避免与攻击力下降同时处理）。
			Duel.BreakEffect()
			-- 将满足条件的对象怪兽以卡牌效果破坏并送去墓地。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
