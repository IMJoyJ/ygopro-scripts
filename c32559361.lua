--CNo.9 天蓋妖星カオス・ダイソン・スフィア
-- 效果：
-- 10星怪兽×3
-- ①：1回合1次，自己主要阶段才能发动。给与对方这张卡的超量素材数量×300伤害。
-- ②：这张卡和对方怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽在这张卡下面重叠作为超量素材。
-- ③：这张卡有「No.9 天盖星 戴森球」在作为超量素材的场合，得到以下效果。
-- ●1回合1次，把这张卡的超量素材任意数量取除才能发动。给与对方取除数量×800伤害。
function c32559361.initial_effect(c)
	-- 为这张卡添加超量召唤手续：可用任意10星怪兽3只叠放进行超量召唤。
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
-- 将该卡登记为No.9，用于No.卡相关规则判定。
aux.xyz_number[32559361]=9
-- ②效果的发动条件判定：本卡必须为超量怪兽，且存在战斗对象，该对象可作为超量素材，满足时允许发动。
function c32559361.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if chk==0 then return tc and c:IsType(TYPE_XYZ) and tc:IsCanOverlay() end
end
-- ②效果处理：若本卡与战斗对象均关联此次战斗且对象为怪兽、不免疫此效果、可作为超量素材，则将战斗对象叠放在本卡下方；若对象自身有超量素材则先将那些素材送去墓地。
function c32559361.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToBattle() and tc:IsType(TYPE_MONSTER) and not tc:IsImmuneToEffect(e) and tc:IsCanOverlay() then
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 将战斗对象原本持有的超量素材按规则理由全部送去墓地。
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将战斗对象作为超量素材叠放在本卡下方。
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
-- ①效果的发动条件与对象设定：本卡有超量素材才可发动；以对方为对象，并按当前素材数×300设置伤害信息。
function c32559361.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetOverlayCount()>0 end
	local ct=e:GetHandler():GetOverlayCount()
	-- 将对方玩家设为该效果的对象（伤害对象）。
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁操作信息，声明伤害分类、伤害对象及预计伤害数值（当前素材数×300）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
end
-- ①效果处理：根据记录的对象玩家和当前超量素材数量，给予对象玩家素材数×300的伤害。
function c32559361.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取该连锁中记录的对象玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=e:GetHandler():GetOverlayCount()
	-- 以效果原因给予对象玩家ct×300伤害。
	Duel.Damage(p,ct*300,REASON_EFFECT)
end
-- ③效果的条件判定：本卡的超量素材中存在「No.9 天盖星 戴森球」（卡号1992816）时才可发动。
function c32559361.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,1992816)
end
-- ③效果的发动代价：从本卡取除任意数量（至少1张）超量素材作为代价，并将取除数量保存到效果的Label中供后续使用。
function c32559361.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	local ct=e:GetHandler():RemoveOverlayCard(tp,1,99,REASON_COST)
	e:SetLabel(ct)
end
-- ③效果发动时：以对方为对象，并根据取除数量设置伤害信息。
function c32559361.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=e:GetLabel()
	-- 将对方玩家设为该效果的对象（伤害对象）。
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁操作信息，声明伤害分类、伤害对象及预计伤害数值（取除数量×800）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*800)
end
-- ③效果处理：根据记录的对象玩家和取除数量，给予对方取除数量×800的伤害。
function c32559361.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取该连锁中记录的对象玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=e:GetLabel()
	-- 以效果原因给予对象玩家ct×800伤害。
	Duel.Damage(p,ct*800,REASON_EFFECT)
end
