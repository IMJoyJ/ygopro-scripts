--エクシーズ・アーマー・フォートレス
-- 效果：
-- 5星怪兽×2
-- 「超量铠甲·要塞式」1回合1次也能在自己场上的3·4阶的超量怪兽上面重叠来超量召唤。持有超量素材的这张卡不能作为超量召唤的素材。
-- ①：1回合1次，把这张卡最多2个超量素材取除才能发动。把取除数量的「铠装超量」卡从卡组加入手卡（同名卡最多1张）。
-- ②：有这张卡装备的怪兽用和怪兽的战斗给与对方的战斗伤害变成2倍。
local s,id,o=GetID()
-- 初始化效果，添加超量召唤手续并设置不能被超量召唤的素材
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,5,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)  --"在自己场上的3·4阶的超量怪兽上面重叠来超量召唤"
	c:EnableReviveLimit()
	-- 持有超量素材的这张卡不能作为超量召唤的素材
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.xyzcondition)
	e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 1回合1次，把这张卡最多2个超量素材取除才能发动。把取除数量的「铠装超量」卡从卡组加入手卡（同名卡最多1张）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 有这张卡装备的怪兽用和怪兽的战斗给与对方的战斗伤害变成2倍
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetCondition(s.damcon)
	-- 设置战斗伤害为2倍
	e3:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e3)
end
-- 过滤满足条件的怪兽（3阶或4阶且表侧表示）
function s.ovfilter(c)
	return c:IsFaceup() and (c:IsRank(3) or c:IsRank(4))
end
-- 超量召唤时检查是否已使用过效果，若未使用则注册标识效果
function s.xyzop(e,tp,chk)
	-- 检查是否已使用过效果
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 注册标识效果，使该效果在结束阶段重置
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 判断该卡是否持有超量素材
function s.xyzcondition(e)
	return e:GetHandler():GetOverlayCount()>0
end
-- 过滤满足条件的「铠装超量」卡
function s.thfilter(c)
	return c:IsSetCard(0x4073) and c:IsAbleToHand()
end
-- 支付超量素材的费用，根据卡组中「铠装超量」卡的数量决定取除1或2个素材
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	local ct=0
	-- 获取卡组中所有满足条件的「铠装超量」卡
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetClassCount(Card.GetCode)==0 then return false end
	if g:GetClassCount(Card.GetCode)>=2 then
		ct=e:GetHandler():RemoveOverlayCard(tp,1,2,REASON_COST)
	else
		ct=e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	end
	e:SetLabel(ct)
end
-- 设置效果处理时的操作信息，确定要加入手牌的卡数量
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「铠装超量」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	local ct=e:GetLabel()
	-- 设置连锁操作信息，指定要处理的卡数量和位置
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,ct,tp,LOCATION_DECK)
end
-- 处理效果发动，从卡组选择满足条件的卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足条件的「铠装超量」卡
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 then
		local ct=e:GetLabel()
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从满足条件的卡中选择指定数量且卡名不同的卡
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,ct,ct)
		if sg then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
-- 判断装备的怪兽是否参与了战斗
function s.damcon(e)
	return e:GetHandler():GetEquipTarget():GetBattleTarget()~=nil
end
