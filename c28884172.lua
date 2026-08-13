--ガガガマンサー
-- 效果：
-- ①：1回合1次，以「我我我术士」以外的自己墓地1只「我我我」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是「我我我」怪兽不能特殊召唤。
-- ②：超量素材的这张卡为让超量怪兽的效果发动而被取除送去墓地的场合，以自己场上1只超量怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升500。
function c28884172.initial_effect(c)
	-- ①：1回合1次，以「我我我术士」以外的自己墓地1只「我我我」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是「我我我」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28884172,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetTarget(c28884172.sptg)
	e1:SetOperation(c28884172.spop)
	c:RegisterEffect(e1)
	-- ②：超量素材的这张卡为让超量怪兽的效果发动而被取除送去墓地的场合，以自己场上1只超量怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28884172,1))  --"攻击上升"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c28884172.atkcon)
	e2:SetTarget(c28884172.atktg)
	e2:SetOperation(c28884172.atkop)
	c:RegisterEffect(e2)
end
-- 定义特殊召唤的过滤函数：从自己墓地中选出「我我我」字段、卡名不是「我我我术士」、且可以被当前效果特殊召唤的怪兽。
function c28884172.spfilter(c,e,tp)
	return c:IsSetCard(0x54) and not c:IsCode(28884172) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动条件与取对象处理：若在连锁处理中确认对象，则判断该对象位于自己墓地且满足过滤条件；发动时需确认自己有可用怪兽区且墓地存在符合条件的对象。
function c28884172.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c28884172.spfilter(chkc,e,tp) end
	-- 检查自己场上主要怪兽区是否有空位，判断能否进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1张符合条件的「我我我」怪兽可供选择为对象。
		and Duel.IsExistingTarget(c28884172.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地的符合条件的「我我我」怪兽中选择1张，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c28884172.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果处理将进行特殊召唤，预定处理1张对象卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的解决处理：将选择的对象怪兽特殊召唤，然后对自己附加「不是『我我我』怪兽不能特殊召唤」的自肃效果。
function c28884172.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时记录的连锁对象卡（即先前选择的墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将那只怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是「我我我」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c28884172.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到场上，使己方玩家在结束阶段前不能特殊召唤非「我我我」怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的判定函数：不是「我我我」字段的怪兽不能被特殊召唤。
function c28884172.splimit(e,c)
	return not c:IsSetCard(0x54)
end
-- 效果②的发动条件：这张卡作为超量素材，因超量怪兽的效果发动而被取除并送去墓地。
function c28884172.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and c:IsPreviousLocation(LOCATION_OVERLAY)
end
-- 效果②的对象过滤函数：选择自己场上表侧表示的超量怪兽。
function c28884172.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 效果②的取对象处理：确认对象为表侧表示的超量怪兽，并在发动时选择自己场上1只符合条件的目标。
function c28884172.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c28884172.atkfilter(chkc) end
	-- 效果②发动合法性检查：自己场上是否存在至少1只表侧表示的超量怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c28884172.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择提示，要求选择表侧表示的超量怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上表侧表示的超量怪兽中选择1只，并登记为当前连锁的对象。
	Duel.SelectTarget(tp,c28884172.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的解决处理：被选择的超量怪兽攻击力直到回合结束时上升500。
function c28884172.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②选择的对象超量怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时上升500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(500)
		tc:RegisterEffect(e1)
	end
end
