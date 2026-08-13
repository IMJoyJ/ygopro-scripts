--No.101 S・H・Ark Knight
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把这张卡2个超量素材取除，以对方场上1只特殊召唤的表侧攻击表示怪兽为对象才能发动。那只怪兽在这张卡下面重叠作为超量素材。
-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
function c48739166.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：允许使用任意2只4星怪兽作为超量素材来进行超量召唤。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 这个卡名的①的效果1回合只能使用1次。①：把这张卡2个超量素材取除，以对方场上1只特殊召唤的表侧攻击表示怪兽为对象才能发动。那只怪兽在这张卡下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48739166,0))  --"吸收素材"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,48739166)
	e1:SetCost(c48739166.cost)
	e1:SetTarget(c48739166.target)
	e1:SetOperation(c48739166.operation)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c48739166.reptg)
	c:RegisterEffect(e2)
end
-- 将这张卡的No.编号登记为101，用于No.相关规则及效果判定。
aux.xyz_number[48739166]=101
-- 发动①效果的代价：进行COST检测（能否取除2个超量素材），并实际取除这张卡的2个超量素材。
function c48739166.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 定义对象怪兽的筛选条件：对方场上表侧攻击表示、通过特殊召唤出场、且可以作为超量素材的怪兽。
function c48739166.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsCanOverlay()
end
-- ①效果的目标处理：以对方场上1只满足条件的特殊召唤的表侧攻击表示怪兽为对象发动。
function c48739166.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c48739166.filter(chkc) end
	-- 在发动时点检查对方怪兽区域是否存在至少1只满足条件的怪兽，作为效果能否发动的条件。
	if chk==0 then return Duel.IsExistingTarget(c48739166.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家显示选择提示消息：请选择要作为超量素材的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 让发动玩家选择对方场上1只符合条件的怪兽作为效果对象，并将该卡登记为当前连锁的对象。
	Duel.SelectTarget(tp,c48739166.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：把对象怪兽重叠到这张卡下面作为超量素材；若对象怪兽持有超量素材，先将那些素材送去墓地。
function c48739166.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取这个效果处理时需要处理的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and tc:IsType(TYPE_MONSTER) and tc:IsCanOverlay() then
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 将对象怪兽原有的超量素材按规则送去墓地（因为这些素材不能随怪兽一起叠放）。
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将对象怪兽作为超量素材，叠放在这张卡下面。
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
-- ②代替破坏效果的判定：这张卡因战斗或效果要被破坏时，检测是否可以取除1个超量素材来代替破坏。
function c48739166.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 询问控制者是否发动代替破坏效果；选择“是”则进入移除素材并代替破坏的处理流程。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		return true
	else return false end
end
