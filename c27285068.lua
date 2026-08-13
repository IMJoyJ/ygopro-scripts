--開闢なる予幻視
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「无垢者 米底乌斯」存在的场合才能发动。从卡组选1只攻击力300/守备力200的怪兽加入手卡或特殊召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只怪兽当作调整使用。
local s,id,o=GetID()
-- 初始化效果注册函数：注册①从卡组选攻300/防200怪兽加入手卡或特殊召唤的效果，以及②墓地除外自身使场上1只表侧表示怪兽当回合当作调整使用的效果；两者各1回合1次。
function s.initial_effect(c)
	-- 将卡号97556336（无垢者 米底乌斯）登记为本卡记载的卡名，便于规则关联。
	aux.AddCodeList(c,97556336)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己场上有「无垢者 米底乌斯」存在的场合才能发动。从卡组选1只攻击力300/守备力200的怪兽加入手卡或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从卡组选怪兽"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：自己主要阶段把墓地的这张卡除外，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只怪兽当作调整使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"变成调整"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动代价：把墓地的这张卡除外（使用便捷代价函数aux.bfgcost）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tntg)
	e2:SetOperation(s.tnop)
	c:RegisterEffect(e2)
end
-- 定义过滤器s.cfilter：判定怪兽为表侧表示且卡号为97556336（无垢者 米底乌斯）。
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(97556336)
end
-- 定义①效果的发动条件s.condition：自己场上有表侧表示的「无垢者 米底乌斯」存在时才可发动。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家tp视角下，自己场上是否存在至少1只满足s.cfilter（表侧表示的无垢者 米底乌斯）的怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 定义检索过滤器s.thfilter：筛选攻击力300且守备力200的怪兽，且该怪兽能够加入手卡，或在主怪兽区有空位时能够被效果特殊召唤。
function s.thfilter(c,e,tp)
	if not (c:IsAttack(300) and c:IsDefense(200)) then return false end
	-- 获取tp玩家主要怪兽区的可用空格数量，用于后续判断能否特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 定义①效果的发动目标判定s.target：发动时若卡组中存在至少1张满足s.thfilter的怪兽，则满足发动条件。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在卡组中检索是否存在至少1张满足s.thfilter条件的怪兽，作为①效果可发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- 定义①效果处理函数s.activate：从卡组选择1只攻300/防200的怪兽，根据玩家选择将其加入手卡或特殊召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要操作的卡”的选择提示（HINT_SELECTMSG + HINTMSG_OPERATECARD），用于后续选择卡组中的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让tp玩家从卡组中选择1张满足s.thfilter条件的怪兽卡，且必须选择1张。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 获取tp玩家主要怪兽区的可用空格数，以判断特殊召唤是否可行。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 若该怪兽能够加入手卡，并且（不能特殊召唤、或没有空位、或玩家选择了“加入手卡”选项（=0）），则执行加入手卡。
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选中的怪兽加入其持有者的手卡，原因记为REASON_EFFECT（效果处理）。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对手玩家展示这张加入手卡的怪兽，进行确认。
			Duel.ConfirmCards(1-tp,tc)
		elseif tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 将选中的怪兽以表侧表示特殊召唤到tp玩家场上，执行常规召唤条件/苏生限制检查。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 定义②效果的对象过滤器s.tnfilter：筛选表侧表示且不是调整的怪兽。
function s.tnfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TUNER)
end
-- 定义②效果的目标选择函数s.tntg：检查并选择自己场上1只表侧表示且不是调整的怪兽作为对象。
function s.tntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tnfilter(chkc) end
	-- 发动时检查：自己场上是否存在至少1只满足s.tnfilter（表侧且非调整）的怪兽，以决定能否发动。
	if chk==0 then return Duel.IsExistingTarget(s.tnfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出“请选择效果的对象”的选择提示（HINT_SELECTMSG + HINTMSG_TARGET）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示且不是调整的怪兽，并将其登记为本连锁的对象。
	Duel.SelectTarget(tp,s.tnfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 定义②效果处理函数s.tnop：为对象怪兽添加本回合当作调整使用的效果（若对象仍与连锁相关且合法）。
function s.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取②效果选择的对象怪兽（本连锁的唯一对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and not tc:IsType(TYPE_TUNER) then
		-- 这个回合，那只怪兽当作调整使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e1)
	end
end
