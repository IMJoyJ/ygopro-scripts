--閃刀機－アディルセイバー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的战斗阶段，把这张卡从手卡丢弃，以场上1只「闪刀」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1500。
-- ②：这张卡在墓地存在的状态，怪兽特殊召唤的场合，以自己场上1只「闪刀」连接怪兽为对象才能发动。这张卡当作攻击力上升1500的装备魔法卡使用给那只怪兽装备。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：自己·对方的战斗阶段，把这张卡从手卡丢弃，以场上1只「闪刀」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.atkcon)
	e1:SetCost(s.atkcost)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，怪兽特殊召唤的场合，以自己场上1只「闪刀」连接怪兽为对象才能发动。这张卡当作攻击力上升1500的装备魔法卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"当作装备卡"
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定函数（战斗阶段且非伤害计算后）
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为战斗阶段，且不在伤害计算后
	return Duel.IsBattlePhase() and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 效果①的发动代价处理函数（从手卡丢弃）
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身作为发动代价丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 效果①的对象过滤条件（表侧表示的「闪刀」怪兽）
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x115)
end
-- 效果①的发动目标选择与合法性检测函数
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.atkfilter(chkc) end
	-- 判定场上是否存在可以作为效果①对象的「闪刀」怪兽
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择场上1只表侧表示的「闪刀」怪兽作为对象
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果①的效果处理（使目标怪兽攻击力上升1500）
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		-- 那只怪兽的攻击力直到回合结束时上升1500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 效果②的对象过滤条件（自己场上表侧表示的「闪刀」连接怪兽）
function s.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x115) and c:IsType(TYPE_LINK)
end
-- 效果②的发动目标选择与合法性检测函数
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	-- 判定自己场上是否有可用的魔法与陷阱区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判定自己场上是否存在可以作为效果②对象的「闪刀」连接怪兽
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家选择自己场上1只「闪刀」连接怪兽作为对象
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁信息，表明该效果包含将自身装备的操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置连锁信息，表明该效果包含卡片离开墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理（将自身作为装备卡装备给目标怪兽，并使其攻击力上升1500）
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果②选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 判定自身不受王家之谷影响且仍在墓地，且目标怪兽仍在场上表侧表示存在
	if aux.NecroValleyFilter()(c) and c:IsRelateToChain() and tc:IsFaceup() and tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 将自身作为装备卡装备给目标怪兽，若装备失败则结束处理
		if not Duel.Equip(tp,c,tc) then return end
		-- 这张卡当作装备魔法卡使用给那只怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 攻击力上升1500
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(1500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 装备限制判定函数（限制只能装备给选择的目标怪兽）
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
