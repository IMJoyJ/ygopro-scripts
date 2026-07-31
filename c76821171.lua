--ヴァルモニカの異神－ジュラルメ
-- 效果：
-- 效果怪兽1只
-- 这张卡的连接召唤若非自己的灵摆区域的天使族怪兽卡的响鸣指示物是3个以上的场合则不能进行，自己对「异响鸣之异神-光耀天使」1回合只能有1次特殊召唤。
-- ①：这张卡连接召唤的场合，以最多有自己的灵摆区域的响鸣指示物数量的对方场上的怪兽为对象才能发动。那些怪兽破坏。
-- ②：把自己的灵摆区域3个响鸣指示物取除才能发动。这个回合，这张卡在同1次的战斗阶段中可以作3次攻击。
local s,id,o=GetID()
-- 初始化卡片效果：设置连接召唤手续、连接召唤条件与特召限制、①连接召唤成功破坏对方怪兽、②去除指示物获得3次攻击效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续：效果怪兽1只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT),1,1)
	-- 这张卡的连接召唤若非自己的灵摆区域的天使族怪兽卡的响鸣指示物是3个以上的场合不能进行
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
-- 连接召唤Cost过滤条件：原本种族为天使族的怪兽卡且放置有3个以上响鸣指示物
function s.cfilter(c)
	return c:GetOriginalRace()&RACE_FAIRY>0 and c:GetOriginalType()&TYPE_MONSTER>0 and c:GetCounter(0x6a)>2
end
-- 连接召唤手续检查：若为连接召唤，检查己方灵摆区是否有符合条件的卡
function s.spcost(e,c,tp,st)
	if st&SUMMON_TYPE_LINK~=SUMMON_TYPE_LINK then return true end
	-- 检查己方灵摆区是否存在放置有3个以上响鸣指示物的天使族怪兽卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,nil)
end
-- ①效果触发条件：此卡连接召唤成功
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ①效果发动准备：计算己方灵摆区响鸣指示物总数
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	local ct=0
	-- 获取己方灵摆区域的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 遍历灵摆区卡片并累加响鸣指示物数量
	for tc in aux.Next(g) do ct=ct+tc:GetCounter(0x6a) end
	-- 发动条件检查：响鸣指示物大于0且对方场上有可作为对象的怪兽
	if chk==0 then return ct>0 and Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上最多等同于指示物数量的怪兽作为对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,ct,nil)
	-- 设置连锁操作信息：破坏选中的目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- ①效果处理：破坏所有选择的目标怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 破坏与连锁相关的目标怪兽
	Duel.Destroy(Duel.GetTargetsRelateToChain(),REASON_EFFECT)
end
-- ②效果触发条件：当前处于可以进入战斗阶段的状态
function s.tacon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家当前是否能够进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 指示物去除检查：判断所选卡片组合能否合计去除至少3个响鸣指示物
function s.chk(g,tp)
	local tl=0
	-- 遍历灵摆区组合中的每张卡片
	for tc in aux.Next(g) do
		local ct=0
		for i=1,3 do
			if tc:IsCanRemoveCounter(tp,0x6a,i,REASON_COST) then ct=i end
		end
		tl=tl+ct
	end
	return tl>2
end
-- ②效果Cost：从己方灵摆区卡片上合计去除3个响鸣指示物
function s.tacost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方灵摆区域的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if chk==0 then return g:CheckSubGroup(s.chk,1,99,tp) end
	local ct=0
	while ct<3 do
		-- 提示玩家选择要去除指示物的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		local tc=g:FilterSelect(tp,Card.IsCanRemoveCounter,1,1,nil,tp,0x6a,1,REASON_COST):GetFirst()
		tc:RemoveCounter(tp,0x6a,1,REASON_COST)
		ct=ct+1
	end
end
-- ②效果发动条件检查：此卡当前尚未获得多次攻击能力
function s.tatg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEffectCount(EFFECT_EXTRA_ATTACK)==0 end
end
-- ②效果处理：赋予此卡在本回合同1次战斗阶段中可以攻击3次的能力
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
