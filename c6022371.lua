--ウォーター・ドラゴン－クラスター
-- 效果：
-- 这张卡不能通常召唤。「结合术」魔法·陷阱卡的效果才能特殊召唤。
-- ①：这张卡特殊召唤成功的场合才能发动。对方场上的效果怪兽直到回合结束时攻击力变成0，不能把效果发动。
-- ②：把这张卡解放才能发动。从手卡·卡组把2只「水龙」无视召唤条件守备表示特殊召唤。这个效果在对方回合也能发动。
function c6022371.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。「结合术」魔法·陷阱卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c6022371.splimit)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤成功的场合才能发动。对方场上的效果怪兽直到回合结束时攻击力变成0，不能把效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(6022371,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(c6022371.atktg)
	e2:SetOperation(c6022371.atkop)
	c:RegisterEffect(e2)
	-- ②：把这张卡解放才能发动。从手卡·卡组把2只「水龙」无视召唤条件守备表示特殊召唤。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(6022371,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c6022371.spcost)
	e3:SetTarget(c6022371.sptg)
	e3:SetOperation(c6022371.spop)
	c:RegisterEffect(e3)
end
-- 判定特殊召唤条件：允许特殊召唤此卡时，发动效果的那张卡必须是「结合术」魔法·陷阱卡（字段0x100），即只有这类卡的效果能特殊召唤此卡。
function c6022371.splimit(e,se,sp,st)
	local sc=se:GetHandler()
	return sc and sc:IsType(TYPE_SPELL+TYPE_TRAP) and sc:IsSetCard(0x100)
end
-- 过滤条件：对方场上表侧表示且为效果怪兽的卡。
function c6022371.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- ①效果的发动条件：对方场上存在至少1只表侧表示的效果怪兽。
function c6022371.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 与id6相同，检查是否存在满足atkfilter的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c6022371.atkfilter,tp,0,LOCATION_MZONE,1,nil) end
end
-- ①效果处理：获取对方场上所有表侧表示效果怪兽，对每只赋予攻击力变成0、且不能发动效果的无效化状态，持续到回合结束。
function c6022371.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示效果怪兽作为效果处理对象。
	local g=Duel.GetMatchingGroup(c6022371.atkfilter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 对方场上的效果怪兽直到回合结束时攻击力变成0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- ①中'不能把效果发动'部分；②：把这张卡解放才能发动。从手卡·卡组把2只「水龙」无视召唤条件守备表示特殊召唤。这个效果在对方回合也能发动。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2,true)
		tc=g:GetNext()
	end
end
-- ②效果的发动代价：确认这张卡可以被解放；若可以，解放自身作为发动代价。
function c6022371.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以cost理由解放这张卡，作为发动②效果所需的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选可特殊召唤的「水龙」：卡号为85066822，且能够无视召唤条件以守备表示特殊召唤。
function c6022371.spfilter(c,e,tp)
	return c:IsCode(85066822) and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_DEFENSE)
end
-- ②效果的发动条件：自己场上可用怪兽区至少2个，且手卡·卡组存在至少2只符合条件的「水龙」，并且没有「青眼精灵龙」禁止同时特殊召唤2只以上怪兽的效果。
function c6022371.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件前半：确认自己场上至少有2个可用的怪兽区（用于放置2只特殊召唤的怪兽）。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>=2
		-- 发动条件后半：确认手卡·卡组中存在至少2只满足spfilter的「水龙」。
		and Duel.IsExistingMatchingCard(c6022371.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,2,nil,e,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) end
	-- 设置操作信息：此效果含特殊召唤，从手卡·卡组特殊召唤2只怪兽（不取对象，处理时确定具体卡）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果处理：先检查空位和「青眼精灵龙」限制，然后提示玩家选择从手卡·卡组特殊召唤的「水龙」，并将选择的2只以守备表示特殊召唤。
function c6022371.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前检查：自己场上怪兽区空位不足2个时，效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 发送选择提示消息，指示玩家正在选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡·卡组中选出2张符合条件的「水龙」（至少2张才处理）。
	local g=Duel.SelectMatchingCard(tp,c6022371.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,2,2,nil,e,tp)
	if g:GetCount()==2 then
		-- 将选中的2只「水龙」以守备表示特殊召唤，nocheck=true表示无视召唤条件。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP_DEFENSE)
	end
end
