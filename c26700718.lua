--スネークアイ追走劇
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·卡组·墓地把1只「迪亚贝尔斯塔尔」怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
-- ②：自己·对方的结束阶段，把墓地的这张卡除外，以自己场上1张当作永续魔法卡使用的怪兽卡为对象才能发动。那张卡特殊召唤。
local s,id,o=GetID()
-- 定义这张卡的初始化函数：创建并注册两个效果。e1为①效果的魔法卡发动（自由时点发动、1回合1次），e2为②效果（墓地除外作为cost、结束阶段触发、取对象、特殊召唤）。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：从自己的手卡·卡组·墓地把1只「迪亚贝尔斯塔尔」怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"当作永续魔法卡放置"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段，把墓地的这张卡除外，以自己场上1张当作永续魔法卡使用的怪兽卡为对象才能发动。那张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	-- 为②效果设置发动成本：将墓地中的这张卡除外（aux.bfgcost封装了除外自身的cost判定与执行）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.spstg)
	e2:SetOperation(s.spsop)
	c:RegisterEffect(e2)
end
-- 定义①效果的候选卡条件：卡名或系列含有「迪亚贝尔斯塔尔」的怪兽卡，且未被禁止当作魔法卡放在魔陷区。
function s.filter1(c)
	return c:IsSetCard(0x119b) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- ①效果的发动条件判定：自己魔法与陷阱区域有空位，且手卡·卡组·墓地存在至少1只满足条件的「迪亚贝尔斯塔尔」怪兽；若这张卡尚未发动到场上，则需为这张卡自身预留1个魔陷区。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己魔法与陷阱区域当前可用的空格数量。
		local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ct=ct-1 end
		-- 判定满足条件的「迪亚贝尔斯塔尔」怪兽在可用区域至少存在1张，且魔陷区仍有空位，满足发动条件。
		return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil) and ct>0
	end
end
-- ①效果的处理：从手卡·卡组·墓地选择1只符合条件的「迪亚贝尔斯塔尔」怪兽，以表侧表示当作永续魔法卡放置到其原本持有者的魔法与陷阱区域，并赋予其“永续魔法卡”的种类。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时再次确认自己魔陷区仍有空位，若没有空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 给玩家显示选择提示，提示文字为“请选择要放置到场上的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从自己的手卡·卡组·墓地中选出1张满足s.filter1的「迪亚贝尔斯塔尔」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽移动到其原本持有者的魔法与陷阱区域，以表侧表示放置，并立即适用其效果。
		Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true)
		-- 当作永续魔法卡使用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- 定义②效果可选择为对象的卡的条件：该卡的原本种类是怪兽，当前已是表侧表示的永续魔法卡（即作为永续魔法卡使用的怪兽卡），并且能够被特殊召唤。
function s.sfilter(c,e,tp)
	return c:GetOriginalType()&TYPE_MONSTER>0 and c:GetType()&TYPE_CONTINUOUS+TYPE_SPELL==TYPE_CONTINUOUS+TYPE_SPELL
		and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件与取对象判定：自己主要怪兽区域存在空位，且自己场上存在满足s.sfilter的对象候选卡。
function s.spstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.sfilter(chkc,e,tp) end
	-- 发动条件检查：自己主要怪兽区域有可用空格，保证特殊召唤能进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查自己场上存在表侧表示且可被特殊召唤的“当作永续魔法卡使用的怪兽卡”作为效果对象。
		and Duel.IsExistingTarget(s.sfilter,tp,LOCATION_ONFIELD,0,1,nil,e,tp) end
	-- 显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己场上选择1张满足s.sfilter的卡作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
	-- 将本次特殊召唤操作登记到连锁处理信息中，供其它效果检测是否包含特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的处理：若选择的对象仍与效果关联，则将其表侧表示特殊召唤到自己场上。
function s.spsop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得处理该效果时锁定的对象卡（本效果只取1张对象）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与此效果关联后，以表侧表示将对象特殊召唤到自己场上。
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
