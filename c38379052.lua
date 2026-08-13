--ARG☆S－屠龍のエテオ
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的战士族怪兽不会被效果破坏。
-- ②：1回合1次，对方把效果发动时才能发动。这张卡变成持有以下效果的效果怪兽（战士族·光·4星·攻/守800）在怪兽区域特殊召唤（也当作陷阱卡使用）。自己的「阿尔戈☆群星」怪兽除外中的场合，可以再让场上1张卡回到手卡。
-- ●自己·对方回合1次，可以发动。这张卡在自己的魔法与陷阱区域表侧表示放置。
local s,id,o=GetID()
-- 创建并注册4个效果：e1允许此卡作为魔陷发动；e2对应①的战士族不被效果破坏；e3对应②的对方发动效果时特召为怪兽并可追加回手；e4对应●的自己·对方回合把自己放回魔陷区。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的战士族怪兽不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indfilter)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：1回合1次，对方把效果发动时才能发动。这张卡变成持有以下效果的效果怪兽（战士族·光·4星·攻/守800）在怪兽区域特殊召唤（也当作陷阱卡使用）。自己的「阿尔戈☆群星」怪兽除外中的场合，可以再让场上1张卡回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ●自己·对方回合1次，可以发动。这张卡在自己的魔法与陷阱区域表侧表示放置。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"表侧表示放置"
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1)
	e4:SetHintTiming(0,TIMING_MAIN_END)
	e4:SetCondition(s.setcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
-- 过滤函数：判断对象卡是否为战士族怪兽，用于①的保护范围筛选。
function s.indfilter(e,c)
	return c:IsRace(RACE_WARRIOR)
end
-- ②的发动条件：对方（rp==1-tp）把效果发动时才能发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- ②的发动时合法性检查：需主怪兽区有空位、本卡本回合未发动过该效果、且玩家当前能特召符合参数的陷阱怪兽；若通过则给本卡标记已发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己主怪兽区是否有可用空格，且本卡尚未发动过②效果（用flag效果id记录本回合是否已用）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:GetFlagEffect(id)==0
		-- 检查玩家能否特殊召唤一只「阿尔戈☆群星」的战士族·光·4星·攻/守800的效果怪兽（即本卡作为陷阱怪兽的特召参数）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1c1,TYPES_EFFECT_TRAP_MONSTER,800,800,4,RACE_WARRIOR,ATTRIBUTE_LIGHT) end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_LEAVE-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息，向系统声明本次效果包含特殊召唤，对象为本卡，数量为1次。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②的实际处理：再次确认可特召后，将本卡变为效果怪兽（也当作陷阱卡）特殊召唤；若召唤成功、自己除外区存在表侧表示的「阿尔戈☆群星」怪兽且场上有可回手卡，则询问玩家是否追加回手效果，选择后从场上选1张送回手卡。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时再次确认玩家仍能特召该陷阱怪兽，若不能则直接终止处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1c1,TYPES_EFFECT_TRAP_MONSTER,800,800,4,RACE_WARRIOR,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 以自身效果（SUMMON_VALUE_SELF）将本卡表侧表示特殊召唤到自己的怪兽区，并判断是否召唤成功（返回值非0）。
	if Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)~=0
		-- 检查自己除外区是否存在至少1张符合条件的「阿尔戈☆群星」怪兽（表侧表示、怪兽、字段0x1c1），用于决定是否可追加回手。
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_REMOVED,0,1,nil)
		-- 检查双方场上是否存在至少1张可以被效果送回手卡的卡，作为追加回手的另一条件。
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 弹出询问，让玩家决定是否发动“让场上1张卡回到手卡”的追加效果；选择是才继续处理。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否让卡回到手卡？"
		-- 给玩家提示“请选择要返回手牌的卡”，设置选择阶段的选卡消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 从双方场上选择1张能被效果送回手卡的卡作为对象，数量为1（不取对象，效果处理时选择）。
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 将所选之卡显示为对象选择动画，并记录其为本效果的（广义）对象。
			Duel.HintSelection(g)
			-- 中断当前效果处理，使后续回手处理单独结算，避免被判定为与特召同时处理。
			Duel.BreakEffect()
			-- 将被选中的卡以效果原因送回其持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end
-- 判断卡是否满足“自己的「阿尔戈☆群星」怪兽除外中”：表侧表示、且为怪兽、且属于「阿尔戈☆群星」字段（0x1c1）。
function s.cfilter2(c)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1c1)
end
-- e4的发动条件：本卡作为怪兽时，不是被战斗破坏的场合，且是用自身②效果特殊召唤的（召唤类型为特殊召唤+SUMMON_VALUE_SELF）。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- e4的合法性检查：自己魔陷区有空位，且本卡当前可以被放置在魔陷区。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔陷区是否有可用区域，以保证能放回魔陷区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and e:GetHandler():IsCanBePlacedOnField() end
end
-- e4的实际处理：再次确认魔陷区有空位后，若本卡仍与效果关联，则将其表侧表示移动到自己魔陷区并适用效果。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认魔陷区仍有空格，若无则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将本卡从怪兽区移动到自己的魔法与陷阱区域，以表侧表示放置并立即适用其作为魔陷的效果。
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
