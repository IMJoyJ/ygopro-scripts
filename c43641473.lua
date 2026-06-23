--移り気な仕立屋
-- 效果：
-- 把怪兽装备的1张装备卡，转换给1只别的能变成正确对象的怪兽。
function c43641473.initial_effect(c)
	-- 效果定义：将卡牌效果注册为发动类型，具有取对象效果属性，提示时点为装备时点，效果代码为自由连锁
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_EQUIP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c43641473.target)
	e1:SetOperation(c43641473.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查目标怪兽是否表侧表示且能成为装备卡的装备对象
function c43641473.tcfilter(tc,ec)
	return tc:IsFaceup() and ec:CheckEquipTarget(tc)
end
-- 过滤函数：检查装备卡是否为装备类型且已装备怪兽，且存在能成为该装备卡装备对象的怪兽
function c43641473.ecfilter(c)
	-- 装备卡过滤条件：装备卡为装备类型且已装备怪兽，且存在能成为该装备卡装备对象的怪兽
	return c:IsType(TYPE_EQUIP) and c:GetEquipTarget()~=nil and Duel.IsExistingTarget(c43641473.tcfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,c:GetEquipTarget(),c)
end
-- 效果处理函数：判断是否满足发动条件，选择装备卡和目标怪兽
function c43641473.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件判断：判断场上是否存在满足条件的装备卡
	if chk==0 then return Duel.IsExistingTarget(c43641473.ecfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	-- 提示选择装备卡：向玩家提示选择一张装备卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(43641473,0))  --"请选择一张装备卡"
	-- 选择装备卡：从场上选择一张满足条件的装备卡
	local g=Duel.SelectTarget(tp,c43641473.ecfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	local ec=g:GetFirst()
	e:SetLabelObject(ec)
	-- 提示选择目标怪兽：向玩家提示选择要转移装备的对象
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(43641473,1))  --"请选择要转移装备的对象"
	-- 选择目标怪兽：选择能成为装备卡装备对象的怪兽
	local tc=Duel.SelectTarget(tp,c43641473.tcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,ec:GetEquipTarget(),ec)
end
-- 效果执行函数：执行装备转移操作
function c43641473.operation(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetLabelObject()
	-- 获取连锁对象：获取当前连锁中选择的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==ec then tc=g:GetNext() end
	if ec:IsFaceup() and ec:IsRelateToEffect(e) then
		-- 执行装备转移：将装备卡装备给目标怪兽
		Duel.Equip(tp,ec,tc)
	end
end
