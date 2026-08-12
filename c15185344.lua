--燦冠乗騎シックラヴィー
-- 效果：
-- 3星怪兽×2
-- 「灿冠乘骑 经典三冠海人马」1回合1次也能在自己场上的攻击力2000以下的兽族怪兽上面重叠来超量召唤。这张卡不能作为超量召唤的素材。
-- ①：这张卡战斗破坏怪兽的场合发动。给这张卡放置1个冠指示物。那之后，这张卡的冠指示物数量的以下效果适用。
-- ●1个：这张卡的攻击力上升400。
-- ●2个：这张卡的攻击力上升600。
-- ●3个：这张卡回到额外卡组，自己抽3张。
local s,id,o=GetID()
local COUNTER_CROWN=0x77
-- 初始化效果：添加超量召唤手续（3星怪兽×2，并可在满足条件的兽族怪兽上重叠召唤）、设置苏生限制、允许放置冠指示物，注册不能作为超量素材的效果外文本以及战斗破坏怪兽时发动的放置指示物诱发必发效果
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,3,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)  --"是否在兽族怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	c:EnableCounterPermit(COUNTER_CROWN)
	-- 这张卡不能作为超量召唤的素材。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	-- ①：这张卡战斗破坏怪兽的场合发动。给这张卡放置1个冠指示物。那之后，这张卡的冠指示物数量的以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"放置指示物"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOEXTRA+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(s.ctcon)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
end
s.mentioned_counter={
	[0x77]=true,
}
-- 超量召唤的重叠素材条件：对象是表侧表示的攻击力2000以下的兽族怪兽
function s.ovfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST) and c:IsAttackBelow(2000)
end
-- 重叠超量召唤时的操作：检查本回合是否已用此方式超量召唤过，若没有则记录本回合已使用的誓约标记（1回合1次的限制）
function s.xyzop(e,tp,chk)
	-- 检测本回合是否尚未用兽族怪兽重叠方式进行过超量召唤（用于1回合1次的判定）
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 为玩家注册本回合已进行过重叠超量召唤的誓约标记，结束阶段重置，实现1回合1次的限制
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 效果发动条件：这张卡表侧表示存在且与战斗相关联（即这张卡战斗破坏了怪兽）
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsRelateToBattle()
end
-- 根据放置后冠指示物的数量预判本次效果分类：1个或2个时为攻击力上升，3个时为回到额外卡组和抽卡，否则无分类
function s.predcat(ct)
	if ct==1 or ct==2 then
		return CATEGORY_ATKCHANGE
	elseif ct==3 then
		return CATEGORY_TOEXTRA+CATEGORY_DRAW
	else
		return 0
	end
end
-- 效果目标设定：计算放置1个冠指示物后的数量，据此设定效果分类；攻击力上升时以这张卡为对象设置攻击变化操作信息；回到额外时设置回额外操作信息，并设定抽卡玩家为自己、抽卡张数为3的抽卡操作信息
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	local ct=c:GetCounter(COUNTER_CROWN)+1
	local cat=s.predcat(ct)
	e:SetCategory(cat)
	if cat&CATEGORY_ATKCHANGE~=0 then
		-- 设置操作信息：本次连锁将使这张卡的攻击力上升
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,c,1,0,0)
	elseif cat&CATEGORY_TOEXTRA~=0 then
		-- 设置操作信息：本次连锁将使这张卡回到额外卡组
		Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,c,1,0,0)
		-- 把本次连锁的对象玩家设置为自己（作为之后抽卡的玩家）
		Duel.SetTargetPlayer(tp)
		-- 把本次连锁的对象参数设置为3（即要抽的卡的数量）
		Duel.SetTargetParam(3)
		-- 设置操作信息：本次连锁将让自己抽3张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
	end
end
-- 效果处理：确认这张卡与连锁相关且表侧表示，给这张卡放置1个冠指示物，再按冠指示物数量适用效果——1个时攻击力上升400，2个时上升600，3个时取回连锁设定的玩家和抽卡数，将这张卡回到额外卡组成功后让自己抽3张
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToChain() and c:IsFaceup()) then return end
	if not c:AddCounter(COUNTER_CROWN,1) then return end
	local ct=c:GetCounter(COUNTER_CROWN)
	if ct==1 then
		-- 中断效果处理时点，使之后的攻击力上升不与放置指示物同时处理（错时点）
		Duel.BreakEffect()
		s.atkup(c,400)
	elseif ct==2 then
		-- 中断效果处理时点，使之后的攻击力上升不与放置指示物同时处理（错时点）
		Duel.BreakEffect()
		s.atkup(c,600)
	elseif ct==3 then
		-- 中断效果处理时点，使之后的回到额外卡组和抽卡不与放置指示物同时处理（错时点）
		Duel.BreakEffect()
		-- 取回当前连锁设定的对象玩家和对象参数（即发动时设定的抽卡玩家和抽卡张数3）
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 将这张卡以效果原因洗回卡组（回到额外卡组），并确认其确实位于额外卡组
		if Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and c:IsLocation(LOCATION_EXTRA) then
			-- 让对象玩家以效果原因抽出对象参数数量的卡（自己抽3张）
			Duel.Draw(p,d,REASON_EFFECT)
		end
	end
end
-- 给这张卡注册一个上升指定数值攻击力的永续效果（离场等标准重置条件下失效）
function s.atkup(c,val)
	-- ●1个：这张卡的攻击力上升400。●2个：这张卡的攻击力上升600。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(val)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
