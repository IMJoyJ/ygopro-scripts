--光と闇の竜王
-- 效果：
-- 龙族·光属性·8星怪兽＋龙族·暗属性·8星怪兽
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：只要这张卡在怪兽区域存在，这张卡的属性也当作「暗」使用。
-- ②：怪兽的效果·魔法·陷阱卡发动时发动（同一连锁上最多1次）。这张卡的攻击力·守备力下降1000，那个发动无效。
-- ③：这张卡被对方破坏的场合，以自己墓地1只龙族怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册本卡全部效果：为光暗龙王的融合素材条件和融合召唤限制、场上属性当作暗、无效怪兽/魔法/陷阱发动并下降1000攻守、被对方破坏时特召墓地龙族怪兽。
function s.initial_effect(c)
	-- 为这张卡添加融合召唤手续：以1只光属性·8星·龙族怪兽和1只暗属性·8星·龙族怪兽作为融合素材。
	aux.AddFusionProcFun2(c,s.mfilter1,s.mfilter2,true)
	c:EnableReviveLimit()
	-- 这张卡不用融合召唤不能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为必须通过融合召唤才能特殊召唤，其他特殊召唤方式均被禁止。
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- ①：只要这张卡在怪兽区域存在，这张卡的属性也当作「暗」使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"属性当作暗"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e1)
	-- ②：怪兽的效果·魔法·陷阱卡发动时发动（同一连锁上最多1次）。这张卡的攻击力·守备力下降1000，那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"发动无效"
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_F)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	-- ③：这张卡被对方破坏的场合，以自己墓地1只龙族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"墓地特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 定义第1只融合素材的筛选条件：光属性、8星、龙族怪兽。
function s.mfilter1(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(8) and c:IsRace(RACE_DRAGON)
end
-- 定义第2只融合素材的筛选条件：暗属性、8星、龙族怪兽。
function s.mfilter2(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsLevel(8) and c:IsRace(RACE_DRAGON)
end
-- 判定②效果能否发动的条件：当前连锁发动的效果属于怪兽效果或魔法·陷阱卡的发动。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER))
end
-- 目标设定：确认本卡尚未标记该效果的flag（用于天邪鬼场合）；若本卡受天邪鬼攻守倒置影响则先标记；随后把当前发动的卡片组设为无效处理对象。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id)==0 end
	if c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
	-- 登记本次效果处理为无效发动，对象为当前连锁的那组卡片。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 实际处理前的自检：若本卡处于里侧、与效果失去联系、攻击力或守备力低于1000、或被战斗破坏，则不执行后续下降攻守和无效处理。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:GetAttack()<1000 or c:GetDefense()<1000
		or c:IsStatus(STATUS_BATTLE_DESTROYED) then
		return
	end
	-- 这张卡的攻击力·守备力下降1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetValue(-1000)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- 当本卡未受天邪鬼效果影响，且当前连锁正好是被无效连锁的下一连锁时，才进行发动无效。
	if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) and Duel.GetCurrentChain()==ev+1 then
		-- 使被无效的那个连锁发动失效。
		Duel.NegateActivation(ev)
	end
end
-- 判断③的发动条件：破坏这张卡的玩家是对方，且破坏前这张卡由自己控制。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp)
end
-- 筛选墓地中满足条件的龙族怪兽，且该怪兽能够被效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 对象合法性检查：指定对象时必须是自己墓地的龙族怪兽，且满足特殊召唤条件。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp)
		and s.spfilter(chkc,e,tp) end
	-- 确认发动可行性：自己主要怪兽区有空位，且墓地存在符合条件的龙族怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 显示选择提示，让操作玩家选择要特殊召唤的墓地龙族怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的龙族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记本次效果处理为特殊召唤，对象为选中的墓地龙族怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果处理：取得效果对象，若对象仍与效果关联，则将其特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果选中的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
