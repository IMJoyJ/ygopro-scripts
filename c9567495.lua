--闘龍門
-- 效果：
-- 6星怪兽×2
-- 「斗龙门」1回合1次也能在自己场上的3阶以下的超量怪兽上面重叠来超量召唤。这张卡在超量召唤的回合不能作为超量召唤的素材。
-- ①：1回合1次，可以发动。这张卡的超量素材任意数量取除。这张卡的攻击力上升取除的超量素材种类（怪兽·魔法·陷阱）×1000，对方场上有怪兽存在的场合，那些攻击力下降所上升的数值。这个回合，这张卡可以向对方怪兽全部各作1次攻击。
local s,id,o=GetID()
-- 初始化效果：设置超量召唤手续（包含在3阶以下超量怪兽上重叠超量召唤）、超量召唤回合不能作为超量素材的限制，以及去除素材上升攻击力、降低对方怪兽攻击力并可以向全部怪兽攻击的起动效果
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,6,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)  --"是否在超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- 这张卡在超量召唤的回合不能作为超量召唤的素材。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetCondition(s.xyzcon)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	-- ①：1回合1次，可以发动。这张卡的超量素材任意数量取除。这张卡的攻击力上升取除的超量素材种类（怪兽·魔法·陷阱）×1000，对方场上有怪兽存在的场合，那些攻击力下降所上升的数值。这个回合，这张卡可以向对方怪兽全部各作1次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"发动"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 条件过滤：判断自身是否在特殊召唤的回合且是通过超量召唤登场
function s.xyzcon(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 条件过滤：用于重叠超量召唤的素材必须是自己场上表侧表示的3阶以下的超量怪兽
function s.ovfilter(c)
	return c:IsFaceup() and c:IsRankBelow(3) and c:IsType(TYPE_XYZ)
end
-- 超量召唤操作：处理「斗龙门」1回合1次在超量怪兽上重叠超量召唤的限制
function s.xyzop(e,tp,chk)
	-- 条件检查：检查该玩家本回合是否还未进行过「斗龙门」的重叠超量召唤
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 状态注册：为玩家注册本回合已进行过「斗龙门」重叠超量召唤的标识，持续到回合结束
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 条件过滤：自身当前不具有可以向全部怪兽攻击的效果时才能发动
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsHasEffect(EFFECT_ATTACK_ALL)
end
-- 效果靶向：检查自身是否可以去除至少1个超量素材作为发动代价
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
end
-- 效果执行：赋予自身向对方全部怪兽各作1次攻击的效果，并让玩家选择任意数量的超量素材取除，根据取除素材的种类数上升自身攻击力，并使对方场上所有表侧表示怪兽的攻击力下降相同数值
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local og=c:GetOverlayGroup()
	if c:IsRelateToChain() then
		-- 这个回合，这张卡可以向对方怪兽全部各作1次攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ATTACK_ALL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		if #og>0 then
			local ct=0
			-- 系统提示：提示玩家选择要取除的超量素材
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)  --"请选择要取除的超量素材"
			local sg=og:Select(tp,1,#og,nil)
			-- 条件检查：如果成功将选中的超量素材送去墓地
			if #sg>0 and Duel.SendtoGrave(sg,REASON_EFFECT)>0 then
				-- 事件触发：触发去除超量素材的单体时点
				Duel.RaiseSingleEvent(c,EVENT_DETACH_MATERIAL,e,0,0,0,0)
				for _,type in ipairs({TYPE_MONSTER,TYPE_SPELL,TYPE_TRAP}) do
					if sg:IsExists(Card.IsType,1,nil,type) then
						ct=ct+1
					end
				end
			end
			if ct>0 and c:IsFaceup() then
				-- 这张卡的攻击力上升取除的超量素材种类（怪兽·魔法·陷阱）×1000
				local e2=Effect.CreateEffect(c)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_UPDATE_ATTACK)
				e2:SetValue(ct*1000)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				c:RegisterEffect(e2)
				if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
					-- 卡片过滤：获取对方场上所有表侧表示的怪兽
					local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
					local tc=g:GetFirst()
					while tc do
						-- 对方场上有怪兽存在的场合，那些攻击力下降所上升的数值。
						local e3=Effect.CreateEffect(c)
						e3:SetType(EFFECT_TYPE_SINGLE)
						e3:SetCode(EFFECT_UPDATE_ATTACK)
						e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
						e3:SetValue(-ct*1000)
						e3:SetReset(RESET_EVENT+RESETS_STANDARD)
						tc:RegisterEffect(e3)
						tc=g:GetNext()
					end
				end
			end
		end
	end
end
