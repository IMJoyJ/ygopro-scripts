--FA－ホープ・レイ・ランサー
-- 效果：
-- 4星怪兽×3
-- 「重铠装-希望鳍条枪兵」1回合1次也能把手卡1张魔法·陷阱卡丢弃，在自己场上的4阶以下的超量怪兽上面重叠来超量召唤。
-- ①：对方场上的怪兽的攻击力下降500。
-- ②：自己·对方的战斗阶段开始时才能发动。对方场上的全部攻击表示怪兽的效果无效化。
-- ③：这张卡的攻击破坏对方怪兽时，把这张卡1个超量素材取除才能发动。这张卡只再1次可以继续攻击。
function c1269512.initial_effect(c)
	aux.AddXyzProcedure(c,nil,4,3,c1269512.ovfilter,aux.Stringid(1269512,0),3,c1269512.xyzop)  --"是否在4阶以下的超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- 效果原文：①：对方场上的怪兽的攻击力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-500)
	c:RegisterEffect(e1)
	-- 效果原文：②：自己·对方的战斗阶段开始时才能发动。对方场上的全部攻击表示怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1269512,2))  --"对方场上攻击表示的怪兽效果无效化"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c1269512.distg)
	e2:SetOperation(c1269512.disop)
	c:RegisterEffect(e2)
	-- 效果原文：③：这张卡的攻击破坏对方怪兽时，把这张卡1个超量素材取除才能发动。这张卡只再1次可以继续攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1269512,3))  --"取除超量素材再次攻击"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCountLimit(1)
	e3:SetCondition(c1269512.atcon)
	e3:SetCost(c1269512.atcost)
	e3:SetOperation(c1269512.atop)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查手牌中是否存在魔法·陷阱卡
function c1269512.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDiscardable()
end
-- 过滤函数：检查场上是否存在4阶以下的表侧表示怪兽
function c1269512.ovfilter(c)
	return c:IsFaceup() and c:IsRankBelow(4)
end
-- XYZ召唤时的处理函数：检查是否满足条件并丢弃手牌中的魔法·陷阱卡
function c1269512.xyzop(e,tp,chk)
	-- 判断是否满足XYZ召唤条件：检查玩家是否未使用过此效果且手牌中存在魔法·陷阱卡
	if chk==0 then return Duel.GetFlagEffect(tp,1269512)==0 and Duel.IsExistingMatchingCard(c1269512.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃手牌中的魔法·陷阱卡操作
	Duel.DiscardHand(tp,c1269512.cfilter,1,1,REASON_COST+REASON_DISCARD)
	-- 注册标识效果：标记玩家在本回合已使用过此效果
	Duel.RegisterFlagEffect(tp,1269512,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 过滤函数：检查是否为可被无效化的攻击表示怪兽
function c1269512.filter(c)
	-- 判断是否为可被无效化的攻击表示怪兽：检查怪兽是否为攻击表示且未被无效化
	return aux.NegateMonsterFilter(c) and c:IsAttackPos()
end
-- 设置无效化效果的目标函数：检查是否存在可无效化的怪兽
function c1269512.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足无效化效果发动条件：检查场上是否存在可无效化的攻击表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c1269512.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取满足条件的攻击表示怪兽组
	local g=Duel.GetMatchingGroup(c1269512.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息：将要处理的怪兽组和数量设置为无效化效果的目标
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 无效化效果的处理函数：对目标怪兽施加无效化和无效化效果
function c1269512.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的攻击表示怪兽组
	local g=Duel.GetMatchingGroup(c1269512.filter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为怪兽施加无效化效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 为怪兽施加无效化效果
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- 判断是否满足再次攻击条件：检查是否为攻击怪兽、是否因战斗破坏且是否可连锁攻击
function c1269512.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否满足再次攻击条件：检查是否为攻击怪兽、是否因战斗破坏且是否可连锁攻击
	return Duel.GetAttacker()==c and aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and c:IsChainAttackable()
end
-- 支付再次攻击代价的函数：检查并移除1个超量素材
function c1269512.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 再次攻击效果的处理函数：使攻击怪兽可再进行1次攻击
function c1269512.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行再次攻击操作
	Duel.ChainAttack()
end
