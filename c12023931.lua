--ブースター・ドラゴン
-- 效果：
-- 「弹丸」怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，以场上1只其他的表侧表示怪兽为对象才能发动（对方不能对应这个效果的发动把卡的效果发动）。那只怪兽的攻击力·守备力上升500。
-- ②：连接召唤的这张卡被战斗·效果破坏送去墓地的场合，以自己墓地1只其他的龙族怪兽为对象才能发动。那只怪兽特殊召唤。
function c12023931.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，需要2个满足‘弹丸’卡组的连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x102),2,2)
	-- ①：1回合1次，以场上1只其他的表侧表示怪兽为对象才能发动（对方不能对应这个效果的发动把卡的效果发动）。那只怪兽的攻击力·守备力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12023931,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c12023931.atktg)
	e1:SetOperation(c12023931.atkop)
	c:RegisterEffect(e1)
	-- ②：连接召唤的这张卡被战斗·效果破坏送去墓地的场合，以自己墓地1只其他的龙族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12023931,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,12023931)
	e2:SetCondition(c12023931.spcon)
	e2:SetTarget(c12023931.sptg)
	e2:SetOperation(c12023931.spop)
	c:RegisterEffect(e2)
end
-- 设置效果目标选择函数，用于选择场上1只表侧表示怪兽
function c12023931.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc~=c end
	-- 检查是否满足选择目标的条件，即场上存在1只表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 向玩家提示选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	-- 设置连锁限制，防止对方在效果发动时连锁响应
	Duel.SetChainLimit(c12023931.chlimit)
end
-- 设置连锁限制函数，仅允许自己连锁
function c12023931.chlimit(e,ep,tp)
	return tp==ep
end
-- 设置效果处理函数，用于处理攻击力和守备力上升效果
function c12023931.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 为目标怪兽增加500点攻击力
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- 设置效果发动条件函数，判断是否满足特殊召唤的条件
function c12023931.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 设置墓地龙族怪兽的过滤函数，用于筛选可特殊召唤的怪兽
function c12023931.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标选择函数
function c12023931.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c12023931.spfilter(chkc,e,tp) and chkc~=c end
	-- 检查是否满足特殊召唤的条件，即场上存在空位且墓地存在符合条件的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在符合条件的龙族怪兽
		and Duel.IsExistingTarget(c12023931.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp) end
	-- 向玩家提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择墓地中的1只符合条件的龙族怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c12023931.spfilter,tp,LOCATION_GRAVE,0,1,1,c,e,tp)
	-- 设置操作信息，告知连锁处理将特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 设置特殊召唤效果处理函数
function c12023931.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
