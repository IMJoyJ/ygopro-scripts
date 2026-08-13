--蛇眼神殿スネークアイ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从自己的手卡·卡组·墓地把1只「蛇眼」怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
-- ②：自己场上的炎属性·1星怪兽的攻击力上升1100。
-- ③：1回合1次，对方把怪兽召唤·特殊召唤的场合，以自己·对方场上1张当作永续魔法卡使用的怪兽卡为对象才能发动。那张卡在自己场上特殊召唤。
local s,id,o=GetID()
-- 注册蛇眼神殿的发动效果（1回合1次）、②攻击力提升永续效果、③对方召唤/特殊召唤时取对象特殊召唤的诱发效果（同时支持通常召唤和特殊召唤两个时点）。
function s.initial_effect(c)
	-- 对应效果原文：‘这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从自己的手卡·卡组·墓地把1只「蛇眼」怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。’
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 对应效果原文：‘②：自己场上的炎属性·1星怪兽的攻击力上升1100。’
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.atktg)
	e2:SetValue(1100)
	c:RegisterEffect(e2)
	-- 对应效果原文：‘③：1回合1次，对方把怪兽召唤·特殊召唤的场合，以自己·对方场上1张当作永续魔法卡使用的怪兽卡为对象才能发动。那张卡在自己场上特殊召唤。’
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 定义过滤函数 s.filter：筛选出「蛇眼」字段的怪兽卡，且其原本持有者的魔法与陷阱区域有空位可放置。
function s.filter(c,tp)
	-- 判断是否为「蛇眼」怪兽，并确认其原本持有者的魔法与陷阱区域有空位。
	return c:IsSetCard(0x19c) and c:IsType(TYPE_MONSTER) and Duel.GetLocationCount(c:GetOwner(),LOCATION_SZONE,tp)>0
end
-- ①效果的发动处理：从手卡·卡组·墓地中选出符合条件的「蛇眼」怪兽（过滤王家长眠之谷影响），询问玩家是否放置，选择1张移动到其原本持有者的魔陷区表侧表示放置，并让它变成永续魔法卡。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取从手卡·卡组·墓地中满足 s.filter 且不受王家长眠之谷影响的「蛇眼」怪兽集合，作为可选的放置候选。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,nil,tp)
	-- 若没有候选卡，或玩家选择不放置，则终止本次发动效果的处理；否则继续。
	if #g==0 or not Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,1)) then return end  --"是否把「蛇眼」怪兽在场上放置？"
	-- 显示选择提示，要求玩家从候选卡中选择1张要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	-- 将选中的怪兽卡移动到其原本持有者的魔法与陷阱区域，以表侧表示放置并使其效果适用。
	if Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
		-- 对应效果原文：‘当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置’中的‘当作永续魔法卡使用’。
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- 确认怪兽是否为等级1且炎属性，用于决定是否受②效果加成。
function s.atktg(e,c)
	return c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 触发条件判断：本次召唤/特殊召唤成功的怪兽中，存在召唤玩家是对方的怪兽（即对方召唤/特殊召唤了怪兽）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 定义对象筛选函数 sfilter：原本种类是怪兽、当前种类为永续魔法（即当作永续魔法卡使用的怪兽卡），且能够被特殊召唤。
function s.sfilter(c,e,tp)
	return c:GetOriginalType()&TYPE_MONSTER>0 and c:GetType()&TYPE_CONTINUOUS+TYPE_SPELL==TYPE_CONTINUOUS+TYPE_SPELL
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的目标选择流程：若选择对象时检查对象合法性；在非选择阶段检查主怪兽区有空位且存在合法对象，然后进行取对象选择。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.sfilter(chkc,e,tp) end
	-- 效果发动条件之一：自己场上主要怪兽区域存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果发动条件之一：双方场上存在1张满足 sfilter 的卡可作为对象。
		and Duel.IsExistingTarget(s.sfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,e,tp) end
	-- 显示选择提示，要求玩家选择1张要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从双方场上选择1张满足条件的卡作为对象，并设为当前连锁的对象卡。
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,e,tp)
	-- 登记操作信息：本连锁将进行1张卡的特殊召唤，对象为刚选择的卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③效果的处理：取得对象卡；若对象仍与本效果关联，则将其表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁选择的怪兽卡对象。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与本效果关联（未中途离场），则将其特殊召唤到自己场上并表侧表示。
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
