--魔神火焔砲
-- 效果：
-- ①：原本卡名包含「艾克佐迪亚」的场上1只10星以上的怪兽得到以下效果。
-- ●把基本分支付一半才能发动。双方的魔法与陷阱区域的卡全部破坏。那之后，从手卡·卡组把5只「被封印」怪兽各当作攻击力上升2000的装备魔法卡使用给这张卡装备。这个效果的发动后，直到回合结束时自己不能把这张卡以外的卡的效果发动。
-- ●这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
local s,id,o=GetID()
-- 注册主效果，设置为自由时点的发动效果，用于触发后续处理
function s.initial_effect(c)
	-- ●把基本分支付一半才能发动。双方的魔法与陷阱区域的卡全部破坏。那之后，从手卡·卡组把5只「被封印」怪兽各当作攻击力上升2000的装备魔法卡使用给这张卡装备。这个效果的发动后，直到回合结束时自己不能把这张卡以外的卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，筛选场上表侧表示、原本卡名为艾克佐迪亚、等级10以上且未被该效果影响的怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsOriginalSetCard(0xde) and c:IsLevelAbove(10) and c:GetFlagEffect(id)==0
end
-- 目标函数，检查场上是否存在满足条件的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 发动函数，选择符合条件的怪兽并为其注册效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local c=e:GetHandler()
	local tc=g:GetFirst()
	if tc then
		-- 显示选中的怪兽被选为对象的动画效果
		Duel.HintSelection(g)
		-- 为选中的怪兽注册起动效果，用于破坏魔法陷阱并装备被封印怪兽
		local e1=Effect.CreateEffect(tc)
		e1:SetDescription(aux.Stringid(id,1))  --"破坏场上的魔法·陷阱卡并装备「被封印」怪兽"
		e1:SetCategory(CATEGORY_DESTROY)
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCost(s.descost)
		e1:SetTarget(s.destg)
		e1:SetOperation(s.desop)
		tc:RegisterEffect(e1)
		-- 为选中的怪兽注册贯穿伤害效果
		local e2=Effect.CreateEffect(tc)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_PIERCE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if not tc:IsType(TYPE_EFFECT) then
			-- 若选中的怪兽不是效果怪兽，则为其添加效果怪兽类型
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_ADD_TYPE)
			e3:SetValue(TYPE_EFFECT)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))  --"「魔神火焰炮」效果适用中"
	end
end
-- 限制效果发动的函数，用于判断是否能发动其他效果
function s.aclimit(e,re,tp)
	local c=re:GetHandler()
	return e:GetLabel()~=c:GetFieldID()
end
-- 支付一半LP作为发动成本
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付一半当前LP
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 过滤函数，筛选魔法陷阱区域的卡
function s.desfilter(c)
	return c:GetSequence()<5
end
-- 过滤函数，筛选手卡或卡组中可装备的被封印怪兽
function s.eqfilter(c,tp)
	return c:IsSetCard(0x40) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden()
end
-- 目标函数，检查是否满足破坏魔法陷阱和装备被封印怪兽的条件
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否存在魔法陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil)
		-- 检查手卡或卡组中是否存在5只被封印怪兽
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK+LOCATION_HAND,0,5,nil,tp) end
	-- 获取场上所有魔法陷阱卡
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	-- 设置操作信息，记录将要破坏的魔法陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 破坏魔法陷阱卡并装备被封印怪兽的处理函数
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上所有魔法陷阱卡
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	-- 破坏魔法陷阱卡并检查是否已无魔法陷阱卡
	if Duel.Destroy(sg,REASON_EFFECT)~=0 and Duel.GetMatchingGroupCount(s.desfilter,tp,LOCATION_SZONE,0,nil)==0 then
		-- 从手卡或卡组中选择5只被封印怪兽
		local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK+LOCATION_HAND,0,5,5,nil,tp)
		-- 若选中了被封印怪兽，则中断当前效果处理
		if g:GetCount()>0 then Duel.BreakEffect() end
		-- 遍历选中的被封印怪兽
		for tc in aux.Next(g) do
			-- 将被封印怪兽装备给魔神火焰炮
			if Duel.Equip(tp,tc,c) then
				-- 设置装备限制，确保被封印怪兽只能装备给魔神火焰炮
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetLabelObject(c)
				e1:SetValue(s.eqlimit)
				tc:RegisterEffect(e1)
				-- 设置装备后的攻击力提升效果
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_EQUIP)
				e2:SetCode(EFFECT_UPDATE_ATTACK)
				e2:SetValue(2000)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
			end
		end
	end
	-- 设置发动后直到回合结束时自己不能发动其他效果的限制
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetTargetRange(1,0)
	e3:SetLabel(c:GetFieldID())
	e3:SetValue(s.aclimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果，使对方不能发动其他效果
	Duel.RegisterEffect(e3,tp)
end
-- 装备限制函数，判断被装备的卡是否为魔神火焰炮
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
