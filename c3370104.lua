--サイバー・フェニックス
-- 效果：
-- ①：只要这张卡在怪兽区域攻击表示存在，只以自己场上的机械族怪兽1只为对象的魔法·陷阱卡的效果无效化。
-- ②：这张卡被战斗破坏送去墓地时才能发动。自己从卡组抽1张。
function c3370104.initial_effect(c)
	-- ①：只要这张卡在怪兽区域攻击表示存在，只以自己场上的机械族怪兽1只为对象的魔法·陷阱卡的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(c3370104.distg)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域攻击表示存在，只以自己场上的机械族怪兽1只为对象的魔法·陷阱卡的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c3370104.disop)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗破坏送去墓地时才能发动。自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(3370104,0))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCondition(c3370104.condition)
	e3:SetTarget(c3370104.target)
	e3:SetOperation(c3370104.operation)
	c:RegisterEffect(e3)
end
-- 作为EFFECT_DISABLE的过滤函数：仅当电子凤凰攻击表示，且被检查的魔法·陷阱卡当前只以1只自己场上的表侧表示机械族怪兽为对象时返回true，从而将该魔法·陷阱卡的效果无效化。
function c3370104.distg(e,c)
	if not e:GetHandler():IsAttackPos() or c:GetCardTargetCount()~=1 then return false end
	local tc=c:GetFirstCardTarget()
	return tc:IsControler(e:GetHandlerPlayer()) and tc:IsFaceup() and tc:IsRace(RACE_MACHINE)
end
-- 连锁处理时点：若电子凤凰攻击表示，且正在发动的效果是取对象的魔法·陷阱卡（非怪兽效果），并且其对象只有1只自己场上的表侧机械族怪兽，则将那次连锁的效果无效。
function c3370104.disop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsAttackPos() or re:IsActiveType(TYPE_MONSTER) then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	-- 获取当前正在处理的连锁（ev）所登记的对象卡组；没有对象则返回nil。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return end
	local tc=g:GetFirst()
	if tc:IsControler(tp) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() and tc:IsRace(RACE_MACHINE) then
		-- 将连锁ev的效果无效化，即让符合条件的那张魔法·陷阱卡的效果处理被无效。
		Duel.NegateEffect(ev)
	end
end
-- ②的发动条件：电子凤凰被战斗破坏后确实送去墓地，位于墓地且破坏原因属于战斗，并且被破坏前是表侧表示。
function c3370104.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:IsPreviousPosition(POS_FACEUP)
end
-- ②发动时：检查自己能否抽1张卡，并把抽卡对象玩家设为自己、抽卡数设为1，同时登记操作信息为抽卡。
function c3370104.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：若在发动时（chk=0），确认自己当前可以因效果抽1张卡；不能抽则不允许发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 把当前连锁的目标玩家设为自己（tp），表示将由自己进行抽卡。
	Duel.SetTargetPlayer(tp)
	-- 把当前连锁的目标参数设为1，表示预计抽卡张数为1。
	Duel.SetTargetParam(1)
	-- 登记操作信息：这次连锁包含抽卡效果，目标玩家为tp，抽1张牌；因为不取对象，目标卡组部分填nil。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：从连锁信息中取出目标玩家和抽卡张数，让该玩家以效果原因抽对应数量的卡。
function c3370104.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取之前设置的目标玩家p和目标参数d（抽卡张数）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡，完成②的抽卡处理。
	Duel.Draw(p,d,REASON_EFFECT)
end
