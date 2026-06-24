--ラーの翼神竜
-- 效果：
-- 这张卡不能特殊召唤。这张卡通常召唤的场合，必须把3只解放作召唤。
-- ①：这张卡的召唤不会被无效化。
-- ②：在这张卡的召唤成功时双方不能把其他卡的效果发动。
-- ③：这张卡召唤时，把基本分支付到变成100基本分才能发动。这张卡的攻击力·守备力上升支付的数值。
-- ④：支付1000基本分，以场上1只怪兽为对象才能发动。那只怪兽破坏。
function c10000010.initial_effect(c)
	-- 这张卡通常召唤的场合，必须把3只解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10000010,2))  --"把3只解放作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(c10000010.ttcon)
	e1:SetOperation(c10000010.ttop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 这张卡通常召唤的场合，必须把3只解放作召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	e2:SetCondition(c10000010.setcon)
	c:RegisterEffect(e2)
	-- ①：这张卡的召唤不会被无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e3)
	-- ②：在这张卡的召唤成功时双方不能把其他卡的效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetOperation(c10000010.sumsuc)
	c:RegisterEffect(e4)
	-- 这张卡不能特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_SPSUMMON_CONDITION)
	e5:SetValue(c10000010.splimit)
	c:RegisterEffect(e5)
	-- ③：这张卡召唤时，把基本分支付到变成100基本分才能发动。这张卡的攻击力·守备力上升支付的数值。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(10000010,0))  --"攻守上升"
	e6:SetCategory(CATEGORY_ATKCHANGE)
	e6:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e6:SetCode(EVENT_SUMMON_SUCCESS)
	e6:SetCost(c10000010.atkcost)
	e6:SetOperation(c10000010.atkop)
	c:RegisterEffect(e6)
	-- ④：支付1000基本分，以场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(10000010,1))  --"破坏"
	e7:SetCategory(CATEGORY_DESTROY)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCost(c10000010.descost)
	e7:SetTarget(c10000010.destg)
	e7:SetOperation(c10000010.desop)
	c:RegisterEffect(e7)
end
-- 召唤条件检查：检查所解放的怪兽数量是否为3，且场上存在可供解放的3只怪兽
function c10000010.ttcon(e,c,minc)
	if c==nil then return true end
	-- 检查可用于解放的怪兽数量是否满足3只
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 召唤操作函数：让玩家选择3只怪兽解放，并将它们设置为召唤素材
function c10000010.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 选择要解放的3只怪兽
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 解放选中的怪兽作为召唤的祭品
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 里侧盖放限制：阻止玩家将这张卡直接里侧盖放（Set）召唤
function c10000010.setcon(e,c,minc)
	if not c then return true end
	return false
end
-- 特殊召唤条件限制函数：实现不能特殊召唤的限制，但同时允许在满足游戏规则特定条件下，当存在其他关联卡效果时通过特定方式特殊召唤
function c10000010.splimit(e,se,sp,st)
	-- 检查玩家是否受到能够进行太阳神特殊召唤的特定效果影响
	return Duel.IsPlayerAffectedByEffect(sp,41044418)
		and (st&SUMMON_VALUE_MONSTER_REBORN>0 or se:GetHandler():IsCode(83764718))
		and e:GetHandler():IsControler(sp) and e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 生成一个限制连锁发动的匿名函数，阻止除指定卡片之外的效果进行连锁
function c10000010.genchainlm(c)
	return	function (e,rp,tp)
				return e:GetHandler()==c
			end
end
-- 召唤成功时效果处理：注册召唤成功时的时点，并将连锁限制设定为双方不能发动任何其他卡的效果
function c10000010.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 在召唤成功时将连锁限制设置为对方不能响应太阳神的发动
	Duel.SetChainLimitTillChainEnd(c10000010.genchainlm(e:GetHandler()))
end
-- 增加攻击力效果代价函数：检查自己基本分是否能支付到100点，若可以则扣除对应的基本分数值并将所支付的基本分数量记录在 label 中
function c10000010.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前发动玩家的生命值（基本分）
	local lp=Duel.GetLP(tp)
	-- 检查玩家当前基本分是否能支付到剩余100点
	if chk==0 then return Duel.CheckLPCost(tp,lp-100,true) end
	e:SetLabel(lp-100)
	-- 让玩家支付基本分，使其值降为100
	Duel.PayLPCost(tp,lp-100,true)
end
-- 增加攻击力效果操作函数：将之前支付的基本分数值作为此卡的攻击力和守备力上升量注册到此卡上
function c10000010.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力·守备力上升支付的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
-- 破坏效果代价函数：检查并扣除1000基本分
function c10000010.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否拥有至少1000点基本分来支付代价
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 扣除玩家1000点基本分作为效果发动的代价
	Duel.PayLPCost(tp,1000)
end
-- 破坏效果目标函数：检查场上是否存在可以作为对象的怪兽，并提示控制者选择1只怪兽作为效果的对象
function c10000010.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 检查场上（无论自己还是对方场上）是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示控制者玩家选择需要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上的1只怪兽作为本次破坏效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设定效果处理的预估信息：破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果操作函数：获取本次效果的对象，如果它依然存在于场上则将其破坏
function c10000010.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选择为效果对象的怪兽卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 通过效果破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
