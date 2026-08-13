--M∀LICE＜C＞GWC－06
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。这张卡也能把自己场上1只表侧表示的「码丽丝」怪兽除外，在盖放的回合发动。
-- ①：自己的墓地·除外状态的1只「码丽丝」怪兽特殊召唤。那之后，自己场上有「码丽丝」连接怪兽存在的场合，可以让自己基本分回复这个效果特殊召唤的怪兽的原本攻击力的数值。
local s,id,o=GetID()
-- 初始化效果：创建并注册两个效果，e1为①效果（特殊召唤并可能回复LP），e2为允许此陷阱在盖放回合通过除外自己场上表侧「码丽丝」怪兽来发动的效果。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己的墓地·除外状态的1只「码丽丝」怪兽特殊召唤。那之后，自己场上有「码丽丝」连接怪兽存在的场合，可以让自己基本分回复这个效果特殊召唤的怪兽的原本攻击力的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这张卡也能把自己场上1只表侧表示的「码丽丝」怪兽除外，在盖放的回合发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"适用「码丽丝<代码>GWC-06」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetValue(id)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(s.condition)
	e2:SetCost(s.cost)
	c:RegisterEffect(e2)
end
-- 定义特殊召唤对象过滤函数：从墓地/除外中选择「码丽丝」怪兽，要求其能被正常特殊召唤，并确保当前或移除cost候选后主怪兽区有空位。
function s.spfilter(c,e,tp,res)
	return c:IsFaceupEx() and c:IsSetCard(0x1bf)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 怪兽区空位判定：当前已有空位，或者存在将被除外的候选卡res时，移除res后仍有空位。
		and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or res and Duel.GetMZoneCount(tp,res)>0)
end
-- 效果发动时的目标函数：检查盖放回合追加发动条件（存在由本卡赋予的EFFECT_TRAP_ACT_IN_SET_TURN效果）或墓地/除外有可特殊召唤的「码丽丝」怪兽；若可发动则后续设置操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local res=e:GetHandler():IsHasEffect(EFFECT_TRAP_ACT_IN_SET_TURN,tp)
	if chk==0 then return res and res:GetOwner()==c and res:GetValue()==id
		-- 发动条件之一：墓地或除外区存在满足s.spfilter条件的「码丽丝」怪兽。
		or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,nil) end
	-- 设置操作信息：声明本效果涉及特殊召唤，从墓地/除外最多特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 定义LP回复判定过滤函数：自己场上表侧表示的「码丽丝」连接怪兽。
function s.lpfilter(c)
	return c:IsSetCard(0x1bf) and c:IsType(TYPE_LINK) and c:IsFaceup()
end
-- 效果处理：选择墓地/除外1只「码丽丝」怪兽特殊召唤，若成功且自己场上有「码丽丝」连接怪兽，则玩家可选择回复该怪兽原本攻击力数值的LP。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给出选择特殊召唤怪兽的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地/除外选择1只不受王家长眠之谷影响且满足条件的「码丽丝」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,nil)
	local tc=g:GetFirst()
	-- 若选择成功且特殊召唤成功（返回值非0），继续执行后续回复判定。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 追加回复条件：自己场上存在表侧表示的「码丽丝」连接怪兽。
		and Duel.IsExistingMatchingCard(s.lpfilter,tp,LOCATION_MZONE,0,1,nil)
		and tc:GetBaseAttack()~=0
		-- 询问玩家是否回复基本分。
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否回复基本分？"
		-- 中断效果连锁，使特殊召唤与LP回复作为不同时处理，以正确触发时点。
		Duel.BreakEffect()
		-- 回复玩家LP，数值为特殊召唤怪兽的原本攻击力，原因记为效果。
		Duel.Recover(tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
-- 定义cost候选过滤函数：自己场上表侧表示的「码丽丝」怪兽，可作为除外cost，且除外后墓地/除外仍有可特殊召唤的「码丽丝」怪兽。
function s.cfilter(c,e,tp)
	return c:IsSetCard(0x1bf) and c:IsFaceup() and c:IsAbleToRemoveAsCost()
		-- 确保除外候选后仍存在可特殊召唤的「码丽丝」怪兽，以满足同时进行特殊召唤的条件。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,c)
end
-- e2的发动条件：此卡处于本回合覆盖状态且在场上，才可适用盖放回合发动的追加效果。
function s.condition(e)
	return e:GetHandler():IsStatus(STATUS_SET_TURN) and e:GetHandler():IsLocation(LOCATION_ONFIELD)
end
-- e2的cost处理：选择并除外自己场上1只表侧表示的「码丽丝」怪兽作为发动代价。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检查：确认场上存在满足条件的可除外「码丽丝」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 给出选择除外怪兽的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只自己要除外的表侧「码丽丝」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 将选择的怪兽表侧除外作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
