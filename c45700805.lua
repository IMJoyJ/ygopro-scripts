--プラズマ戦士エイトム
local s,id,o=GetID()
-- 定义卡片初始效果函数，启用复活限制，并注册特殊召唤条件、过程和攻击力改变效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 创建效果：设定为单体效果，类型为特殊召唤条件，且不可禁用、不可复制。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e0)
	-- 创建效果：设定为全场效果，类型为特殊召唤规则，且不可复制。设置生效范围为手牌和墓地，限制次数为1次（基于卡片ID），并关联条件、目标和操作函数。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 创建效果：设定描述文本，类别为攻击力改变，类型为起动效果。设置生效范围为主怪兽区，限制次数为1次，并关联费用、目标和操作函数。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.datcost)
	e2:SetTarget(s.dattg)
	e2:SetOperation(s.datop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数，用于筛选等级高于7且场上存在怪兽区的卡片。
function s.cfilter(c,tp)
	return c:IsLevelAbove(7)
		-- 检查玩家场上的怪兽区数量是否大于0
		and Duel.GetMZoneCount(tp,c)>0
end
-- 定义特殊召唤条件函数：如果卡片为nil则返回true，获取控制者，并检查释放组中满足过滤条件的卡片数量是否至少为1张。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否存在满足s.cfilter的卡片用于特殊召唤
	return Duel.CheckReleaseGroupEx(tp,s.cfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 定义特殊召唤目标函数：获取可释放的卡片组并进行过滤，提示玩家选择要解放的卡片，如果选择了卡片则设置标签对象并返回true，否则返回false。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 从玩家场上获取可释放的卡片组，并使用s.cfilter进行过滤
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(s.cfilter,nil,tp)
	-- 向玩家发送提示信息，要求选择要解放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 定义特殊召唤操作函数：获取标签对象（被解放的卡片），并将其解放。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local rc=e:GetLabelObject()
	-- 以REASON_SPSUMMON原因解放rc
	Duel.Release(rc,REASON_SPSUMMON)
end
-- 定义费用过滤函数，用于筛选属于特定卡组、类型为怪兽、不为当前卡片且可作为费用的卡片。
function s.costfilter(c)
	return c:IsSetCard(0xe9,0x2066) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and c:IsAbleToGraveAsCost()
end
-- 定义费用支付函数：检查是否为0（确认），如果存在满足条件的卡片则提示玩家选择要送去墓地的卡片并将其送去墓地。
function s.datcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足s.costfilter的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向玩家发送提示信息，要求选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从牌组中选择符合s.costfilter条件的1-1张卡片
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡片以REASON_COST原因送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义攻击力改变目标函数：获取效果处理者，如果检查为0则返回其基础攻击力不等于1500或没有直接攻击效果。
function s.dattg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetBaseAttack()~=1500 or not c:IsHasEffect(EFFECT_DIRECT_ATTACK) end
end
-- 定义攻击力改变操作函数：获取效果处理者，如果卡片与连锁相关且表侧表示则创建并注册两个效果：一个设定基础攻击力为1500，另一个赋予直接攻击能力（不可禁用），并在回合结束时重置。
function s.datop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() then
		-- 创建单体效果，设置基础攻击力为1500，在事件、标准重置、阶段结束时重置
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(1500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 创建单体效果，赋予直接攻击能力且不可禁用，在事件、标准重置、阶段结束时重置
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DIRECT_ATTACK)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
