--魔神火焔砲
-- 效果：
-- ①：原本卡名包含「艾克佐迪亚」的场上1只10星以上的怪兽得到以下效果。
-- ●把基本分支付一半才能发动。双方的魔法与陷阱区域的卡全部破坏。那之后，从手卡·卡组把5只「被封印」怪兽各当作攻击力上升2000的装备魔法卡使用给这张卡装备。这个效果的发动后，直到回合结束时自己不能把这张卡以外的卡的效果发动。
-- ●这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
local s,id,o=GetID()
-- 初始化魔神火焰炮的卡牌效果：注册其①效果的发动，作为魔法卡发动时选择场上1只原本卡名包含「艾克佐迪亚」的10星以上表侧表示怪兽，使其获得后续效果。
function s.initial_effect(c)
	-- ①：原本卡名包含「艾克佐迪亚」的场上1只10星以上的怪兽得到以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 筛选符合条件的对象：表侧表示且原本卡名包含「艾克佐迪亚」、等级10以上、且未适用过本效果的怪兽。
function s.filter(c)
	return c:IsFaceup() and c:IsOriginalSetCard(0xde) and c:IsLevelAbove(10) and c:GetFlagEffect(id)==0
end
-- 效果发动前检查：确认双方怪兽区是否存在至少1只满足s.filter筛选条件的怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时（chk==0）返回是否存在可指定的对象，以决定效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 处理①效果：选择1只符合条件的怪兽，赋予其“破坏魔陷并装备被封印怪兽”的起动效果、贯穿伤害效果，并处理非效果怪兽变更为效果怪兽，最后为该怪兽打上适用标记。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示消息，让玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让发动玩家从双方场上选择1只满足s.filter条件的怪兽，并将其指定为当前连锁的对象。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local c=e:GetHandler()
	local tc=g:GetFirst()
	if tc then
		-- 为被选中的怪兽播放选中动画，并将其记录为效果对象。
		Duel.HintSelection(g)
		-- 把基本分支付一半才能发动。双方的魔法与陷阱区域的卡全部破坏。那之后，从手卡·卡组把5只「被封印」怪兽各当作攻击力上升2000的装备魔法卡使用给这张卡装备。这个效果的发动后，直到回合结束时自己不能把这张卡以外的卡的效果发动。
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
		-- 这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
		local e2=Effect.CreateEffect(tc)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_PIERCE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if not tc:IsType(TYPE_EFFECT) then
			-- “得到以下效果”（若对象原有类型不是效果怪兽，则为其添加效果怪兽类型以便获得上述效果）。
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
-- 自肃判定函数：若效果发动者的field id不等于被赋予效果的这张卡的field id，则禁止发动，用于实现“不能把这张卡以外的卡的效果发动”。
function s.aclimit(e,re,tp)
	local c=re:GetHandler()
	return e:GetLabel()~=c:GetFieldID()
end
-- 该起动效果的发动代价：支付当前基本分的一半。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 实际支付基本分一半（向下取整）的LP。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 筛选位于魔法与陷阱区域（五个魔陷格，不包括场地区）的卡，用于确定“双方的魔法与陷阱区域的卡”。
function s.desfilter(c)
	return c:GetSequence()<5
end
-- 筛选可装备的「被封印」怪兽：属于被封印系列、是怪兽卡、魔陷区不存在同名卡且不是禁止卡。
function s.eqfilter(c,tp)
	return c:IsSetCard(0x40) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden()
end
-- 起动效果发动条件：场上魔法与陷阱区域存在可破坏的卡，且手卡·卡组中有至少5只符合条件的「被封印」怪兽。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上魔法与陷阱区域是否存在至少1张卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil)
		-- 检查手卡·卡组中是否存在至少5只符合条件的「被封印」怪兽。
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK+LOCATION_HAND,0,5,nil,tp) end
	-- 取得双方魔法与陷阱区域中所有要破坏的卡。
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	-- 向系统登记本次破坏操作的对象组及数量，供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 执行①的起动效果：破坏双方魔法与陷阱区域全部卡；若破坏成功且己方魔陷区已无剩余，则从手卡·卡组选择5只「被封印」怪兽装备给对象（每只攻击力+2000并设置装备限制）；最后为对象施加自肃效果。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得双方魔法与陷阱区域中所有要破坏的卡。
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	-- 实际破坏双方魔法与陷阱区域的所有卡，并确认至少破坏1张且己方魔陷区已无残留，才继续后续装备处理。
	if Duel.Destroy(sg,REASON_EFFECT)~=0 and Duel.GetMatchingGroupCount(s.desfilter,tp,LOCATION_SZONE,0,nil)==0 then
		-- 从手卡·卡组选择5只符合条件的「被封印」怪兽，准备作为装备卡。
		local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK+LOCATION_HAND,0,5,5,nil,tp)
		-- 若成功选择了装备用怪兽，则中断当前效果处理，使后续装备动作与破坏处理分开，避免时点问题。
		if g:GetCount()>0 then Duel.BreakEffect() end
		-- 遍历选出的「被封印」怪兽，逐一尝试装备。
		for tc in aux.Next(g) do
			-- 尝试将当前「被封印」怪兽以攻击力上升2000的装备魔法卡形式装备到对象怪兽上。
			if Duel.Equip(tp,tc,c) then
				-- “各当作攻击力上升2000的装备魔法卡使用给这张卡装备”（装备限制：只能装备给对象怪兽）。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetLabelObject(c)
				e1:SetValue(s.eqlimit)
				tc:RegisterEffect(e1)
				-- “攻击力上升2000”。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_EQUIP)
				e2:SetCode(EFFECT_UPDATE_ATTACK)
				e2:SetValue(2000)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
			end
		end
	end
	-- “这个效果的发动后，直到回合结束时自己不能把这张卡以外的卡的效果发动。”（同时定义装备限制函数s.eqlimit。）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetTargetRange(1,0)
	e3:SetLabel(c:GetFieldID())
	e3:SetValue(s.aclimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册为影响己方玩家的领域效果，持续到回合结束。
	Duel.RegisterEffect(e3,tp)
end
-- 装备限制判定：仅允许这张被赋予效果的怪兽作为这些「被封印」装备卡的装备对象。
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
