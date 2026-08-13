--封印の魔導士スプーン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：可以把这张卡从手卡丢弃，从以下效果选择1个发动。
-- ●从卡组把「封印之魔导士 斯彭」以外的1只「大贤者」怪兽加入手卡。
-- ●对方场上1只怪兽的攻击力直到回合结束时变成一半。
-- ②：把墓地的这张卡除外，以自己场上1只表侧表示怪兽为对象才能发动。从自己的额外卡组·墓地把1只「大贤者」怪兽当作装备魔法卡使用给作为对象的怪兽装备。
local s,id,o=GetID()
-- 创建并注册两个效果：①效果为手牌起动效果，丢弃自身发动，可选择检索「大贤者」怪兽或降低对方怪兽攻击力；②效果为墓地起动效果，除外自身，选择自己场上表侧怪兽并从额外卡组·墓地选择「大贤者」怪兽装备。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：可以把这张卡从手卡丢弃，从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"丢弃发动效果"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只表侧表示怪兽为对象才能发动。从自己的额外卡组·墓地把1只「大贤者」怪兽当作装备魔法卡使用给作为对象的怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"装备"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动代价为把墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
-- ①效果的代价处理：chk==0时检查这张卡能否从手卡丢弃；chk==1时把这张卡从手卡丢弃并送去墓地作为发动代价。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将这张卡作为丢弃代价从手卡送去墓地。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 检索用过滤条件：卡名不是这张卡、是怪兽且属于「大贤者」系列，并且可以被加入手卡。
function s.filter(c)
	return not c:IsCode(id) and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x150)
		and c:IsAbleToHand()
end
-- ①效果发动时的分支选择：分别检查能否检索以及对方场上是否有表侧怪兽可减半攻击力；若只有一者可用则自动选择，若两者可用则让玩家选择，并根据选择将效果标记为检索或减半攻击力，同时设置对应的效果类别。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方卡组是否存在1张满足s.filter的「大贤者」怪兽，以决定检索分支是否可选。
	local b1=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
	-- 检查对方场上是否存在表侧表示怪兽，以决定攻击力减半分支是否可选。
	local b2=Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and not b2 then
		-- 向对方玩家提示：本效果选择了检索分支。
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))  --"检索"
		op=1
	end
	if b2 and not b1 then
		-- 向对方玩家提示：本效果选择了攻击力变成一半分支。
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,3))  --"攻击力变成一半"
		op=2
	end
	if b1 and b2 then
		-- 当两个分支均可选时，通过选项框让发动玩家选择要执行的分支（1为检索，2为攻击力减半）。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"检索"
			{b2,aux.Stringid(id,3),2})  --"攻击力变成一半"
	end
	if op==1 then
		e:SetLabel(1)
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		-- 登记连锁的操作信息：本效果预定从卡组把1张卡加入手卡（用于时点与相关效果判定）。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		e:SetLabel(2)
		e:SetCategory(CATEGORY_ATKCHANGE)
	end
end
-- ①效果处理：若标签为1，则从卡组选1张符合条件的「大贤者」怪兽加入手卡并向对方展示；若标签为2，则选择对方场上1只表侧表示怪兽，使其攻击力直到回合结束时变为当前攻击力的一半（向上取整）。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 显示选择提示：请选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从己方卡组选择1张满足s.filter的「大贤者」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			-- 将选中的「大贤者」怪兽以效果原因加入其持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示被检索加入手卡的卡片，以便确认检索内容。
			Duel.ConfirmCards(1-tp,g)
		end
	elseif e:GetLabel()==2 then
		-- 显示选择提示：请选择表侧表示的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 效果处理时选择对方场上1只表侧表示怪兽作为攻击力减半的适用对象（不取对象）。
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 手动显示所选怪兽被选中的动画，并记录其为当前效果处理的相关卡片。
			Duel.HintSelection(g)
			-- ●对方场上1只怪兽的攻击力直到回合结束时变成一半。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(math.ceil(tc:GetAttack()/2))
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
-- 装备卡选择过滤条件：该卡属于「大贤者」系列、是怪兽、在魔法陷阱区没有同名卡冲突且不是被禁止作为装备卡的卡。
function s.eqfilter(c,tp)
	return c:IsSetCard(0x150) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden()
end
-- ②效果的发动条件与取对象：确认魔法陷阱区有空位、自己场上有表侧表示怪兽、墓地或额外卡组存在可装备的「大贤者」怪兽；然后在发动时选择自己场上1只表侧表示怪兽作为装备对象。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- ②效果发动条件之一：自己魔法陷阱区必须存在空位，否则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- ②效果发动条件之一：自己场上必须存在表侧表示怪兽，可作为装备对象。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		-- ②效果发动条件之一：自己墓地或额外卡组必须存在满足条件的「大贤者」怪兽（且排除除外状态的这张卡自身），否则不能发动。
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,e:GetHandler(),tp) end
	-- 显示选择提示：请选择要装备的卡（这里是选择被装备的对象怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择自己场上1只表侧表示怪兽作为此效果的装备对象，并登记为连锁对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理：确认对象仍合法且魔法陷阱区有空位后，从墓地·额外卡组选择1只「大贤者」怪兽（排除受王家长眠之谷影响的卡），将其作为装备魔法卡装备给对象怪兽，并为装备卡附加仅能装备给该对象的限制。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判定对象怪兽是否仍与效果关联、是否仍表侧表示在主要怪兽区，以及魔法陷阱区是否仍有空位，任一不满足则效果处理不继续。
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 显示选择提示：请选择要装备的卡（这里选择作为装备卡的「大贤者」怪兽）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 让玩家从自己墓地·额外卡组选择1张满足s.eqfilter且不受王家长眠之谷影响的「大贤者」怪兽作为装备卡。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,tp)
		local ec=g:GetFirst()
		if ec then
			-- 将选中的「大贤者」怪兽作为装备魔法卡装备给对象怪兽；若装备失败（如对象已不合适）则终止处理。
			if not Duel.Equip(tp,ec,tc) then return end
			-- 从自己的额外卡组·墓地把1只「大贤者」怪兽当作装备魔法卡使用给作为对象的怪兽装备。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetLabelObject(tc)
			e1:SetValue(s.eqlimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			ec:RegisterEffect(e1)
		end
	end
end
-- 装备限制判定：这张装备卡只能装备给发动时选择的对象怪兽（e:GetLabelObject()），防止装备到其他怪兽身上。
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
