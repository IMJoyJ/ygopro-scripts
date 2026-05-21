--エクシーズ・アーマー・トルピード
-- 效果：
-- 3星怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：没有超量素材的这张卡不能攻击。
-- ②：把这张卡2个超量素材取除才能发动。自己抽1张。
-- ③：只要这张卡装备中，以下效果适用。
-- ●装备怪兽进行战斗的场合，直到伤害步骤结束时，对方不能把卡的效果发动，对方场上的表侧表示怪兽的效果无效化。
-- ●装备怪兽是超量怪兽的场合，对方不能把装备怪兽作为效果的对象。
local s,id,o=GetID()
-- 注册卡片的初始效果，包括XYZ召唤手续、不能攻击限制、起动效果抽卡以及作为装备卡时的各项适用效果
function s.initial_effect(c)
	-- 设置XYZ召唤手续：3星怪兽×2
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- ①：没有超量素材的这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetCondition(s.attcon)
	c:RegisterEffect(e1)
	-- ②：把这张卡2个超量素材取除才能发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.drawcost)
	e2:SetTarget(s.drawtarget)
	e2:SetOperation(s.drawoperation)
	c:RegisterEffect(e2)
	-- ●装备怪兽进行战斗的场合，直到伤害步骤结束时，对方不能把卡的效果发动
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(s.actcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ●装备怪兽进行战斗的场合，直到伤害步骤结束时，对方场上的表侧表示怪兽的效果无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetCondition(s.actcon)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
	-- ●装备怪兽是超量怪兽的场合，对方不能把装备怪兽作为效果的对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置不能成为对方卡的效果的对象
	e5:SetValue(aux.tgoval)
	e5:SetCondition(s.targetcon)
	c:RegisterEffect(e5)
end
-- 检查装备怪兽是否为超量怪兽，作为对象抗性效果的适用条件
function s.targetcon(e)
	return e:GetHandler():GetEquipTarget():IsType(TYPE_XYZ)
end
-- 检查这张卡是否没有超量素材，作为不能攻击效果的适用条件
function s.attcon(e)
	return e:GetHandler():GetOverlayCount()==0
end
-- 抽卡效果的Cost：取除这张卡的2个超量素材
function s.drawcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 抽卡效果的Target：检查玩家是否能抽卡，并设置抽卡的目标玩家和数量
function s.drawtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以从卡组抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为1（抽卡张数）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的Operation：获取目标玩家和参数，执行抽卡
function s.drawoperation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 检查装备怪兽是否正在进行战斗，作为封锁发动和无效效果的适用条件
function s.actcon(e)
	local tc=e:GetHandler():GetEquipTarget()
	-- 检查装备怪兽是否存在，且其为本次战斗的攻击怪兽或被攻击怪兽
	return tc~=nil and (Duel.GetAttacker()==tc or Duel.GetAttackTarget()==tc)
end
-- 过滤对方场上表侧表示且未被无效的怪兽
function s.disfilter(c)
	-- 检查卡片是否为表侧表示的怪兽，且其效果可以被无效
	return aux.NegateAnyFilter(c) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
-- 攻击宣言时的操作：获取对方场上所有表侧表示怪兽，并将其效果无效化直到伤害步骤结束
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有符合无效化条件的表侧表示怪兽
	local g=Duel.GetMatchingGroup(s.disfilter,tp,0,LOCATION_MZONE,c)
	local tc=g:GetFirst()
	while tc do
		-- 对方场上的表侧表示怪兽的效果无效化。（使怪兽效果无效）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
		-- 对方场上的表侧表示怪兽的效果无效化。（使已发动的效果无效化）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 对方场上的表侧表示怪兽的效果无效化。（使陷阱怪兽的效果无效化）
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
			tc:RegisterEffect(e3)
		end
		tc=g:GetNext()
	end
end
