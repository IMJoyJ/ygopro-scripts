--方界波動
-- 效果：
-- ①：以自己场上1只「方界」怪兽和对方场上1只表侧表示怪兽为对象才能发动。那只自己怪兽的攻击力变成2倍，那只对方怪兽的攻击力变成一半。
-- ②：从自己墓地把这张卡和「方界」怪兽任意数量除外，以除外的「方界」怪兽数量的对方场上的表侧表示怪兽为对象才能发动。给那些怪兽各放置1个方界指示物。有方界指示物放置的怪兽不能攻击，效果无效化。
function c35058588.initial_effect(c)
	-- ①：以自己场上1只「方界」怪兽和对方场上1只表侧表示怪兽为对象才能发动。那只自己怪兽的攻击力变成2倍，那只对方怪兽的攻击力变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35058588,0))  --"改变攻击力"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c35058588.atktg)
	e1:SetOperation(c35058588.atkop)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把这张卡和「方界」怪兽任意数量除外，以除外的「方界」怪兽数量的对方场上的表侧表示怪兽为对象才能发动。给那些怪兽各放置1个方界指示物。有方界指示物放置的怪兽不能攻击，效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35058588,1))  --"放置指示物"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c35058588.countertg)
	e2:SetOperation(c35058588.counterop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选自己场上正面表示的「方界」怪兽
function c35058588.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe3)
end
-- 效果处理函数，检查是否满足发动条件
function c35058588.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在至少1只正面表示的「方界」怪兽
	if chk==0 then return Duel.IsExistingTarget(c35058588.atkfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少1只正面表示的怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择自己的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)  --"请选择自己的卡"
	-- 选择自己场上1只正面表示的「方界」怪兽作为对象
	Duel.SelectTarget(tp,c35058588.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 向玩家提示选择对方的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 选择对方场上1只正面表示的怪兽作为对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	e:SetLabelObject(g:GetFirst())
end
-- 效果处理函数，执行攻击力变更操作
function c35058588.atkop(e,tp,eg,ep,ev,re,r,rp)
	local hc=e:GetLabelObject()
	-- 获取当前连锁的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==hc then tc=g:GetNext() end
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 将目标怪兽的攻击力设置为原来的2倍
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if hc:IsFaceup() and hc:IsRelateToEffect(e) then
			-- 将目标怪兽的攻击力设置为原来的一半
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_ATTACK_FINAL)
			e2:SetValue(math.ceil(hc:GetAttack()/2))
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			hc:RegisterEffect(e2)
		end
	end
end
-- 过滤函数，用于筛选可以作为除外代价的「方界」怪兽
function c35058588.cfilter(c)
	return c:IsSetCard(0xe3) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 过滤函数，用于筛选可以被放置指示物的对方怪兽
function c35058588.tgfilter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e) and c:IsCanAddCounter(0x1038,1)
end
-- 效果处理函数，检查是否满足发动条件
function c35058588.countertg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsCanAddCounter(0x1038,1) end
	-- 获取对方场上正面表示且可被放置指示物的怪兽组
	local tg=Duel.GetMatchingGroup(c35058588.tgfilter,tp,0,LOCATION_MZONE,nil,e)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and tg:GetCount()>0
		-- 检查自己墓地是否存在至少1张「方界」怪兽可以除外
		and Duel.IsExistingMatchingCard(c35058588.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地中的「方界」怪兽作为除外对象
	local g=Duel.SelectMatchingCard(tp,c35058588.cfilter,tp,LOCATION_GRAVE,0,1,tg:GetCount(),nil)
	local ct=g:GetCount()
	g:AddCard(e:GetHandler())
	-- 将选中的卡从墓地除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 向玩家提示选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=tg:Select(tp,ct,ct,nil)
	-- 设置当前连锁的对象为选中的怪兽
	Duel.SetTargetCard(sg)
end
-- 效果处理函数，执行放置指示物及无效化效果
function c35058588.counterop(e,tp,eg,ep,ev,re,r,rp)
	-- 筛选出与当前效果相关的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1038,1)
		-- 使放置了方界指示物的怪兽不能攻击
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetCondition(c35058588.disable)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- 判断怪兽是否放置了方界指示物
function c35058588.disable(e)
	return e:GetHandler():GetCounter(0x1038)>0
end
