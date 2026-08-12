--FA－ダーク・ナイト・ランサー
-- 效果：
-- 7星怪兽×3
-- 「重铠装-暗黑骑士枪兵」1回合1次也能在自己场上的5·6阶的超量怪兽上面重叠来超量召唤。
-- ①：这张卡的攻击力上升这张卡的超量素材和装备卡数量×300。
-- ②：1回合1次，以自己墓地1张「超量」卡为对象才能发动。那张卡加入手卡。
-- ③：1回合1次，自己场上的怪兽有装备卡被装备的场合才能发动。把对方场上1只怪兽作为这张卡的超量素材。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含XYZ召唤手续、攻击力上升的永续效果、回收墓地「超量」卡的起动效果，以及装备卡装备时将对方怪兽叠放为超量素材的诱发效果。
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,7,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)  --"在自己场上的5·6阶的超量怪兽上面重叠来超量召唤"
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡的超量素材和装备卡数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以自己墓地1张「超量」卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己场上的怪兽有装备卡被装备的场合才能发动。把对方场上1只怪兽作为这张卡的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_EQUIP)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.eqcon)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
end
-- 过滤自身场上表侧表示的5阶或6阶超量怪兽，用于重叠超量召唤。
function s.ovfilter(c)
	return c:IsFaceup() and (c:IsRank(5) or c:IsRank(6))
end
-- 重叠超量召唤时的操作函数，用于注册并检查每回合1次重叠召唤的玩家标记。
function s.xyzop(e,tp,chk)
	-- 检查当前回合该玩家是否已经使用过此卡名怪兽的重叠超量召唤。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 给玩家注册一个持续到回合结束的标记，表示本回合已进行过此卡的重叠超量召唤。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 计算并返回攻击力上升值，数值为这张卡的超量素材数量与装备卡数量之和乘以300。
function s.atkval(e,c)
	return (c:GetOverlayCount()+c:GetEquipCount())*300
end
-- 过滤墓地中属于「超量」系列且能加入手牌的卡。
function s.thfilter(c)
	return c:IsSetCard(0x73) and c:IsAbleToHand()
end
-- 效果②（回收墓地「超量」卡）的发动条件与对象选择目标过滤。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查自己墓地是否存在至少1张满足条件的「超量」卡。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张满足条件的「超量」卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁信息，表示该效果的处理为将选中的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②（回收墓地「超量」卡）的效果处理函数。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为对象的目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果加入持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤被装备的卡，检查其装备对象是否为自己场上的怪兽。
function s.eqcfilter(c,tp)
	local tc=c:GetEquipTarget()
	return tc and tc:IsControler(tp)
end
-- 效果③的发动条件：检查是否有装备卡装备给自己场上的怪兽。
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.eqcfilter,1,nil,tp)
end
-- 过滤可以作为超量素材的卡片。
function s.ovfilter2(c)
	return c:IsCanOverlay()
end
-- 效果③（将对方怪兽作为超量素材）的发动准备与可行性检查。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只可以作为超量素材的怪兽（排除自身）。
	if chk==0 then return Duel.IsExistingMatchingCard(s.ovfilter2,tp,0,LOCATION_MZONE,1,nil,e:GetHandler()) end
end
-- 效果③（将对方怪兽作为超量素材）的效果处理函数。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取对方场上所有可以作为超量素材的怪兽。
	local g=Duel.GetMatchingGroup(s.ovfilter2,tp,0,LOCATION_MZONE,c)
	if g:GetCount()>0 then
		-- 提示玩家选择要作为超量素材的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		local tg=g:Select(tp,1,1,nil)
		-- 闪烁显示被选为超量素材的对方怪兽。
		Duel.HintSelection(tg)
		local tc=tg:GetFirst()
		if not tc:IsImmuneToEffect(e) then
			local og=tc:GetOverlayGroup()
			if og:GetCount()>0 then
				-- 将该怪兽原本拥有的超量素材因规则送去墓地。
				Duel.SendtoGrave(og,REASON_RULE)
			end
			-- 将选中的对方怪兽重叠作为这张卡的超量素材。
			Duel.Overlay(c,tg)
		end
	end
end
