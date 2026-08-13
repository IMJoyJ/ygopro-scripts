--武神帝－カグツチ
-- 效果：
-- 兽战士族4星怪兽×2
-- 这张卡超量召唤成功时，从自己卡组上面把5张卡送去墓地。这张卡的攻击力上升这个效果送去墓地的名字带有「武神」的卡数量×100的数值。此外，自己场上的名字带有「武神」的兽战士族怪兽被战斗或者卡的效果破坏的场合，可以作为那1只破坏的怪兽的代替而把这张卡1个超量素材取除。「武神帝-迦具土」在自己场上只能有1只表侧表示存在。
function c1855932.initial_effect(c)
	c:SetUniqueOnField(1,0,1855932)
	-- 为「武神帝-迦具土」添加超量召唤手续：以兽战士族4星怪兽2只为素材进行超量召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_BEASTWARRIOR),4,2)
	c:EnableReviveLimit()
	-- 这张卡超量召唤成功时，从自己卡组上面把5张卡送去墓地。这张卡的攻击力上升这个效果送去墓地的名字带有「武神」的卡数量×100的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1855932,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c1855932.discon)
	e1:SetTarget(c1855932.distg)
	e1:SetOperation(c1855932.disop)
	c:RegisterEffect(e1)
	-- 此外，自己场上的名字带有「武神」的兽战士族怪兽被战斗或者卡的效果破坏的场合，可以作为那1只破坏的怪兽的代替而把这张卡1个超量素材取除。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c1855932.reptg)
	e2:SetValue(c1855932.repval)
	c:RegisterEffect(e2)
end
-- 效果发动条件判定：此卡必须是通过超量召唤方式特殊召唤成功时才触发该效果。
function c1855932.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果发动时的目标判定：该效果为必发且不取对象，因此在chk==0时直接返回true，并设置本次操作信息为将卡组顶5张卡送去墓地。
function c1855932.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，声明本效果涉及将玩家tp的卡组最上方5张卡送去墓地（类别为卡组送墓），供其他卡牌效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,5)
end
-- 实际效果处理：将玩家tp卡组顶端5张卡以效果原因送去墓地；随后若此卡仍表侧表示且与效果关联，则统计这些送往墓地的卡中带有「武神」字段的卡的数量，若大于0则给此卡赋予攻击力上升该数量×100的数值。
function c1855932.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将玩家tp卡组顶端的5张卡送去墓地。
	Duel.DiscardDeck(tp,5,REASON_EFFECT)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 从上次实际被操作的卡组（即被DiscardDeck送去墓地的卡）中筛选出卡名带有「武神」字段的卡，并统计其数量。
		local ct=Duel.GetOperatedGroup():FilterCount(Card.IsSetCard,nil,0x88)
		if ct>0 then
			-- 这张卡的攻击力上升这个效果送去墓地的名字带有「武神」的卡数量×100的数值。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(ct*100)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
-- 代替破坏的筛选条件：要保护的怪兽必须是表侧表示、由玩家tp控制、位于主要怪兽区、卡名含有「武神」字段且种族为兽战士族。
function c1855932.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x88) and c:IsRace(RACE_BEASTWARRIOR)
end
-- 代替破坏效果的发动判定与处理：若场上存在符合条件的将被破坏的怪兽，且此卡能去除1个超量素材且玩家选择发动，则实际去除1个超量素材，并从这些将被破坏的怪兽中选定1只作为代替破坏的对象（若只有1只则直接选定；若多只则提示玩家选择），保存到效果标签中，返回true表示本次破坏由这张武神帝代替。
function c1855932.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c1855932.repfilter,1,nil,tp) end
	-- 检查此卡能否以效果原因去除1个超量素材，并询问玩家是否发动代替破坏效果，两个条件同时满足才继续。
	if e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) and Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		local g=eg:Filter(c1855932.repfilter,nil,tp)
		if g:GetCount()==1 then
			e:SetLabelObject(g:GetFirst())
		else
			-- 当存在多个可代替破坏的怪兽时，弹出选择提示，让玩家选择要代替破坏的1只怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
			local cg=g:Select(tp,1,1,nil)
			e:SetLabelObject(cg:GetFirst())
		end
		return true
	else return false end
end
-- 代替破坏的判定依据：被破坏的怪兽c必须等于效果标签中保存的怪兽（即之前选定代替破坏的卡），才由这张武神帝代替其破坏。
function c1855932.repval(e,c)
	return c==e:GetLabelObject()
end
