--スパークガン
-- 效果：
-- 「元素英雄 电光侠」才能装备。自己的回合的主要阶段时可以把1只表侧表示的怪兽的表示形式改变。这个效果使用3次后，这张卡破坏。
function c97362768.initial_effect(c)
	-- 为卡片添加「元素英雄」系列怪兽列表
	aux.AddSetNameMonsterList(c,0x3008)
	-- 「元素英雄 电光侠」才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c97362768.target)
	e1:SetOperation(c97362768.operation)
	c:RegisterEffect(e1)
	-- 「元素英雄 电光侠」才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c97362768.eqlimit)
	c:RegisterEffect(e2)
	-- 自己的回合的主要阶段时可以把1只表侧表示的怪兽的表示形式改变。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(97362768,0))  --"改变表示形式"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCost(c97362768.poscost)
	e3:SetTarget(c97362768.postg)
	e3:SetOperation(c97362768.posop)
	c:RegisterEffect(e3)
	-- 这个效果使用3次后，这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_CHAIN_SOLVED)
	e4:SetRange(LOCATION_SZONE)
	e4:SetOperation(c97362768.sdesop)
	c:RegisterEffect(e4)
end
-- 装备限制：只能装备给「元素英雄 电光侠」
function c97362768.eqlimit(e,c)
	return c:IsCode(20721928)
end
-- 过滤条件：场上表侧表示的「元素英雄 电光侠」
function c97362768.filter(c)
	return c:IsFaceup() and c:IsCode(20721928)
end
-- 装备卡发动时的对象选择与效果处理
function c97362768.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c97362768.filter(chkc) end
	-- 检查场上是否存在可以装备的表侧表示的「元素英雄 电光侠」
	if chk==0 then return Duel.IsExistingTarget(c97362768.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只表侧表示的「元素英雄 电光侠」作为装备对象
	Duel.SelectTarget(tp,c97362768.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡发动成功后的效果处理：将此卡装备给目标怪兽
function c97362768.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取装备的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 改变表示形式效果的启动费用：为装备卡添加1个计数标记
function c97362768.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(97362768,RESET_EVENT+RESETS_STANDARD,0,0)
end
-- 过滤条件：场上表侧表示且可以改变表示形式的怪兽
function c97362768.posfilter(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- 改变表示形式效果的对象选择与效果处理
function c97362768.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c97362768.posfilter(chkc) end
	-- 检查场上是否存在可以改变表示形式的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c97362768.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择1只表侧表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c97362768.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 改变表示形式效果的具体处理
function c97362768.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取要改变表示形式的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽的表示形式改变（表侧攻击表示与表侧守备表示互相转换）
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
-- 检查效果使用次数，若达到3次则将此卡破坏
function c97362768.sdesop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(97362768)==3 then
		-- 因规则原因破坏这张卡
		Duel.Destroy(e:GetHandler(),REASON_RULE)
	end
end
