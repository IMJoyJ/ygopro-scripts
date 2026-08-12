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
c35058588.mentioned_counter={
	[0x1038]=true,
}
-- 过滤函数：筛选表侧表示的「方界」怪兽
function c35058588.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe3)
end
-- 效果①的对象选择函数：检查双方场上是否存在满足条件的可作为对象的怪兽
function c35058588.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在1只可作为对象的表侧表示「方界」怪兽
	if chk==0 then return Duel.IsExistingTarget(c35058588.atkfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在1只可作为对象的表侧表示怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家请选择自己的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)  --"请选择自己的卡"
	-- 选择自己场上1只表侧表示的「方界」怪兽作为效果对象
	Duel.SelectTarget(tp,c35058588.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家请选择对方的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	e:SetLabelObject(g:GetFirst())
end
-- 效果①的处理：使作为对象的自己怪兽攻击力变成2倍、对方怪兽攻击力变成一半
function c35058588.atkop(e,tp,eg,ep,ev,re,r,rp)
	local hc=e:GetLabelObject()
	-- 取得当前连锁的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==hc then tc=g:GetNext() end
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 那只自己怪兽的攻击力变成2倍
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if hc:IsFaceup() and hc:IsRelateToEffect(e) then
			-- 那只对方怪兽的攻击力变成一半
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_ATTACK_FINAL)
			e2:SetValue(math.ceil(hc:GetAttack()/2))
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			hc:RegisterEffect(e2)
		end
	end
end
-- 过滤函数：筛选可作为代价除外的「方界」怪兽
function c35058588.cfilter(c)
	return c:IsSetCard(0xe3) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 过滤函数：筛选表侧表示、可成为效果对象且可以放置方界指示物的怪兽
function c35058588.tgfilter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e) and c:IsCanAddCounter(0x1038,1)
end
-- 效果②的对象选择函数：检查这张卡自身可否除外、对方场上可放置指示物的怪兽数量以及墓地中可作为代价的「方界」怪兽
function c35058588.countertg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsCanAddCounter(0x1038,1) end
	-- 取得对方场上所有表侧表示且可以放置方界指示物的怪兽
	local tg=Duel.GetMatchingGroup(c35058588.tgfilter,tp,0,LOCATION_MZONE,nil,e)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and tg:GetCount()>0
		-- 检查自己墓地是否存在至少1只可作为代价除外的「方界」怪兽
		and Duel.IsExistingMatchingCard(c35058588.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1至对方场上可放置指示物的怪兽数量只「方界」怪兽
	local g=Duel.SelectMatchingCard(tp,c35058588.cfilter,tp,LOCATION_GRAVE,0,1,tg:GetCount(),nil)
	local ct=g:GetCount()
	g:AddCard(e:GetHandler())
	-- 将这张卡和选择的「方界」怪兽表侧表示除外作为代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 提示玩家请选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=tg:Select(tp,ct,ct,nil)
	-- 把除外的「方界」怪兽数量的对方场上表侧表示怪兽设置为当前连锁的对象
	Duel.SetTargetCard(sg)
end
-- 效果②的处理：给每只对象怪兽各放置1个方界指示物，并使其不能攻击、效果无效化
function c35058588.counterop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡中仍与本效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1038,1)
		-- 有方界指示物放置的怪兽不能攻击
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
-- 判定条件：该怪兽放置有1个以上方界指示物
function c35058588.disable(e)
	return e:GetHandler():GetCounter(0x1038)>0
end
