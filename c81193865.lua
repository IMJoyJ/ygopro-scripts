--エターナル・エヴォリューション・バースト
-- 效果：
-- 机械族融合怪兽才能装备。
-- ①：只要这张卡在魔法与陷阱区域存在，自己战斗阶段中对方不能把魔法·陷阱·怪兽的效果发动。
-- ②：装备怪兽向对方怪兽攻击的伤害步骤结束时，从自己墓地把1只「电子龙」怪兽除外才能发动。装备怪兽向对方怪兽可以继续攻击。这个效果发动的回合，装备怪兽以外的自己怪兽不能攻击。
function c81193865.initial_effect(c)
	-- 机械族融合怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c81193865.target)
	e1:SetOperation(c81193865.operation)
	c:RegisterEffect(e1)
	-- 机械族融合怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(c81193865.eqlimit)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己战斗阶段中对方不能把魔法·陷阱·怪兽的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(c81193865.actcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ②：装备怪兽向对方怪兽攻击的伤害步骤结束时，从自己墓地把1只「电子龙」怪兽除外才能发动。装备怪兽向对方怪兽可以继续攻击。这个效果发动的回合，装备怪兽以外的自己怪兽不能攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(81193865,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c81193865.cacon)
	e4:SetCost(c81193865.cacost)
	e4:SetTarget(c81193865.catg)
	e4:SetOperation(c81193865.caop)
	c:RegisterEffect(e4)
	if not c81193865.global_check then
		c81193865.global_check=true
		c81193865[0]=0
		c81193865[1]=0
		-- 这个效果发动的回合，装备怪兽以外的自己怪兽不能攻击。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(c81193865.checkop)
		-- 注册全局效果，用于检测本回合是否有其他怪兽进行过攻击宣告
		Duel.RegisterEffect(ge1,0)
		-- 从自己墓地把1只「电子龙」怪兽除外才能发动。装备怪兽向对方怪兽可以继续攻击。这个效果发动的回合，装备怪兽以外的自己怪兽不能攻击。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c81193865.clear)
		-- 注册全局效果，在回合开始时重置攻击宣告次数的计数
		Duel.RegisterEffect(ge2,0)
	end
end
-- 攻击宣告时的操作，记录当前回合玩家进行攻击宣告的怪兽数量，并给该怪兽添加标记
function c81193865.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:GetFlagEffect(81193865)==0 then
		c81193865[ep]=c81193865[ep]+1
		tc:RegisterFlagEffect(81193865,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 重置双方玩家本回合进行过攻击宣告的怪兽数量计数
function c81193865.clear(e,tp,eg,ep,ev,re,r,rp)
	c81193865[0]=0
	c81193865[1]=0
end
-- 装备限制：只能装备给机械族·融合怪兽
function c81193865.eqlimit(e,c)
	return c:IsRace(RACE_MACHINE) and c:IsType(TYPE_FUSION)
end
-- 过滤条件：场上表侧表示的机械族·融合怪兽
function c81193865.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_FUSION)
end
-- 装备魔法卡发动时的效果目标选择与处理信息设置
function c81193865.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c81193865.eqfilter(chkc) end
	-- 检查场上是否存在可以装备的合法目标
	if chk==0 then return Duel.IsExistingTarget(c81193865.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只符合条件的怪兽作为装备对象并设为效果目标
	Duel.SelectTarget(tp,c81193865.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功后的装备处理
function c81193865.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 对方不能发动效果的永续效果的适用条件判定
function c81193865.actcon(e)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	-- 判定当前是否为自己的战斗阶段
	return Duel.GetTurnPlayer()==e:GetHandler():GetControler() and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 连击效果的发动条件判定
function c81193865.cacon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定是否为装备怪兽向对方怪兽进行攻击的伤害步骤结束时
	return Duel.GetAttacker()==e:GetHandler():GetEquipTarget() and Duel.GetAttackTarget()~=nil
end
-- 过滤条件：自己墓地可以除外的「电子龙」怪兽
function c81193865.cafilter(c)
	return c:IsSetCard(0x1093) and c:IsAbleToRemoveAsCost()
end
-- 连击效果的发动代价与攻击限制的适用处理
function c81193865.cacost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己墓地是否存在可以作为代价除外的「电子龙」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c81193865.cafilter,tp,LOCATION_GRAVE,0,1,nil)
		and (c81193865[tp]==0 or c:GetEquipTarget():GetFlagEffect(81193865)~=0) end
	-- 从自己墓地把1只「电子龙」怪兽除外才能发动。装备怪兽向对方怪兽可以继续攻击。这个效果发动的回合，装备怪兽以外的自己怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c81193865.ftarget)
	e1:SetLabel(c:GetEquipTarget():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果，限制装备怪兽以外的自己怪兽在本回合不能攻击
	Duel.RegisterEffect(e1,tp)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1只「电子龙」怪兽
	local g=Duel.SelectMatchingCard(tp,c81193865.cafilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的「电子龙」怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 攻击限制的目标过滤：除装备怪兽以外的自己场上的怪兽
function c81193865.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 连击效果的发动目标判定
function c81193865.catg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在怪兽，且装备怪兽是否可以继续攻击
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		and e:GetHandler():GetEquipTarget():IsChainAttackable(0,true) end
end
-- 连击效果的效果处理
function c81193865.caop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if not ec:IsRelateToBattle() then return end
	-- 使装备怪兽可以继续进行1次攻击
	Duel.ChainAttack()
	-- 装备怪兽向对方怪兽可以继续攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE+PHASE_DAMAGE_CAL)
	ec:RegisterEffect(e1)
end
