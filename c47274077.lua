--ネオス・フォース
-- 效果：
-- 「元素英雄 新宇侠」才能装备。装备怪兽的攻击力上升800。装备怪兽战斗破坏怪兽送去墓地时，给与对方基本分破坏怪兽的攻击力数值的伤害。结束阶段时把这张卡加入卡组洗切。
function c47274077.initial_effect(c)
	-- 记录卡片记载了“元素英雄 新宇侠”的卡名
	aux.AddCodeList(c,89943723)
	-- 将“元素英雄”系列编码添加至该卡的怪兽系列列表
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
-- 定义装备限制：仅能装备给“元素英雄 新宇侠”
function c47274077.eqlimit(e,c)
	return c:IsCode(89943723)
end
-- 过滤场上表侧表示的“元素英雄 新宇侠”
function c47274077.filter(c)
	return c:IsFaceup() and c:IsCode(89943723)
end
-- 装备魔法发动时的对象选择处理函数
function c47274077.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c47274077.filter(chkc) end
	-- 检查场上是否存在可成为装备对象的合法怪兽
	if chk==0 then return Duel.IsExistingTarget(c47274077.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置选择卡片时的提示文字
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择并锁定一个表侧表示的“元素英雄 新宇侠”作为装备对象
	Duel.SelectTarget(tp,c47274077.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法发动后的效果处理函数
function c47274077.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作，将此卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 检查是否为装备怪兽通过战斗破坏了怪兽并送入墓地
function c47274077.damcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	local bc=ec:GetBattleTarget()
	return ec==e:GetHandler():GetEquipTarget() and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE)
end
-- 伤害效果的发动准备，计算被破坏怪兽的攻击力
function c47274077.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ec=eg:GetFirst()
	local bc=ec:GetBattleTarget()
	local dam=bc:GetAttack()
	-- 设置效果处理的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果处理的参数为伤害数值
	Duel.SetTargetParam(dam)
	-- 设置效果处理信息为给与对方伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 伤害效果的执行函数
function c47274077.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动阶段确定的伤害对象玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行伤害处理，给与对方玩家基本分伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 返回卡组效果的发动准备
function c47274077.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息为将此卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 返回卡组效果的执行函数
function c47274077.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡送回持有者卡组并洗牌
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
