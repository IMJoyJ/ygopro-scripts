--光器の瀑布
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：指定自己场上的通常怪兽以及「塞尼特」仪式怪兽数量的对方的主要怪兽区域才能发动。这个回合中，指定的区域各有1次，发动的怪兽的效果无效化。
-- ②：自己场上的通常怪兽卡的攻击力合计比3000高的场合，把墓地的这张卡除外，以对方场上1只怪兽为对象才能发动。那只怪兽送去墓地。
local s,id,o=GetID()
-- 初始化效果
function s.initial_effect(c)
	-- ①：指定自己场上的通常怪兽以及「塞尼特」仪式怪兽数量的对方的主要怪兽区域才能发动。这个回合中，指定的区域各有1次，发动的怪兽的效果无效化。
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
	-- 将墓地的这张卡除外作为代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 过滤通常怪兽或「塞尼特」仪式怪兽
function s.cfilter(c)
	return c:IsFaceup() and (c:IsType(TYPE_NORMAL) or c:IsSetCard(0x1eb) and c:IsType(TYPE_RITUAL))
end
-- 选择对应数量的对方主要怪兽区域
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计场上的通常怪兽及「塞尼特」仪式怪兽数量
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return ct>0 end
	local diss={}
	-- 让玩家选择对方的主要怪兽区域
	local dis=Duel.SelectField(tp,math.min(ct,5),0,LOCATION_MZONE,0x60<<16)
	for i=0,4 do
		if dis&(1<<(i+16))~=0 then
			table.insert(diss,i)
		end
	end
	e:SetLabel(table.unpack(diss))
	-- 提示选中的区域
	Duel.Hint(HINT_ZONE,tp,dis)
end
-- 为每个指定区域注册怪兽效果无效化处理
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
		-- 注册区域怪兽效果无效化效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断发动怪兽效果的区域是否在指定区域中
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁发动的区域、位置与控制者
	local loc,seq,p=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE,CHAININFO_TRIGGERING_CONTROLER)
	return rp==1-tp and p==1-tp and re:IsActiveType(TYPE_MONSTER)
		and loc&LOCATION_MZONE~=0 and seq==e:GetLabel()
end
-- 无效该怪兽效果
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 展示卡片提示
	Duel.Hint(HINT_CARD,0,id)
	-- 使发动的效果无效
	Duel.NegateEffect(ev)
end
-- 过滤表侧表示通常怪兽卡
function s.csfilter(c)
	return c:IsFaceup() and c:IsAllCardTypes(TYPE_NORMAL+TYPE_MONSTER)
end
-- 获取通常怪兽卡的攻击力
function s.getatk(c)
	if c:IsType(TYPE_MONSTER) then
		return c:GetAttack()
	else
		return c:GetBaseAttack()
	end
end
-- 确认场上通常怪兽卡攻击力合计是否大于3000
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上的通常怪兽卡
	local g=Duel.GetMatchingGroup(s.csfilter,tp,LOCATION_ONFIELD,0,nil)
	return g:GetSum(s.getatk)>3000
end
-- 选择对方场上1只怪兽为对象
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToGrave() end
	-- 检查对方场上是否存在可送去墓地的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示选择要送去墓地的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方场上1只怪兽为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 将对象怪兽送去墓地的效果处理
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 将对象怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
