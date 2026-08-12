--M∀LICE＜C＞GWC－06
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。这张卡也能把自己场上1只表侧表示的「码丽丝」怪兽除外，在盖放的回合发动。
-- ①：自己的墓地·除外状态的1只「码丽丝」怪兽特殊召唤。那之后，自己场上有「码丽丝」连接怪兽存在的场合，可以让自己基本分回复这个效果特殊召唤的怪兽的原本攻击力的数值。
local s,id,o=GetID()
-- 创建主效果和盖放时可发动的效果
function s.initial_effect(c)
	-- ①：自己的墓地·除外状态的1只「码丽丝」怪兽特殊召唤。那之后，自己场上有「码丽丝」连接怪兽存在的场合，可以让自己基本分回复这个效果特殊召唤的怪兽的原本攻击力的数值。
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
-- 判断目标怪兽是否满足特殊召唤条件
function s.spfilter(c,e,tp,res)
	return c:IsFaceupEx() and c:IsSetCard(0x1bf)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断目标怪兽是否满足特殊召唤条件
		and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or res and Duel.GetMZoneCount(tp,res)>0)
end
-- 判断目标怪兽是否满足特殊召唤条件
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local res=e:GetHandler():IsHasEffect(EFFECT_TRAP_ACT_IN_SET_TURN,tp)
	if chk==0 then return res and res:GetOwner()==c and res:GetValue()==id
		-- 判断目标怪兽是否满足特殊召唤条件
		or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,nil) end
	-- 设置连锁操作信息，确定特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 判断目标怪兽是否满足连接怪兽条件
function s.lpfilter(c)
	return c:IsSetCard(0x1bf) and c:IsType(TYPE_LINK) and c:IsFaceup()
end
-- 发动效果，选择并特殊召唤卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,nil)
	local tc=g:GetFirst()
	-- 将目标怪兽特殊召唤
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 判断场上是否存在码丽丝连接怪兽
		and Duel.IsExistingMatchingCard(s.lpfilter,tp,LOCATION_MZONE,0,1,nil)
		and tc:GetBaseAttack()~=0
		-- 询问是否回复基本分
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否回复基本分？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 回复基本分
		Duel.Recover(tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
-- 判断目标怪兽是否满足除外条件
function s.cfilter(c,e,tp)
	return c:IsSetCard(0x1bf) and c:IsFaceup() and c:IsAbleToRemoveAsCost()
		-- 判断目标怪兽是否满足除外条件
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,c)
end
-- 判断是否满足盖放时发动条件
function s.condition(e)
	return e:GetHandler():IsStatus(STATUS_SET_TURN) and e:GetHandler():IsLocation(LOCATION_ONFIELD)
end
-- 支付发动费用，除外场上码丽丝怪兽
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足支付费用条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 将目标卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
