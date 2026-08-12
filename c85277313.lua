--ティスティナの胎動
-- 效果：
-- ①：以场上1只表侧表示怪兽为对象才能把这张卡发动。发动后变成持有以下效果的效果怪兽（水族·光·10星·攻/守0）在怪兽区域特殊召唤（也当作陷阱卡使用）。
-- ●对方回合作为对象的表侧表示怪兽从场上离开时这张卡破坏。对方回合这张卡从场上离开时作为对象的表侧表示怪兽破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含卡片发动、陷阱怪兽特召、以及在对方回合因对象离场而自毁、因自身离场而破坏对象的永续/状态监控效果
function s.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能把这张卡发动。发动后变成持有以下效果的效果怪兽（水族·光·10星·攻/守0）在怪兽区域特殊召唤（也当作陷阱卡使用）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ●对方回合作为对象的表侧表示怪兽从场上离开时这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.condition)
	e2:SetOperation(s.sdestroy)
	c:RegisterEffect(e2)
	-- ●对方回合这张卡从场上离开时作为对象的表侧表示怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD_P)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(s.check)
	c:RegisterEffect(e3)
	-- ●对方回合这张卡从场上离开时作为对象的表侧表示怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetLabelObject(e3)
	e4:SetCondition(s.condition)
	e4:SetOperation(s.tdestroy)
	c:RegisterEffect(e4)
end
-- 卡片发动时的效果处理目标判定，检查场上是否存在表侧表示怪兽作为对象、自身怪兽区域是否有空位、以及是否能将自身作为陷阱怪兽特殊召唤
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以作为效果对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查自身的主要怪兽区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能将这张卡作为特定属性、种族、等级、攻守的陷阱怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1a4,TYPES_EFFECT_TRAP_MONSTER,0,0,10,RACE_AQUA,ATTRIBUTE_LIGHT) end
	-- 向玩家发送提示信息，要求选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息，表明此效果包含特殊召唤自身的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 卡片发动时的效果处理函数，将自身作为陷阱怪兽特殊召唤，并与选择的对象怪兽建立连接关系
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否已无空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 或者检查是否已无法将这张卡作为陷阱怪兽特殊召唤，若满足其一则不处理
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1a4,TYPES_EFFECT_TRAP_MONSTER,0,0,10,RACE_AQUA,ATTRIBUTE_LIGHT) then return end
	local c=e:GetHandler()
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将这张卡在自己的怪兽区域以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then c:SetCardTarget(tc) end
end
-- 离场破坏效果的触发条件判定函数，仅在对方回合触发
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 对象怪兽离场时，破坏这张卡的效果处理函数
function s.sdestroy(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	-- 如果作为对象的怪兽在离场的卡片中，则将这张卡破坏
	if tc and eg:IsContains(tc) then Duel.Destroy(e:GetHandler(),REASON_EFFECT) end
end
-- 在这张卡离场前，记录其效果是否被无效的状态
function s.check(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsDisabled() then e:SetLabel(1) else e:SetLabel(0) end
end
-- 这张卡离场时，破坏作为对象的怪兽的效果处理函数
function s.tdestroy(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if e:GetLabelObject():GetLabel()==0 and tc and tc:IsLocation(LOCATION_MZONE) then
		-- 将作为对象的怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
