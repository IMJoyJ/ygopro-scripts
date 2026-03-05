--SNo.38 タイタニック・ギャラクシー
-- 效果：
-- 光属性9星怪兽×3
-- 这张卡也能在自己场上的「No.38 希望魁龙 银河巨神」上面重叠来超量召唤。
-- ①：这张卡的攻击力上升这张卡的超量素材数量×200。
-- ②：1回合1次，以对方场上最多2张魔法·陷阱卡为对象才能发动（不能对应这个发动把作为对象的卡的效果发动）。那些卡作为这张卡的超量素材。
-- ③：把这张卡1个超量素材取除才能发动。这个回合，这张卡的原本攻击力变成1500，可以直接攻击。
local s,id,o=GetID()
-- 初始化效果函数，注册超量召唤条件、攻击力上升效果、超量素材选择效果和直接攻击效果
function s.initial_effect(c)
	-- 记录该卡与「No.38 希望魁龙 银河巨神」的关联
	aux.AddCodeList(c,63767246)
	aux.AddXyzProcedure(c,s.mfilter,9,3,s.ovfilter,aux.Stringid(id,0))  --"是否在「No.38 希望魁龙 银河巨神」上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡的超量素材数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"攻击力上升"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以对方场上最多2张魔法·陷阱卡为对象才能发动（不能对应这个发动把作为对象的卡的效果发动）。那些卡作为这张卡的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"作为超量素材"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	-- ③：把这张卡1个超量素材取除才能发动。这个回合，这张卡的原本攻击力变成1500，可以直接攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))  --"直接攻击"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(s.datcost)
	e3:SetTarget(s.dattg)
	e3:SetOperation(s.datop)
	c:RegisterEffect(e3)
end
-- 设置该卡为编号38的超量怪兽
aux.xyz_number[id]=38
-- 判断怪兽是否为光属性
function s.mfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 判断怪兽是否为表侧表示且为「No.38 希望魁龙 银河巨神」
function s.ovfilter(c)
	return c:IsFaceup() and c:IsCode(63767246)
end
-- 计算攻击力上升值，为超量素材数量乘以200
function s.atkval(e,c)
	return c:GetOverlayCount()*200
end
-- 筛选可作为超量素材的魔法·陷阱卡
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsCanOverlay()
		and (c:IsControlerCanBeChanged() or not c:IsType(TYPE_MONSTER))
end
-- 处理超量素材选择效果的发动条件和选择过程
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.filter(chkc) and chkc~=c end
	-- 判断是否满足发动条件：该卡为超量怪兽且对方场上存在可作为超量素材的魔法·陷阱卡
	if chk==0 then return c:IsType(TYPE_XYZ) and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD,1,c) end
	-- 提示玩家选择作为超量素材的魔法·陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择最多2张对方场上的魔法·陷阱卡作为超量素材
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD,1,2,c)
	g:KeepAlive()
	-- 设置连锁限制，防止选择的卡发动效果
	Duel.SetChainLimit(s.limit(g))
	-- 注册连锁限制效果，防止选择的卡发动效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(RESET_CHAIN)
	e1:SetCountLimit(1)
	e1:SetLabelObject(g)
	e1:SetOperation(s.retop)
	e1:SetReset(RESET_CHAIN)
	-- 注册连锁限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 定义连锁限制函数，防止选择的卡发动效果
function s.limit(g)
	return  function (e,lp,tp)
				return not g:IsContains(e:GetHandler())
			end
end
-- 处理连锁结束后清除选择的卡组
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():DeleteGroup()
end
-- 判断卡是否对效果免疫
function s.lfilter(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 处理超量素材选择效果的执行过程，将选中的卡叠放至自身
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取与连锁相关的选中卡组并过滤
	local sg=Duel.GetTargetsRelateToChain():Filter(s.lfilter,c,e)
	if sg:GetCount()>0 and c:IsRelateToEffect(e) then
		-- 遍历选中卡组中的每张卡
		for tc in aux.Next(sg) do
			local og=tc:GetOverlayGroup()
			if og:GetCount()>0 then
				-- 将选中卡的叠放卡送去墓地
				Duel.SendtoGrave(og,REASON_RULE)
			end
		end
		-- 将选中的卡叠放至自身
		Duel.Overlay(c,sg)
	end
end
-- 判断是否满足直接攻击效果的发动条件
function s.dattg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetBaseAttack()~=1500 or not c:IsHasEffect(EFFECT_DIRECT_ATTACK) end
end
-- 判断是否满足支付1个超量素材的费用
function s.datcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 处理直接攻击效果的发动和执行
function s.datop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 设置该卡的原本攻击力为1500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(1500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 设置该卡获得直接攻击效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DIRECT_ATTACK)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
