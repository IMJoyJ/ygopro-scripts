--EMレディアンジュ
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，自己和对方的怪兽之间进行战斗的攻击宣言时，从手卡丢弃1只灵摆怪兽才能发动。那只对方怪兽的攻击力直到回合结束时下降1000。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合只能有1次使用其中任意1个。
-- ①：从手卡把「娱乐伙伴 天使女士」以外的1只「娱乐伙伴」怪兽和这张卡丢弃才能发动。自己从卡组抽2张。
-- ②：这张卡在墓地存在，自己场上有「异色眼」卡或者「娱乐伙伴 粗鲁先生」存在的场合才能发动。这张卡在自己的灵摆区域放置。
function c58938528.initial_effect(c)
	-- 注册灵摆怪兽的灵摆属性（灵摆召唤、灵摆卡的发动等）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己和对方的怪兽之间进行战斗的攻击宣言时，从手卡丢弃1只灵摆怪兽才能发动。那只对方怪兽的攻击力直到回合结束时下降1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58938528,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c58938528.atkcon)
	e1:SetCost(c58938528.atkcost)
	e1:SetOperation(c58938528.atkop)
	c:RegisterEffect(e1)
	-- ①：从手卡把「娱乐伙伴 天使女士」以外的1只「娱乐伙伴」怪兽和这张卡丢弃才能发动。自己从卡组抽2张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58938528,1))  --"抽2张卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,58938528)
	e2:SetCost(c58938528.drcost)
	e2:SetTarget(c58938528.drtg)
	e2:SetOperation(c58938528.drop)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在，自己场上有「异色眼」卡或者「娱乐伙伴 粗鲁先生」存在的场合才能发动。这张卡在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(58938528,2))
	e3:SetCategory(CATEGORY_LEAVE_GRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,58938528)
	e3:SetCondition(c58938528.pencon)
	e3:SetTarget(c58938528.pentg)
	e3:SetOperation(c58938528.penop)
	c:RegisterEffect(e3)
end
-- 灵摆效果①的发动条件判定函数：自己和对方的怪兽之间进行战斗
function c58938528.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方和对方处于战斗中的怪兽
	local a,d=Duel.GetBattleMonster(tp)
	return a and d and d:IsFaceup()
end
-- 灵摆效果①的丢弃代价过滤函数：手卡中的灵摆怪兽
function c58938528.costfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsDiscardable()
end
-- 灵摆效果①的发动代价处理函数：从手卡丢弃1只灵摆怪兽
function c58938528.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只可丢弃的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c58938528.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择手卡中1只满足条件的灵摆怪兽作为代价丢弃
	Duel.DiscardHand(tp,c58938528.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 灵摆效果①的效果处理函数：使进行战斗的对方怪兽攻击力下降
function c58938528.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方进行战斗的怪兽
	local tc=Duel.GetBattleMonster(1-tp)
	if tc and tc:IsRelateToBattle() then
		-- 那只对方怪兽的攻击力直到回合结束时下降1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 怪兽效果①的丢弃代价过滤函数：手卡中「娱乐伙伴 天使女士」以外的「娱乐伙伴」怪兽
function c58938528.drfilter(c)
	return c:IsSetCard(0x9f) and c:IsType(TYPE_MONSTER) and not c:IsCode(58938528) and c:IsDiscardable()
end
-- 怪兽效果①的发动代价处理函数：将此卡和手卡中另一只「娱乐伙伴」怪兽丢弃
function c58938528.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查此卡是否可丢弃，且手卡中是否存在另一只可丢弃的「娱乐伙伴」怪兽
	if chk==0 then return c:IsDiscardable() and Duel.IsExistingMatchingCard(c58938528.drfilter,tp,LOCATION_HAND,0,1,c) end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 玩家选择手卡中1只「娱乐伙伴 天使女士」以外的「娱乐伙伴」怪兽
	local g=Duel.SelectMatchingCard(tp,c58938528.drfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将选中的卡和这张卡一起送去墓地
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 怪兽效果①的发动目标判定与效果分类注册函数
function c58938528.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置当前效果的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前效果的目标参数为2（抽卡数量）
	Duel.SetTargetParam(2)
	-- 注册连锁处理中的操作信息：玩家抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 怪兽效果①的效果处理函数：自己从卡组抽2张
function c58938528.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行效果抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 怪兽效果②的场地卡片过滤函数：场上表侧表示的「异色眼」卡或「娱乐伙伴 粗鲁先生」
function c58938528.penfilter(c)
	return (c:IsSetCard(0x99) or c:IsCode(21949879)) and c:IsFaceup()
end
-- 怪兽效果②的发动条件判定函数：自己场上有「异色眼」卡或者「娱乐伙伴 粗鲁先生」存在
function c58938528.pencon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张满足条件的卡
	return Duel.IsExistingMatchingCard(c58938528.penfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 怪兽效果②的发动目标判定与效果分类注册函数
function c58938528.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
	-- 注册连锁处理中的操作信息：此卡离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 怪兽效果②的效果处理函数：将这张卡在自己的灵摆区域放置
function c58938528.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡移动到自己的灵摆区域表侧表示放置
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
