--粛声のガーディアン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，同一连锁上不能发动。
-- ①：仪式怪兽以外的自己场上的怪兽被战斗·效果破坏的场合才能发动。从手卡·卡组把1只「法理守护者」特殊召唤。
-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地，以自己场上1只仪式怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升场上的其他怪兽的原本攻击力的合计数值。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含卡片发动、①效果（被破坏时特召）和②效果（送墓升攻）。
function s.initial_effect(c)
	-- 建立卡片关联，表明本卡记载了「法理守护者」的卡名。
	aux.AddCodeList(c,3627449)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：仪式怪兽以外的自己场上的怪兽被战斗·效果破坏的场合才能发动。从手卡·卡组把1只「法理守护者」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"上升攻击力"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地，以自己场上1只仪式怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升场上的其他怪兽的原本攻击力的合计数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.atkcon)
	e3:SetCost(s.atkcost)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
-- 过滤条件：因战斗或效果破坏、且原本在自己场上的非仪式怪兽。
function s.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not (c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER)) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- ①效果的发动条件：检查被破坏的卡中是否存在满足过滤条件的怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- ①效果的消耗/限制处理：检查并注册同一连锁上不能发动的标识。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前连锁中是否尚未发动过该卡的效果。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 在当前连锁中注册已发动标识，用于防止同一连锁重复发动。
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
end
-- 过滤条件：卡名为「法理守护者」且可以特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsCode(3627449) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ①效果的发动准备：检查怪兽区域空位以及手卡·卡组是否存在可特召的「法理守护者」，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组是否存在至少1只满足特召条件的「法理守护者」。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡或卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ①效果的效果处理：从手卡或卡组选择1只「法理守护者」特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已无可用怪兽区域，则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只「法理守护者」。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：这张卡在魔陷区表侧表示存在。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- ②效果的消耗处理：检查同一连锁未发动过该卡效果，并将魔陷区表侧表示的这张卡送去墓地。
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查同一连锁是否未发动过该卡效果，且这张卡是否能作为消耗送去墓地。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and e:GetHandler():IsAbleToGraveAsCost() end
	-- 在当前连锁中注册已发动标识，防止同一连锁重复发动。
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	-- 将作为发动成本的这张卡送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：自己场上表侧表示的仪式怪兽，且场上存在其他有原本攻击力的怪兽。
function s.atkfilter(c)
	-- 检查该卡是否为表侧表示的仪式怪兽，且场上除它以外的其他表侧表示怪兽的原本攻击力合计大于0。
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and Duel.GetMatchingGroup(Card.IsFaceup,0,LOCATION_MZONE,LOCATION_MZONE,c):GetSum(Card.GetBaseAttack)>0 and c:IsFaceup()
end
-- ②效果的发动准备：选择自己场上1只表侧表示的仪式怪兽作为对象。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atkfilter(chkc) end
	-- 检查自己场上是否存在符合条件的仪式怪兽作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的仪式怪兽作为效果对象。
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果的效果处理：计算场上其他怪兽的原本攻击力合计，使作为对象的仪式怪兽的攻击力上升该数值。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的仪式怪兽。
	local tc=Duel.GetFirstTarget()
	-- 计算场上除对象怪兽以外的其他所有表侧表示怪兽的原本攻击力合计数值。
	local atk=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,tc):GetSum(Card.GetBaseAttack)
	if atk>0 and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		-- 那只怪兽的攻击力直到回合结束时上升场上的其他怪兽的原本攻击力的合计数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(atk)
		tc:RegisterEffect(e1)
	end
end
