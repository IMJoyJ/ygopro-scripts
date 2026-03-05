--沈黙狼－カルーポ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合发动。自己卡组最上面的卡当作攻击力上升500的装备卡使用以里侧表示给这张卡装备。
-- ②：自己·对方的结束阶段发动。对方对这张卡的①的效果装备中的卡的原本种类（怪兽·魔法·陷阱）作猜测。猜中的场合，这张卡送去墓地。猜错的场合，对方手卡随机选1张丢弃，这张卡回到持有者手卡。
local s,id,o=GetID()
-- 创建并注册卡片的三个效果：①通常召唤成功时发动的效果、①特殊召唤成功时发动的效果、②结束阶段发动的效果
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合发动。自己卡组最上面的卡当作攻击力上升500的装备卡使用以里侧表示给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己·对方的结束阶段发动。对方对这张卡的①的效果装备中的卡的原本种类（怪兽·魔法·陷阱）作猜测。猜中的场合，这张卡送去墓地。猜错的场合，对方手卡随机选1张丢弃，这张卡回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.guesstg)
	e3:SetOperation(s.guessop)
	c:RegisterEffect(e3)
end
-- 效果①的发动时点处理函数，用于判断是否满足发动条件
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 效果①的处理函数，从卡组顶部取出一张卡作为装备卡装备给自身
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己卡组最上方的一张卡
	local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
	-- 判断自身是否在场且效果有效，以及场上是否有可用的魔陷区域
	if c:IsFaceup() and c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断取出的卡是否为里侧表示且自己可以将其盖放
		and tc and tc:IsFacedown() and Duel.IsPlayerCanSSet(tp,tc) then
		-- 禁止后续操作进行洗牌检测
		Duel.DisableShuffleCheck()
		if tc:IsForbidden() then
			-- 若取出的卡被禁止使用，则将其送去墓地
			Duel.SendtoGrave(tc,REASON_RULE)
			return
		end
		-- 尝试将取出的卡装备给自身
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 设置装备卡只能被此卡装备的限制
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 设置装备卡装备后攻击力增加500
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e2:SetValue(500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
-- 装备对象限制函数，确保装备卡只能被此卡装备
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果②的发动时点处理函数，用于设置连锁操作信息
function s.guesstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，提示对方需要丢弃手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
end
-- 筛选装备卡的过滤函数，用于筛选出被此卡装备且为里侧表示的卡
function s.eqfilter(c)
	return c:IsFacedown() and c:GetFlagEffect(id)~=0
end
-- 效果②的处理函数，对方猜测装备卡类型，根据猜测结果执行不同效果
function s.guessop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetEquipGroup():Filter(s.eqfilter,nil):GetFirst()
	if tc then
		-- 提示对方选择卡片类型
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
		-- 让对方玩家宣言一个卡片类型（怪兽/魔法/陷阱）
		local op=Duel.AnnounceType(1-tp)
		if (op==0 and tc:GetOriginalType()&TYPE_MONSTER~=0)
			or (op==1 and tc:GetOriginalType()&TYPE_SPELL~=0)
			or (op==2 and tc:GetOriginalType()&TYPE_TRAP~=0)
			and c:IsAbleToGrave() then
			-- 若猜测正确，将自身送去墓地
			Duel.SendtoGrave(c,REASON_EFFECT)
		elseif (op==0 and tc:GetOriginalType()&TYPE_MONSTER==0)
			or (op==1 and tc:GetOriginalType()&TYPE_SPELL==0)
			or (op==2 and tc:GetOriginalType()&TYPE_TRAP==0) then
			-- 获取对方手牌组
			local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
			if g:GetCount()==0 then return end
			local sg=g:RandomSelect(1-tp,1)
			-- 若猜测错误，将对方手牌中随机一张送去墓地，并将自身送回手牌
			if Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)>0 and c:IsAbleToHand() then
				-- 将自身送回持有者手牌
				Duel.SendtoHand(c,nil,REASON_EFFECT)
			end
		end
	end
end
