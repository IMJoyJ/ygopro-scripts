--シンクロ・チェイス
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己把「战士」、「同调士」、「星尘」同调怪兽同调召唤的场合，以作为那次同调召唤的素材的自己墓地1只怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
-- ②：只要这张卡在魔法与陷阱区域存在，对方不能对应原本卡名包含「战士」、「同调士」、「星尘」之内任意种的自己的同调怪兽的效果的发动把魔法·陷阱·怪兽的效果发动。
function c23442438.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己把「战士」、「同调士」、「星尘」同调怪兽同调召唤的场合，以作为那次同调召唤的素材的自己墓地1只怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23442438,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,23442438)
	e2:SetCondition(c23442438.spcon)
	e2:SetTarget(c23442438.sptg)
	e2:SetOperation(c23442438.spop)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在魔法与陷阱区域存在，对方不能对应原本卡名包含「战士」、「同调士」、「星尘」之内任意种的自己的同调怪兽的效果的发动把魔法·陷阱·怪兽的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(c23442438.ccop)
	c:RegisterEffect(e3)
end
-- 筛选条件：怪兽须为同调召唤成功、卡名属于「战士」「同调士」「星尘」字段之一的同调怪兽。
function c23442438.cfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x66,0x1017,0xa3)
end
-- 筛选条件：该怪兽在自己墓地且由自己控制，可作为当前效果对象，并能够被效果以表侧守备表示特殊召唤。
function c23442438.spfilter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 触发条件：同调召唤成功的怪兽组中存在满足cfilter的怪兽，且这次同调召唤是由己方执行的。
function c23442438.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c23442438.cfilter,1,nil) and rp==tp
end
-- 目标处理：取出触发效果的同调怪兽所使用的素材组；若为选对象时则检查所选卡是否在素材中且合法；发动判定时检查自己主要怪兽区有空位且素材中存在合法对象。
function c23442438.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=eg:Filter(c23442438.cfilter,nil):GetFirst():GetMaterial()
	if chkc then return mg:IsContains(chkc) and c23442438.spfilter(chkc,e,tp) end
	-- 检查自己主要怪兽区域是否存在空位，以确定能否进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and mg:IsExists(c23442438.spfilter,1,nil,e,tp) end
	-- 给玩家弹出选择提示，要求选择一张要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=mg:FilterSelect(tp,c23442438.spfilter,1,1,nil,e,tp)
	-- 将选择的卡设置为当前连锁效果的对象。
	Duel.SetTargetCard(g)
	-- 设置操作信息：本效果将把选择的那1张卡特殊召唤，用于连锁判定和效果记录。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取得对象卡，若对象仍与效果关联，则将其以表侧守备表示特殊召唤到自己场上。
function c23442438.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁效果处理时的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤到己方场上，不检查召唤条件且不检查苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- ②效果的不入连锁持续监视：每当有玩家发动效果时，若该效果是己方发动的同步怪兽效果，且该怪兽原本卡名包含「战士」「同调士」「星尘」字段之一，则设置连锁限制。
function c23442438.ccop(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if ep==tp and re:IsActiveType(TYPE_MONSTER) and tc:IsType(TYPE_SYNCHRO) and tc:IsOriginalSetCard(0x66,0x1017,0xa3) then
		-- 设置连锁限制条件：本次连锁中对方不能对应发动魔法·陷阱·怪兽效果。
		Duel.SetChainLimit(c23442438.chainlm)
	end
end
-- 连锁限制判定：仅允许发动该效果的一方玩家进行连锁，从而阻止对方连锁。json
function c23442438.chainlm(e,rp,tp)
	return tp==rp
end
