--エクシーズ・アーマー・フォートレス
-- 效果：
-- 5星怪兽×2
-- 「超量铠甲·要塞式」1回合1次也能在自己场上的3·4阶的超量怪兽上面重叠来超量召唤。持有超量素材的这张卡不能作为超量召唤的素材。
-- ①：1回合1次，把这张卡最多2个超量素材取除才能发动。把取除数量的「铠装超量」卡从卡组加入手卡（同名卡最多1张）。
-- ②：有这张卡装备的怪兽用和怪兽的战斗给与对方的战斗伤害变成2倍。
local s,id,o=GetID()
-- 为这张卡注册三类效果：超量召唤手续（包含1回合1次在自己场上的3·4阶超量怪兽上重叠来超量召唤的追加方式）、持有超量素材时不能作为超量召唤素材的限制效果、①的检索「铠装超量」效果以及②的装备怪兽战斗伤害翻倍效果。
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,5,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)  --"在自己场上的3·4阶的超量怪兽上面重叠来超量召唤"
	c:EnableReviveLimit()
	-- 持有超量素材的这张卡不能作为超量召唤的素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.xyzcondition)
	e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：1回合1次，把这张卡最多2个超量素材取除才能发动。把取除数量的「铠装超量」卡从卡组加入手卡（同名卡最多1张）。
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
	-- ②：有这张卡装备的怪兽用和怪兽的战斗给与对方的战斗伤害变成2倍。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetCondition(s.damcon)
	-- 将②效果的战斗伤害变更值设为：装备怪兽向对方造成的战斗伤害变为2倍（DOUBLE_DAMAGE）。
	e3:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e3)
end
-- 超量召唤的素材筛选条件：必须是表侧表示且阶级为3或4的超量怪兽，用于本卡在自己场上的3·4阶超量怪兽上面重叠来超量召唤。
function s.ovfilter(c)
	return c:IsFaceup() and (c:IsRank(3) or c:IsRank(4))
end
-- 超量召唤手续的追加操作：若为可发动性检查则返回本回合是否尚未使用过该召唤方式；通过后注册一个到结束阶段重置的誓约标志，限制1回合只能1次以这种方式超量召唤。
function s.xyzop(e,tp,chk)
	-- 可发动性检查：玩家tp本回合尚未拥有id标志，即尚未用过“在自己场上的3·4阶超量怪兽上面重叠来超量召唤”这一方式。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 注册标志效果：给tp记录id标志，在结束阶段重置并带有誓约属性，用来保证这个召唤方式一回合只能使用一次。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 限制条件：这张卡持有超量素材时，不能作为超量召唤的素材。
function s.xyzcondition(e)
	return e:GetHandler():GetOverlayCount()>0
end
-- 检索过滤条件：卡名属于「铠装超量」系列，并且能够加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x4073) and c:IsAbleToHand()
end
-- 代价处理：若卡组中存在符合条件的「铠装超量」卡，则根据其卡名种类数决定取除素材数量——卡名种类≥2时取除2个，否则取除1个（即最多2个），并将实际取除数量保存到标签供后续使用。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	local ct=0
	-- 获取卡组中所有满足「铠装超量」字段且能加入手卡的卡，用于计算可检索的不同卡名数。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetClassCount(Card.GetCode)==0 then return false end
	if g:GetClassCount(Card.GetCode)>=2 then
		ct=e:GetHandler():RemoveOverlayCard(tp,1,2,REASON_COST)
	else
		ct=e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	end
	e:SetLabel(ct)
end
-- 发动目标阶段：检查卡组存在至少1张满足条件的「铠装超量」卡；然后从标签读取取除素材数量，并设置操作信息表示本次效果将把对应数量卡片加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标阶段的可发动性检查：卡组中是否存在至少1张满足检索条件的「铠装超量」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	local ct=e:GetLabel()
	-- 设置操作信息：将本次效果处理的操作标记为从卡组把ct张卡加入手卡（CATEGORY_TOHAND），供后续时点/效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,ct,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择ct张卡名互不相同的「铠装超量」卡，加入手卡并展示给对方确认；若没有可选卡则不做处理。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时获取卡组中所有满足条件的「铠装超量」卡。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 then
		local ct=e:GetLabel()
		-- 给玩家显示选择提示：‘请选择要加入手牌的卡’。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组中选出ct张卡名各不相同的「铠装超量」卡（同名最多1张）。
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,ct,ct)
		if sg then
			-- 将选出的「铠装超量」卡加入其持有者的手卡，加入原因为效果。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 把加入手卡的卡展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
-- ②效果的条件：这张卡作为装备卡装备的怪兽进行了与怪兽的战斗（存在战斗对象怪兽）时，该战斗伤害才能翻倍。
function s.damcon(e)
	return e:GetHandler():GetEquipTarget():GetBattleTarget()~=nil
end
