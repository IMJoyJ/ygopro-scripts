--ダグラの剣
-- 效果：
-- 只有天使族怪兽能装备这张卡。装备这张卡的怪兽攻击力上升500点。装备这张卡的怪兽对对方造成战斗伤害时，自己回复与伤害数值相同的基本分。
function c28106077.initial_effect(c)
	-- 装备效果，用于选择目标怪兽进行装备
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c28106077.target)
	e1:SetOperation(c28106077.operation)
	c:RegisterEffect(e1)
	-- 诱发效果，当装备怪兽对对方造成战斗伤害时触发，回复基本分
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetDescription(aux.Stringid(28106077,0))  --"LP回复"
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c28106077.reccon)
	e2:SetTarget(c28106077.rectg)
	e2:SetOperation(c28106077.recop)
	c:RegisterEffect(e2)
	-- 装备对象限制，只有天使族怪兽能装备此卡
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c28106077.eqlimit)
	c:RegisterEffect(e3)
	-- 装备后使装备怪兽攻击力上升500
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(500)
	c:RegisterEffect(e4)
end
-- 判断目标是否为天使族怪兽
function c28106077.eqlimit(e,c)
	return c:IsRace(RACE_FAIRY)
end
-- 筛选场上正面表示的天使族怪兽
function c28106077.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY)
end
-- 选择装备目标怪兽，设置效果处理信息
function c28106077.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c28106077.filter(chkc) end
	-- 判断是否存在符合条件的装备目标
	if chk==0 then return Duel.IsExistingTarget(c28106077.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备目标怪兽
	Duel.SelectTarget(tp,c28106077.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将装备卡装备给目标怪兽
function c28106077.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作
		Duel.Equip(tp,c,tc)
	end
end
-- 判断是否为装备怪兽对对方造成战斗伤害
function c28106077.reccon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and eg:IsContains(ec) and ep~=tp
end
-- 设置回复基本分的效果处理信息
function c28106077.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置回复基本分的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置回复基本分的伤害数值
	Duel.SetTargetParam(ev)
	-- 设置回复基本分的效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,0,0,tp,ev)
end
-- 执行回复基本分效果
function c28106077.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复对应数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
