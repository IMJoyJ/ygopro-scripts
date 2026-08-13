--ネオス・フォース
-- 效果：
-- 「元素英雄 新宇侠」才能装备。装备怪兽的攻击力上升800。装备怪兽战斗破坏怪兽送去墓地时，给与对方基本分破坏怪兽的攻击力数值的伤害。结束阶段时把这张卡加入卡组洗切。
function c47274077.initial_effect(c)
	-- 向这张卡登记卡号89943723（元素英雄 新宇侠），使相关判定能识别该卡名。
	aux.AddCodeList(c,89943723)
	-- 向这张卡登记「元素英雄」系列字段0x3008，用于支持与「元素英雄」怪兽相关的条件判定。
	aux.AddSetNameMonsterList(c,0x3008)
	-- 「元素英雄 新宇侠」才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c47274077.target)
	e1:SetOperation(c47274077.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(800)
	c:RegisterEffect(e2)
	-- 「元素英雄 新宇侠」才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c47274077.eqlimit)
	c:RegisterEffect(e3)
	-- 装备怪兽战斗破坏怪兽送去墓地时，给与对方基本分破坏怪兽的攻击力数值的伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(47274077,0))  --"伤害"
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCondition(c47274077.damcon)
	e4:SetTarget(c47274077.damtg)
	e4:SetOperation(c47274077.damop)
	c:RegisterEffect(e4)
	-- 结束阶段时把这张卡加入卡组洗切。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(47274077,1))  --"返回卡组"
	e5:SetCategory(CATEGORY_TODECK)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(c47274077.rettg)
	e5:SetOperation(c47274077.retop)
	c:RegisterEffect(e5)
end
-- 装备限制判断函数：只有卡号为89943723（元素英雄 新宇侠）的怪兽才能装备这张卡。
function c47274077.eqlimit(e,c)
	return c:IsCode(89943723)
end
-- 装备对象过滤函数：场上表侧表示且卡号为89943723的怪兽。
function c47274077.filter(c)
	return c:IsFaceup() and c:IsCode(89943723)
end
-- 魔法卡发动时的取对象处理：确认存在符合条件的装备对象后，让玩家选择1只表侧表示的「元素英雄 新宇侠」，并登记装备操作信息。
function c47274077.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c47274077.filter(chkc) end
	-- 发动合法性检查：己方场上是否存在1只表侧表示且卡号为89943723的怪兽可作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(c47274077.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向选择玩家发送提示消息，提示其选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方怪兽区域选择1只满足filter条件的表侧表示怪兽，并将其登记为效果对象。
	Duel.SelectTarget(tp,c47274077.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次操作将这张卡装备给对象怪兽（CATEGORY_EQUIP）。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时，若这张卡和对象怪兽都仍与效果相关且对象表侧表示，则将这张卡装备给对象怪兽。
function c47274077.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的第一个对象怪兽（装备对象）。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡，装备给对象怪兽tc，装备控制者为己方tp。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 伤害效果触发条件：进行战斗并战斗破坏怪兽的怪兽是这张卡的装备怪兽，且被破坏的怪兽因战斗被送去墓地。
function c47274077.damcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	local bc=ec:GetBattleTarget()
	return ec==e:GetHandler():GetEquipTarget() and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE)
end
-- 伤害效果处理前的目标设定：以对方玩家为伤害对象，伤害数值取被战斗破坏怪兽的攻击力。
function c47274077.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ec=eg:GetFirst()
	local bc=ec:GetBattleTarget()
	local dam=bc:GetAttack()
	-- 将连锁的对象玩家设为对方玩家（1-tp），即承受伤害的一方。
	Duel.SetTargetPlayer(1-tp)
	-- 将连锁的对象参数设为伤害数值dam（被战斗破坏怪兽的攻击力数值）。
	Duel.SetTargetParam(dam)
	-- 设置操作信息：本次效果处理将造成伤害，目标玩家为对方，伤害值为dam。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 伤害效果处理：从连锁信息取得目标玩家和伤害值，对目标玩家造成效果伤害。
function c47274077.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家和对象参数，依次赋给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害形式对玩家p造成d点伤害（REASON_EFFECT）。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 回卡组效果的发动目标处理：无额外条件，声明时将这张卡设为返回卡组的对象。
function c47274077.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次处理将把这张卡返回持有者卡组，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 效果处理时，将这张卡返回持有者的卡组并进行洗切。
function c47274077.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡送去持有者卡组，并置于需要洗切的位置（SEQ_DECKSHUFFLE表示洗切后随机返回卡组）。
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
