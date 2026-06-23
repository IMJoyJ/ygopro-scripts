--CNo.9 天蓋妖星カオス・ダイソン・スフィア
-- 效果：
-- 10星怪兽×3
-- ①：1回合1次，自己主要阶段才能发动。给与对方这张卡的超量素材数量×300伤害。
-- ②：这张卡和对方怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽在这张卡下面重叠作为超量素材。
-- ③：这张卡有「No.9 天盖星 戴森球」在作为超量素材的场合，得到以下效果。
-- ●1回合1次，把这张卡的超量素材任意数量取除才能发动。给与对方取除数量×800伤害。
function c32559361.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为10的怪兽3只作为超量素材
	aux.AddXyzProcedure(c,nil,10,3)
	c:EnableReviveLimit()
	-- ②：这张卡和对方怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽在这张卡下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32559361,0))  --"吸收素材"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetTarget(c32559361.target)
	e1:SetOperation(c32559361.operation)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段才能发动。给与对方这张卡的超量素材数量×300伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32559361,1))  --"给与对方超量素材数量×300的伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c32559361.damtg)
	e2:SetOperation(c32559361.damop)
	c:RegisterEffect(e2)
	-- ③：这张卡有「No.9 天盖星 戴森球」在作为超量素材的场合，得到以下效果。●1回合1次，把这张卡的超量素材任意数量取除才能发动。给与对方取除数量×800伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32559361,2))  --"超量素材取除，给与对方×800的伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c32559361.damcon)
	e3:SetCost(c32559361.damcost)
	e3:SetTarget(c32559361.damtg2)
	e3:SetOperation(c32559361.damop2)
	c:RegisterEffect(e3)
end
-- 设置该卡为No.9系列的XYZ怪兽
aux.xyz_number[32559361]=9
-- 判断是否可以将战斗中的对方怪兽作为超量素材
function c32559361.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if chk==0 then return tc and c:IsType(TYPE_XYZ) and tc:IsCanOverlay() end
end
-- 将战斗中的对方怪兽叠放至自身作为超量素材，并将该怪兽原本的叠放卡送去墓地
function c32559361.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToBattle() and tc:IsType(TYPE_MONSTER) and not tc:IsImmuneToEffect(e) and tc:IsCanOverlay() then
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 将目标怪兽原本的叠放卡送去墓地
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将目标怪兽叠放至自身作为超量素材
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
-- 判断是否拥有超量素材以发动效果
function c32559361.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetOverlayCount()>0 end
	local ct=e:GetHandler():GetOverlayCount()
	-- 设置连锁处理的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁操作信息为对对方造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
end
-- 对对方造成伤害
function c32559361.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=e:GetHandler():GetOverlayCount()
	-- 对目标玩家造成伤害
	Duel.Damage(p,ct*300,REASON_EFFECT)
end
-- 判断是否拥有「No.9 天盖星 戴森球」作为超量素材
function c32559361.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,1992816)
end
-- 支付将自身超量素材取除的代价
function c32559361.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	local ct=e:GetHandler():RemoveOverlayCard(tp,1,99,REASON_COST)
	e:SetLabel(ct)
end
-- 判断是否可以发动效果
function c32559361.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=e:GetLabel()
	-- 设置连锁处理的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁操作信息为对对方造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*800)
end
-- 对对方造成伤害
function c32559361.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=e:GetLabel()
	-- 对目标玩家造成伤害
	Duel.Damage(p,ct*800,REASON_EFFECT)
end
