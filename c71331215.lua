--ウォークライ・オーディール
-- 效果：
-- ①：「战吼试炼」在自己场上只能有1张表侧表示存在。
-- ②：作为这张卡的发动时的效果处理，给这张卡放置3个指示物。
-- ③：自己的「战吼」怪兽战斗破坏对方怪兽送去对方墓地时才能发动。这张卡1个指示物取除，自己从卡组抽1张。这个效果让这张卡的指示物全部被取除的场合，这张卡送去墓地。
function c71331215.initial_effect(c)
	c:EnableCounterPermit(0x5a,LOCATION_SZONE)
	c:SetUniqueOnField(1,0,71331215)
	-- ②：作为这张卡的发动时的效果处理，给这张卡放置3个指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c71331215.target)
	e1:SetOperation(c71331215.activate)
	c:RegisterEffect(e1)
	-- ③：自己的「战吼」怪兽战斗破坏对方怪兽送去对方墓地时才能发动。这张卡1个指示物取除，自己从卡组抽1张。这个效果让这张卡的指示物全部被取除的场合，这张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71331215,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c71331215.drcon)
	e2:SetTarget(c71331215.drtg)
	e2:SetOperation(c71331215.drop)
	c:RegisterEffect(e2)
end
-- 卡片发动时的效果处理（Target函数），用于检测是否能放置指示物
function c71331215.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查是否能向这张卡放置3个指示物
	if chk==0 then return Duel.IsCanAddCounter(tp,0x5a,3,e:GetHandler()) end
end
-- 卡片发动时的效果处理（Operation函数），给这张卡放置3个指示物
function c71331215.activate(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x5a,3)
end
-- 效果发动的条件：自己的「战吼」怪兽战斗破坏对方怪兽并送去墓地
function c71331215.drcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local at=tc:GetBattleTarget()
	return eg:GetCount()==1 and tc:IsLocation(LOCATION_GRAVE) and tc:IsReason(REASON_BATTLE)
		and at:IsRelateToBattle() and at:IsControler(tp) and at:IsSetCard(0x15f)
end
-- 抽卡效果的Target函数，检查是否能移去1个指示物并抽卡，并设置抽卡操作信息
function c71331215.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查是否能移去这张卡的1个指示物且自己是否可以抽卡
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x5a,1,REASON_EFFECT) and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡效果的对象玩家为当前回合玩家（自己）
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡效果的参数为1张
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的Operation函数，移去1个指示物并抽卡，若指示物全部被取除则将这张卡送去墓地
function c71331215.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:RemoveCounter(tp,0x5a,1,REASON_EFFECT) then
		-- 获取当前连锁设定的目标玩家和抽卡数量
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 如果成功抽卡且这张卡上的指示物数量变为0
		if Duel.Draw(p,d,REASON_EFFECT)~=0 and c:GetCounter(0x5a)==0 then
			-- 将这张卡送去墓地
			Duel.SendtoGrave(c,REASON_EFFECT)
		end
	end
end
