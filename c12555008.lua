--光器の瀑布
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：指定自己场上的通常怪兽以及「塞尼特」仪式怪兽数量的对方的主要怪兽区域才能发动。这个回合中，指定的区域各有1次，发动的怪兽的效果无效化。
-- ②：自己场上的通常怪兽卡的攻击力合计比3000高的场合，把墓地的这张卡除外，以对方场上1只怪兽为对象才能发动。那只怪兽送去墓地。
local s,id,o=GetID()
-- 初始化卡片效果，注册效果①（卡的发动·指定区域无效怪兽效果）与效果②（墓地起动除外送墓怪兽）
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：指定自己场上的通常怪兽以及「塞尼特」仪式怪兽数量的对方的主要怪兽区域才能发动。这个回合中，指定的区域各有1次，发动的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"指定区域"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的通常怪兽卡的攻击力合计比3000高的场合，把墓地的这张卡除外，以对方场上1只怪兽为对象才能发动。那只怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(s.tgcon)
	-- 效果②发动Cost：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的通常怪兽或「塞尼特」仪式怪兽
function s.cfilter(c)
	return c:IsFaceup() and (c:IsType(TYPE_NORMAL) or c:IsSetCard(0x1eb) and c:IsType(TYPE_RITUAL))
end
-- 效果①发动条件判断及区域选择：指定对方主要怪兽区域
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上通常怪兽及「塞尼特」仪式怪兽的数量
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return ct>0 end
	local diss={}
	-- 让玩家选择对应数量的对方主要怪兽区域
	local dis=Duel.SelectField(tp,math.min(ct,5),0,LOCATION_MZONE,0x60<<16)
	for i=0,4 do
		if dis&(1<<(i+16))~=0 then
			table.insert(diss,i)
		end
	end
	e:SetLabel(table.unpack(diss))
	-- 在场上显示被选中的区域提示
	Duel.Hint(HINT_ZONE,tp,dis)
end
-- 效果①处理：为每个指定区域注册该回合各1次无效怪兽效果的全局效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local t={e:GetLabel()}
	for i,v in ipairs(t) do
		-- 这个回合中，指定的区域各有1次，发动的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetCountLimit(1)
		e1:SetLabel(v)
		e1:SetCondition(s.negcon)
		e1:SetOperation(s.negop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册该区域的无效效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断发动效果的怪兽是否处于指定的对方主要怪兽区域
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and rc:IsRelateToChain(ev)
		and rc:IsControler(1-tp) and rc:IsLocation(LOCATION_MZONE) and rc:GetSequence()==e:GetLabel()
end
-- 无效该怪兽发动的效果
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示本卡卡片动画提示
	Duel.Hint(HINT_CARD,0,id)
	-- 使该连锁的效果处理无效
	Duel.NegateEffect(ev)
end
-- 过滤条件：场上表侧表示的通常怪兽卡
function s.csfilter(c)
	return c:IsFaceup() and c:IsAllCardTypes(TYPE_NORMAL+TYPE_MONSTER)
end
-- 获取卡片攻击力（若是怪兽卡则取当前攻击力，否则取原本攻击力）
function s.getatk(c)
	if c:IsType(TYPE_MONSTER) then
		return c:GetAttack()
	else
		return c:GetBaseAttack()
	end
end
-- 效果②生效条件：自己场上的通常怪兽卡的攻击力合计大于3000
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的通常怪兽卡
	local g=Duel.GetMatchingGroup(s.csfilter,tp,LOCATION_ONFIELD,0,nil)
	return g:GetSum(s.getatk)>3000
end
-- 效果②目标选择及操作信息设置：以对方场上1只怪兽为对象
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToGrave() end
	-- 检查对方场上是否存在可以送去墓地的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要送去墓地的怪兽作为对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方场上1只怪兽作为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将对象怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果②处理：将作为对象的对方怪兽送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 将目标怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
