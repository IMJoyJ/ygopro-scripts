--ヴァルモニカの異神－ジュラルメ
-- 效果：
-- 效果怪兽1只
-- 这张卡的连接召唤若非自己的灵摆区域的天使族怪兽卡的响鸣指示物是3个以上的场合则不能进行，自己对「异响鸣之异神-光耀天使」1回合只能有1次特殊召唤。
-- ①：这张卡连接召唤的场合，以最多有自己的灵摆区域的响鸣指示物数量的对方场上的怪兽为对象才能发动。那些怪兽破坏。
-- ②：把自己的灵摆区域3个响鸣指示物取除才能发动。这个回合，这张卡在同1次的战斗阶段中可以作3次攻击。
local s,id,o=GetID()
-- 初始化卡片效果：注册连接召唤限制、①连接召唤成功破坏对方怪兽效果、②去除响鸣指示物增加攻击次数效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册连接召唤手续：效果怪兽1只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT),1,1)
	-- 这张卡的连接召唤若非自己的灵摆区域的天使族怪兽卡的响鸣指示物是3个以上的场合则不能进行，自己对「异响鸣之异神-光耀天使」1回合只能有1次特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_COST)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCost(s.spcost)
	c:RegisterEffect(e1)
	c:SetSPSummonOnce(id)
	-- ①：这张卡连接召唤的场合，以最多有自己的灵摆区域的响鸣指示物数量的对方场上的怪兽为对象才能发动。那些怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- ②：把自己的灵摆区域3个响鸣指示物去除才能发动。这个回合，这张卡在同1次的战斗阶段中可以作3次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.tacon)
	e3:SetCost(s.tacost)
	e3:SetTarget(s.tatg)
	e3:SetOperation(s.taop)
	c:RegisterEffect(e3)
end
s.mentioned_counter={
	[0x6a]=true,
}
-- 灵摆区域卡片过滤条件：天使族怪兽卡且响鸣指示物在3个以上
function s.cfilter(c)
	return c:GetOriginalRace()&RACE_FAIRY>0 and c:GetOriginalType()&TYPE_MONSTER>0 and c:GetCounter(0x6a)>2
end
-- 连接召唤Cost条件检查：非连接召唤直接允许，连接召唤需灵摆区存在满足条件的卡
function s.spcost(e,c,tp,st)
	if st&SUMMON_TYPE_LINK~=SUMMON_TYPE_LINK then return true end
	-- 检查自己灵摆区域是否存在响鸣指示物为3个以上的天使族怪兽卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,nil)
end
-- ①效果发动条件：此卡为连接召唤成功
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ①效果发动准备：计算灵摆区响鸣指示物总数，选择最多该数量的对方怪兽作为对象并设置破坏操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	local ct=0
	-- 获取自己灵摆区域的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 统计灵摆区域卡片上的响鸣指示物总数量
	for tc in aux.Next(g) do ct=ct+tc:GetCounter(0x6a) end
	-- 发动条件检查：指示物大于0且对方场上存在可成为对象的怪兽
	if chk==0 then return ct>0 and Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择破坏目标卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1到ct只怪兽作为连锁对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,ct,nil)
	-- 设置连锁操作信息：破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- ①效果处理：将选中的目标怪兽破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 破坏关联连锁的所有目标怪兽
	Duel.Destroy(Duel.GetTargetsRelateToChain(),REASON_EFFECT)
end
-- ②效果发动条件：当前可以进入战斗阶段
function s.tacon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否能够进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 响鸣指示物去除Cost检查辅助函数：判断选择的卡组去除指示物总数是否大于2
function s.chk(g,tp)
	local tl=0
	-- 遍历灵摆区域组合卡片
	for tc in aux.Next(g) do
		local ct=0
		for i=1,3 do
			if tc:IsCanRemoveCounter(tp,0x6a,i,REASON_COST) then ct=i end
		end
		tl=tl+ct
	end
	return tl>2
end
-- ②效果发动Cost：从灵摆区域卡片中累计去除3个响鸣指示物
function s.tacost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己灵摆区域的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if chk==0 then return g:CheckSubGroup(s.chk,1,99,tp) end
	local ct=0
	while ct<3 do
		-- 显示选择要去除指示物的表侧表示卡片提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		local tc=g:FilterSelect(tp,Card.IsCanRemoveCounter,1,1,nil,tp,0x6a,1,REASON_COST):GetFirst()
		tc:RemoveCounter(tp,0x6a,1,REASON_COST)
		ct=ct+1
	end
end
-- ②效果发动准备：检查自身当前是否未拥有额外攻击效果
function s.tatg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEffectCount(EFFECT_EXTRA_ATTACK)==0 end
end
-- ②效果处理：为自身赋予在本回合同一战斗阶段中可以攻击3次的效果
function s.taop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 这个回合，这张卡在同1次的战斗阶段中可以作3次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(2)
	c:RegisterEffect(e1)
end
