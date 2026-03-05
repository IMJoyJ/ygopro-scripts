--暗遷士 カンゴルゴーム
-- 效果：
-- 4星怪兽×2
-- ①：只以场上的卡1张为对象的其他的魔法·陷阱·怪兽的效果发动时，把这张卡1个超量素材取除，以场上1张作为正确对象的别的卡为对象才能发动。那个效果的对象转移为作为正确对象的那张卡。
function c21501505.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为4的怪兽进行2次叠放
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：只以场上的卡1张为对象的其他的魔法·陷阱·怪兽的效果发动时，把这张卡1个超量素材取除，以场上1张作为正确对象的别的卡为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21501505,0))  --"对象转移"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c21501505.condition)
	e1:SetCost(c21501505.cost)
	e1:SetTarget(c21501505.target)
	e1:SetOperation(c21501505.operation)
	c:RegisterEffect(e1)
end
-- 判断是否为其他效果发动且该效果具有取对象属性，同时确认对象卡为场上的1张卡
function c21501505.condition(e,tp,eg,ep,ev,re,r,rp)
	if e==re or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的效果对象卡组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	return tc:IsOnField()
end
-- 支付效果发动的代价，移除自身1个超量素材
function c21501505.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义过滤函数，用于检查目标卡是否能成为指定连锁的对象
function c21501505.filter(c,ct)
	-- 检查目标卡是否能成为指定连锁的对象
	return Duel.CheckChainTarget(ct,c)
end
-- 设置效果的目标选择逻辑，包括对象卡的筛选和选择
function c21501505.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=ev
	-- 获取玩家0的标识效果Label值
	local label=Duel.GetFlagEffectLabel(0,21501505)
	if label then
		if ev==bit.rshift(label,16) then ct=bit.band(label,0xffff) end
	end
	if chkc then return chkc:IsOnField() and c21501505.filter(chkc,ct) end
	-- 检查是否存在满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(c21501505.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetLabelObject(),ct) end
	-- 向玩家提示选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择效果对象卡
	Duel.SelectTarget(tp,c21501505.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetLabelObject(),ct)
	local val=ct+bit.lshift(ev+1,16)
	if label then
		-- 设置标识效果的Label值
		Duel.SetFlagEffectLabel(0,21501505,val)
	else
		-- 注册全局标识效果并设置Label值
		Duel.RegisterFlagEffect(0,21501505,RESET_CHAIN,0,1,val)
	end
end
-- 执行效果操作，将连锁对象更换为选择的卡
function c21501505.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将连锁对象更换为指定卡
		Duel.ChangeTargetCard(ev,Group.FromCards(tc))
	end
end
