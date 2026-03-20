--蛇眼神殿スネークアイ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从自己的手卡·卡组·墓地把1只「蛇眼」怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
-- ②：自己场上的炎属性·1星怪兽的攻击力上升1100。
-- ③：1回合1次，对方把怪兽召唤·特殊召唤的场合，以自己·对方场上1张当作永续魔法卡使用的怪兽卡为对象才能发动。那张卡在自己场上特殊召唤。
local s,id,o=GetID()
-- 初始化效果，创建并注册3个效果：①魔陷发动效果、②场上炎属性1星怪兽攻击力上升1100、③对方召唤/特殊召唤时可将对象怪兽卡特殊召唤的效果
function s.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从自己的手卡·卡组·墓地把1只「蛇眼」怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的炎属性·1星怪兽的攻击力上升1100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.atktg)
	e2:SetValue(1100)
	c:RegisterEffect(e2)
	-- ③：1回合1次，对方把怪兽召唤·特殊召唤的场合，以自己·对方场上1张当作永续魔法卡使用的怪兽卡为对象才能发动。那张卡在自己场上特殊召唤。
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
-- 过滤函数，用于筛选满足条件的「蛇眼」怪兽（必须是怪兽卡、属于蛇眼卡组、且目标玩家场上存在空位）
function s.filter(c,tp)
	-- 满足条件的「蛇眼」怪兽必须是怪兽卡、属于蛇眼卡组、且目标玩家场上存在空位
	return c:IsSetCard(0x19c) and c:IsType(TYPE_MONSTER) and Duel.GetLocationCount(c:GetOwner(),LOCATION_SZONE,tp)>0
end
-- 发动效果处理：检索满足条件的「蛇眼」怪兽并将其放置到场上
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检索满足条件的「蛇眼」怪兽（包括手牌、卡组、墓地）
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,nil,tp)
	-- 若无满足条件的怪兽或玩家拒绝发动，则不执行后续操作
	if #g==0 or not Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,1)) then return end  --"是否把「蛇眼」怪兽在场上放置？"
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	-- 将选中的怪兽移动到场上并设置为永续魔法卡
	if Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
		-- 将选中的怪兽转换为永续魔法卡类型
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- 设置攻击力提升效果的目标条件：场上炎属性1星怪兽
function s.atktg(e,c)
	return c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 判断是否为对方召唤成功时触发的效果
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 筛选可特殊召唤的怪兽卡（必须是原本为怪兽卡、当前为永续魔法卡、且可特殊召唤）
function s.sfilter(c,e,tp)
	return c:GetOriginalType()&TYPE_MONSTER>0 and c:GetType()&TYPE_CONTINUOUS+TYPE_SPELL==TYPE_CONTINUOUS+TYPE_SPELL
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的处理条件：检查是否有满足条件的目标卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.sfilter(chkc,e,tp) end
	-- 检查目标玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的场上目标卡
		and Duel.IsExistingTarget(s.sfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,e,tp)
	-- 设置操作信息：特殊召唤目标卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 若目标卡仍存在于场上则执行特殊召唤
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
