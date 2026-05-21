--青眼の究極霊竜
-- 效果：
-- 调整2只以上＋调整以外的「青眼」怪兽1只
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要这张卡在怪兽区域存在，对方不能把自己墓地的卡除外。
-- ②：卡的效果在场上发动时才能发动。那个发动无效，这张卡的攻击力直到回合结束时上升1000。
-- ③：这张卡被战斗·效果破坏的场合才能发动。从自己墓地把「青眼究极灵龙」以外的1只龙族·光属性怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- 设置同调召唤手续：调整2只以上＋调整以外的「青眼」怪兽1只。
	aux.AddSynchroMixProcedure(c,aux.NonTuner(Card.IsSetCard,0xdd),nil,nil,aux.Tuner(nil),2,99)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，对方不能把自己墓地的卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetTarget(s.rmlimit)
	c:RegisterEffect(e1)
	-- ②：卡的效果在场上发动时才能发动。那个发动无效，这张卡的攻击力直到回合结束时上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"发动无效"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,id)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗·效果破坏的场合才能发动。从自己墓地把「青眼究极灵龙」以外的1只龙族·光属性怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- （此卡在规则上视为「青眼精灵龙」）
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(21142671)
	c:RegisterEffect(e4)
end
-- 限制对方除外自己墓地卡片的过滤条件：目标卡在自己墓地且由对方发动效果。
function s.rmlimit(e,c,rp,r,re)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and re:GetOwnerPlayer()~=tp
end
-- 效果无效的发动条件：此卡未被战斗破坏、发动位置在场上且该发动可以被无效。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中触发效果的发动位置。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and loc&LOCATION_ONFIELD~=0
		-- 检查该连锁的发动是否可以被无效。
		and Duel.IsChainNegatable(ev)
end
-- 效果无效的靶向与操作信息设置函数。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：在连锁0处理使该发动无效的操作。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果无效的具体执行函数：无效发动并提升此卡攻击力。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若成功无效发动，且此卡仍在场上表侧表示存在。
	if Duel.NegateActivation(ev) and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力直到回合结束时上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 特殊召唤效果的发动条件：此卡被战斗或效果破坏。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤自己墓地中「青眼究极灵龙」以外的龙族·光属性怪兽。
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 特殊召唤效果的靶向与可行性检查函数。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足特殊召唤条件的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：从自己墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 特殊召唤效果的具体执行函数。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域，则不处理效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 过滤并选择自己墓地中不受「王家之谷」影响且满足条件的1只怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽在自己场上表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
