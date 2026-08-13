--SNo.38 タイタニック・ギャラクシー
-- 效果：
-- 光属性9星怪兽×3
-- 这张卡也能在自己场上的「No.38 希望魁龙 银河巨神」上面重叠来超量召唤。
-- ①：这张卡的攻击力上升这张卡的超量素材数量×200。
-- ②：1回合1次，以对方场上最多2张魔法·陷阱卡为对象才能发动（不能对应这个发动把作为对象的卡的效果发动）。那些卡作为这张卡的超量素材。
-- ③：把这张卡1个超量素材取除才能发动。这个回合，这张卡的原本攻击力变成1500，可以直接攻击。
local s,id,o=GetID()
-- initial_effect函数：为闪光No.38注册召唤手续（光属性9星怪兽×3，或叠放在No.38 希望魁龙 银河巨神上）以及①攻击力上升、②把对方魔陷叠放为素材、③拔素材直接攻击三个效果。
function s.initial_effect(c)
	-- 将卡号63767246（No.38 希望魁龙 银河巨神）登记为这张卡上记载的另一张卡名，用于支持本卡重叠在其上进行超量召唤的规则处理。
	aux.AddCodeList(c,63767246)
	aux.AddXyzProcedure(c,s.mfilter,9,3,s.ovfilter,aux.Stringid(id,0))  --"是否在「No.38 希望魁龙 银河巨神」上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- 对应①：这张卡的攻击力上升这张卡的超量素材数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"攻击力上升"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- 对应②：1回合1次，以对方场上最多2张魔法·陷阱卡为对象才能发动（不能对应这个发动把作为对象的卡的效果发动）。那些卡作为这张卡的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"作为超量素材"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	-- 对应③：把这张卡1个超量素材取除才能发动。这个回合，这张卡的原本攻击力变成1500，可以直接攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))  --"直接攻击"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(s.datcost)
	e3:SetTarget(s.dattg)
	e3:SetOperation(s.datop)
	c:RegisterEffect(e3)
end
-- 将这张卡在No.相关规则中的编号标记为38，使其作为闪光No.38处理。
aux.xyz_number[id]=38
-- 超量召唤素材条件：素材怪兽必须是光属性（等级9由AddXyzProcedure的lv参数限制）。
function s.mfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 特殊叠放条件：可以叠放在表侧表示的卡号63767246（No.38 希望魁龙 银河巨神）上进行超量召唤。
function s.ovfilter(c)
	return c:IsFaceup() and c:IsCode(63767246)
end
-- ①的攻击力上升数值计算：这张卡的超量素材数量×200。
function s.atkval(e,c)
	return c:GetOverlayCount()*200
end
-- ②可选择对象过滤：对方场上可以作为超量素材的魔法·陷阱卡；若该卡同时是怪兽化魔陷，则还要求控制权可以变更。
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsCanOverlay()
		and (c:IsControlerCanBeChanged() or not c:IsType(TYPE_MONSTER))
end
-- ②的发动条件和发动时处理：检查能否发动后，选择对方场上最多2张符合条件的魔陷为对象，设置不能对应这个发动把对象卡效果发动的连锁限制，并注册连锁结束时清理对象组的辅助效果。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.filter(chkc) and chkc~=c end
	-- 发动条件检查：这张卡是超量怪兽，且对方场上有至少1张满足s.filter的卡可以选择。
	if chk==0 then return c:IsType(TYPE_XYZ) and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD,1,c) end
	-- 向操作者显示“请选择要作为超量素材的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 从对方场上选择1~2张满足s.filter的卡作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD,1,2,c)
	g:KeepAlive()
	-- 设置连锁限制：使已被选为对象的卡不能在本次连锁中发动效果。
	Duel.SetChainLimit(s.limit(g))
	-- 实现②的“那些卡作为这张卡的超量素材”（含被取对象卡原素材的处理）以及③的发动条件和代价，对应原文：②：1回合1次，以对方场上最多2张魔法·陷阱卡为对象才能发动（不能对应这个发动把作为对象的卡的效果发动）。那些卡作为这张卡的超量素材。③：把这张卡1个超量素材取除才能发动。这个回合，这张卡的原本攻击力变成1500，可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(RESET_CHAIN)
	e1:SetCountLimit(1)
	e1:SetLabelObject(g)
	e1:SetOperation(s.retop)
	e1:SetReset(RESET_CHAIN)
	-- 将用于连锁结束时自动清理对象组（DeleteGroup）的辅助连续效果注册到场上，防止对象组引用残留。
	Duel.RegisterEffect(e1,tp)
end
-- 连锁限制函数：如果打算连锁的效果的持有者是对象组中的卡，则禁止其发动，实现“不能对应这个发动把作为对象的卡的效果发动”。
function s.limit(g)
	return  function (e,lp,tp)
				return not g:IsContains(e:GetHandler())
			end
end
-- 连锁结束时清除保存的对象组，释放之前KeepAlive保护的对象组引用。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():DeleteGroup()
end
-- 过滤出仍与当前效果关联且不免疫此效果的卡，保证只有能被正常处理的卡才会被叠放。
function s.lfilter(c,e)
	return not c:IsImmuneToEffect(e)
end
-- ②效果处理：将仍关联且不免疫的选取对象，在这张卡仍在场上时全部叠放在其下方作为超量素材。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁中仍与本效果关联的对象卡，并过滤掉对此效果免疫的卡，得到实际可叠放的对象组。
	local sg=Duel.GetTargetsRelateToChain():Filter(s.lfilter,c,e)
	if sg:GetCount()>0 and c:IsRelateToEffect(e) then
		-- 遍历对象组中的每一张卡，依次处理其原有超量素材。
		for tc in aux.Next(sg) do
			local og=tc:GetOverlayGroup()
			if og:GetCount()>0 then
				-- 若被取对象的卡上面叠放有超量素材，因这些素材不能随卡一起转移，将它们按规则送去墓地。
				Duel.SendtoGrave(og,REASON_RULE)
			end
		end
		-- 将处理后的对象卡全部叠放在这张卡下面，成为这张卡的超量素材。
		Duel.Overlay(c,sg)
	end
end
-- ③的发动条件检查：本卡原本攻击力不是1500，或者尚未获得直接攻击效果时才允许发动，避免空发。
function s.dattg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetBaseAttack()~=1500 or not c:IsHasEffect(EFFECT_DIRECT_ATTACK) end
end
-- ③的发动代价：从这张卡上取除1个超量素材。
function s.datcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ③的效果处理：把本卡原本攻击力改成1500，并赋予直接攻击能力，持续到回合结束。
function s.datop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 对应③：这个回合，这张卡的原本攻击力变成1500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(1500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 对应③：这张卡可以直接攻击。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DIRECT_ATTACK)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
