--ヴァルモニカの異神－ジュラルメ
-- 效果：
-- 效果怪兽1只
-- 这张卡的连接召唤若非自己的灵摆区域的天使族怪兽卡的响鸣指示物是3个以上的场合则不能进行，自己对「异响鸣之异神-光耀天使」1回合只能有1次特殊召唤。
-- ①：这张卡连接召唤的场合，以最多有自己的灵摆区域的响鸣指示物数量的对方场上的怪兽为对象才能发动。那些怪兽破坏。
-- ②：把自己的灵摆区域3个响鸣指示物取除才能发动。这个回合，这张卡在同1次的战斗阶段中可以作3次攻击。
local s,id,o=GetID()
-- 注册卡片的初始效果，包括连接召唤手续、连接召唤限制、同名卡一回合一次特召限制、连接召唤成功时破坏对方怪兽的效果，以及去除响鸣指示物获得3次攻击的效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：效果怪兽1只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT),1,1)
	-- 这张卡的连接召唤若非自己的灵摆区域的天使族怪兽卡的响鸣指示物是3个以上的场合则不能进行
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
	-- ②：把自己的灵摆区域3个响鸣指示物取除才能发动。这个回合，这张卡在同1次的战斗阶段中可以作3次攻击。
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
-- 过滤自身灵摆区域中原本是天使族怪兽且放置有3个以上响鸣指示物的卡
function s.cfilter(c)
	return c:GetOriginalRace()&RACE_FAIRY>0 and c:GetOriginalType()&TYPE_MONSTER>0 and c:GetCounter(0x6a)>2
end
-- 连接召唤限制的Cost判定：若为连接召唤，则检查自己灵摆区域是否存在满足条件的放置有3个以上响鸣指示物的天使族怪兽卡
function s.spcost(e,c,tp,st)
	if st&SUMMON_TYPE_LINK~=SUMMON_TYPE_LINK then return true end
	-- 检查自己灵摆区域是否存在至少1张满足过滤条件（原本是天使族怪兽且有3个以上响鸣指示物）的卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,nil)
end
-- 检查此卡是否是通过连接召唤的方式特殊召唤成功
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 破坏效果的靶向与合法性检查：计算自己灵摆区域的响鸣指示物总数，并选择对应数量的对方场上的怪兽作为对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	local ct=0
	-- 获取自己灵摆区域的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 遍历自己灵摆区域的卡片，累加它们之上的响鸣指示物数量
	for tc in aux.Next(g) do ct=ct+tc:GetCounter(0x6a) end
	-- 检查可行性：自己灵摆区域必须有响鸣指示物，且对方场上必须存在至少1只可以作为对象的怪兽
	if chk==0 then return ct>0 and Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择1到ct（指示物总数）张对方场上的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,ct,nil)
	-- 设置当前连锁的操作信息：破坏所选的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 破坏效果的执行：破坏所有仍与该连锁相关的对象怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 破坏所有在效果处理时仍与该连锁相关的对象怪兽
	Duel.Destroy(Duel.GetTargetsRelateToChain(),REASON_EFFECT)
end
-- 检查当前回合玩家是否能够进入战斗阶段
function s.tacon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否能够进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 辅助检查函数：检查所选的灵摆区卡片组中，能够取除的响鸣指示物总数是否大于等于3个
function s.chk(g,tp)
	local tl=0
	-- 遍历传入的卡片组
	for tc in aux.Next(g) do
		local ct=0
		for i=1,3 do
			if tc:IsCanRemoveCounter(tp,0x6a,i,REASON_COST) then ct=i end
		end
		tl=tl+ct
	end
	return tl>2
end
-- 攻击效果的代价处理：从自己的灵摆区域中选择并取除合计3个响鸣指示物
function s.tacost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己灵摆区域的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if chk==0 then return g:CheckSubGroup(s.chk,1,99,tp) end
	local ct=0
	while ct<3 do
		-- 提示玩家选择表侧表示的卡（用于取除指示物）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		local tc=g:FilterSelect(tp,Card.IsCanRemoveCounter,1,1,nil,tp,0x6a,1,REASON_COST):GetFirst()
		tc:RemoveCounter(tp,0x6a,1,REASON_COST)
		ct=ct+1
	end
end
-- 攻击效果的靶向与合法性检查：检查此卡当前是否未获得追加攻击的效果
function s.tatg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEffectCount(EFFECT_EXTRA_ATTACK)==0 end
end
-- 攻击效果的执行：赋予此卡在同一次战斗阶段中可以作3次攻击的效果
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
