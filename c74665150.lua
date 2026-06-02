--デコード・トーカー・インテグレーション
-- 效果：
-- 效果怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在额外怪兽区域存在，这张卡的攻击力上升这张卡以外的双方的场上·墓地的连接怪兽数量×500，对方不能把这张卡作为效果的对象。
-- ②：自己·对方回合，把这张卡所连接区1只自己怪兽解放才能发动。从额外卡组把1只电子界族怪兽送去墓地。这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
local s,id,o=GetID()
-- 初始化卡片效果：添加连接召唤手续、设置苏生限制、注册额外怪兽区域存在时的攻击力提升效果和不能成为对方效果对象效果、以及通过解放连接区怪兽将电子界怪兽送墓并增加攻击次数的效果
function s.initial_effect(c)
	-- 效果怪兽2只以上
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	c:EnableReviveLimit()
	-- ①：只要这张卡在额外怪兽区域存在，这张卡的攻击力上升这张卡以外的双方的场上·墓地的连接怪兽数量×500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.atkcon)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- 对方不能把这张卡作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	-- 设置不能成为效果对象效果的阻抗类型：不受对手的卡片效果选择为对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ②：自己·对方回合，把这张卡所连接区1只自己怪兽解放才能发动。从额外卡组把1只电子界族怪兽送去墓地。这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCost(s.tgcost)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
-- 判断自身是否处于额外怪兽区域（序列号大于4）
function s.atkcon(e)
	return e:GetHandler():GetSequence()>4
end
-- 过滤条件：表侧表示存在且属于连接怪兽的卡片
function s.atkfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_LINK)
end
-- 计算攻击力上升数值的函数
function s.atkval(e,c)
	-- 计算并返回双方场上及墓地除了此卡以外的所有连接怪兽数量×500的数值
	return Duel.GetMatchingGroupCount(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,e:GetHandler())*500
end
-- 过滤条件：被解放的卡必须处于此卡的连接区，且未在战斗中被破坏
function s.cfilter(c,g)
	return g:IsContains(c) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 效果②的发动代价处理：解放此卡连接区的1只自己怪兽
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 代价可行性检查：检查自己场上此卡的连接区是否存在可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,lg) end
	-- 让玩家从连接区选择1只自己怪兽
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,lg)
	-- 解放选择的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 过滤条件：可以送去墓地的电子界族怪兽
function s.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_CYBERSE) and c:IsAbleToGrave()
end
-- 效果②发动的合法性检查与操作信息注册
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：额外卡组中是否存在可送去墓地的电子界族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：将1张卡从额外卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的实际处理逻辑
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从额外卡组选择1只满足条件的电子界族怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的电子界族怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
	if not c:IsRelateToChain() then return end
	-- 这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
