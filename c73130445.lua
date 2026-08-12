--EMリザードロー
-- 效果：
-- ←6 【灵摆】 6→
-- 「娱乐伙伴 抽卡蜥蜴」的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段在另一边的自己的灵摆区域有「娱乐伙伴 抽卡蜥蜴」以外的「娱乐伙伴」卡存在的场合才能发动。这张卡破坏，自己从卡组抽1张。
-- 【怪兽效果】
-- 「娱乐伙伴 抽卡蜥蜴」的怪兽效果1回合只能使用1次。
-- ①：这张卡以外的自己场上的表侧表示怪兽被对方怪兽的攻击或者对方的效果破坏的场合才能发动。自己从卡组抽出自己场上的「娱乐伙伴」怪兽的数量。
function c73130445.initial_effect(c)
	-- 为卡片注册灵摆怪兽的灵摆属性（灵摆召唤、灵摆卡的发动等）
	aux.EnablePendulumAttribute(c)
	-- 「娱乐伙伴 抽卡蜥蜴」的灵摆效果1回合只能使用1次。①：自己主要阶段在另一边的自己的灵摆区域有「娱乐伙伴 抽卡蜥蜴」以外的「娱乐伙伴」卡存在的场合才能发动。这张卡破坏，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,73130445)
	e2:SetTarget(c73130445.destg)
	e2:SetOperation(c73130445.desop)
	c:RegisterEffect(e2)
	-- 「娱乐伙伴 抽卡蜥蜴」的怪兽效果1回合只能使用1次。①：这张卡以外的自己场上的表侧表示怪兽被对方怪兽的攻击或者对方的效果破坏的场合才能发动。自己从卡组抽出自己场上的「娱乐伙伴」怪兽的数量。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,73130446)
	e3:SetCondition(c73130445.drcon)
	e3:SetTarget(c73130445.drtg)
	e3:SetOperation(c73130445.drop)
	c:RegisterEffect(e3)
end
-- 过滤条件：另一边灵摆区域的「娱乐伙伴 抽卡蜥蜴」以外的「娱乐伙伴」卡
function c73130445.desfilter(c)
	return c:IsSetCard(0x9f) and not c:IsCode(73130445)
end
-- 灵摆效果的发动准备：检查是否可以抽卡、另一边灵摆区是否有符合条件的卡、自身是否可破坏
function c73130445.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查另一边的灵摆区域是否存在「娱乐伙伴 抽卡蜥蜴」以外的「娱乐伙伴」卡
		and Duel.IsExistingMatchingCard(c73130445.desfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
		and e:GetHandler():IsDestructable() end
	-- 设置操作信息：破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 灵摆效果的处理：破坏自身，并抽1张卡
function c73130445.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试用效果破坏自身，并判断是否破坏成功
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
		-- 玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 过滤条件：自己场上原本表侧表示的怪兽，且是被对方怪兽的攻击或对方的效果破坏
function c73130445.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		-- 检查破坏原因是否为对方的效果破坏，或者是作为攻击对象被战斗破坏
		and (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp or c:IsReason(REASON_BATTLE) and c==Duel.GetAttackTarget())
end
-- 怪兽效果的发动条件：检查被破坏的卡中是否存在满足条件的怪兽
function c73130445.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c73130445.cfilter,1,nil,tp)
end
-- 过滤条件：自己场上表侧表示的「娱乐伙伴」怪兽
function c73130445.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f)
end
-- 怪兽效果的发动准备：计算自己场上「娱乐伙伴」怪兽的数量，并检查是否可以抽对应数量的卡
function c73130445.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上表侧表示的「娱乐伙伴」怪兽的数量
	local ct=Duel.GetMatchingGroupCount(c73130445.filter,tp,LOCATION_MZONE,0,nil)
	-- 检查自己场上是否有「娱乐伙伴」怪兽，且玩家是否可以抽对应数量的卡
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	-- 设置操作信息：抽卡，数量为自己场上「娱乐伙伴」怪兽的数量
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 怪兽效果的处理：计算自己场上「娱乐伙伴」怪兽的数量，并抽对应数量的卡
function c73130445.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新计算当前自己场上表侧表示的「娱乐伙伴」怪兽的数量
	local ct=Duel.GetMatchingGroupCount(c73130445.filter,tp,LOCATION_MZONE,0,nil)
	-- 玩家从卡组抽出对应数量的卡
	Duel.Draw(tp,ct,REASON_EFFECT)
end
