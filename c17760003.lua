--A・ジェネクス・トライアーム
-- 效果：
-- 「次世代控制员」＋调整以外的怪兽1只以上
-- ①：1回合1次，可以丢弃1张手卡，从作为这张卡的同调素材的除调整以外的怪兽属性的以下效果选择1个发动。
-- ●风：对方手卡随机1张送去墓地。
-- ●水：以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
-- ●暗：以场上1只光属性怪兽为对象才能发动。那只光属性怪兽破坏，自己抽1张。
function c17760003.initial_effect(c)
	-- 为该怪兽添加同调召唤所需的素材代码列表，允许使用卡号为68505803的「次世代控制员」作为素材
	aux.AddMaterialCodeList(c,68505803)
	-- 设置该怪兽的同调召唤手续，要求1只卡号为68505803的调整和1只调整以外的怪兽作为同调素材
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsCode,68505803),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 当该怪兽特殊召唤成功时，检查其同调素材中包含的属性并记录到效果标签中
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c17760003.valcheck)
	c:RegisterEffect(e1)
	-- 当该怪兽特殊召唤成功时，根据其同调素材中包含的属性，注册对应的起动效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c17760003.regcon)
	e2:SetOperation(c17760003.regop)
	c:RegisterEffect(e2)
	e2:SetLabelObject(e1)
end
-- 遍历该怪兽的同调素材，提取非调整且非「次世代控制员」的怪兽属性，并通过位运算保留风、水、暗三种属性
function c17760003.valcheck(e,c)
	local g=c:GetMaterial()
	local att=0
	local tc=g:GetFirst()
	while tc do
		if not tc:IsCode(68505803) or not tc:IsType(TYPE_TUNER) then
			att=bit.bor(att,tc:GetAttribute())
		end
		tc=g:GetNext()
	end
	att=bit.band(att,0x2a)
	e:SetLabel(att)
end
-- 判断该怪兽是否为同调召唤成功，并且其同调素材中包含至少一种属性
function c17760003.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
		and e:GetLabelObject():GetLabel()~=0
end
-- 根据该怪兽的同调素材属性，注册对应的起动效果，包括风、水、暗三种属性的效果
function c17760003.regop(e,tp,eg,ep,ev,re,r,rp)
	local att=e:GetLabelObject():GetLabel()
	local c=e:GetHandler()
	if bit.band(att,ATTRIBUTE_WIND)~=0 then
		-- 注册风属性效果，丢弃1张手卡后随机选择对方1张手卡送去墓地
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(17760003,0))  --"对方手牌随机1张送去墓地"
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
		e1:SetCost(c17760003.cost)
		e1:SetTarget(c17760003.target1)
		e1:SetOperation(c17760003.operation1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(17760003,3))  --"风属性怪兽作为同调素材"
	end
	if bit.band(att,ATTRIBUTE_WATER)~=0 then
		-- 注册水属性效果，丢弃1张手卡后选择场上1张魔法或陷阱卡破坏
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(17760003,1))  --"场上存在的1张魔法或者陷阱卡破坏"
		e1:SetCategory(CATEGORY_DESTROY)
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
		e1:SetCost(c17760003.cost)
		e1:SetTarget(c17760003.target2)
		e1:SetOperation(c17760003.operation2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(17760003,4))  --"水属性怪兽作为同调素材"
	end
	if bit.band(att,ATTRIBUTE_DARK)~=0 then
		-- 注册暗属性效果，丢弃1张手卡后选择场上1只光属性怪兽破坏并抽1张卡
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(17760003,2))  --"场上表侧表示存在的1只光属性怪兽破坏"
		e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
		e1:SetCost(c17760003.cost)
		e1:SetTarget(c17760003.target3)
		e1:SetOperation(c17760003.operation3)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(17760003,5))  --"暗属性怪兽作为同调素材"
	end
end
-- 检查玩家手牌是否存在可丢弃的卡牌，若存在则丢弃1张手牌作为效果的费用
function c17760003.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌是否存在可丢弃的卡牌
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃1张手牌的操作，作为效果的费用
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 设置风属性效果的目标，检查对方手牌是否存在
function c17760003.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手牌是否存在
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 设置风属性效果的处理信息，指定将对方手牌送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND)
end
-- 执行风属性效果，随机选择对方1张手牌送去墓地
function c17760003.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家对方手牌的卡组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(tp,1)
	-- 将随机选择的对方手牌送去墓地
	Duel.SendtoGrave(sg,REASON_EFFECT)
end
-- 定义过滤函数，用于筛选魔法或陷阱卡
function c17760003.filter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置水属性效果的目标，检查场上是否存在魔法或陷阱卡
function c17760003.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c17760003.filter2(chkc) end
	-- 检查场上是否存在魔法或陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c17760003.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法或陷阱卡作为目标
	local g=Duel.SelectTarget(tp,c17760003.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置水属性效果的处理信息，指定破坏目标卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行水属性效果，破坏目标卡
function c17760003.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 定义过滤函数，用于筛选表侧表示的光属性怪兽
function c17760003.filter3(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 设置暗属性效果的目标，检查场上是否存在光属性怪兽
function c17760003.target3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c17760003.filter3(chkc) end
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查场上是否存在光属性怪兽
		and Duel.IsExistingTarget(c17760003.filter3,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只光属性怪兽作为目标
	local g=Duel.SelectTarget(tp,c17760003.filter3,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置暗属性效果的处理信息，指定破坏目标卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置暗属性效果的处理信息，指定抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行暗属性效果，破坏目标光属性怪兽并抽1张卡
function c17760003.operation3(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且为光属性怪兽，并破坏该怪兽
	if tc:IsRelateToEffect(e) and c17760003.filter3(tc) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 执行抽卡操作，为玩家抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
