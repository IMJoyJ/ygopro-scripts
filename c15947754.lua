--沈黙狼－カルーポ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合发动。自己卡组最上面的卡当作攻击力上升500的装备卡使用以里侧表示给这张卡装备。
-- ②：自己·对方的结束阶段发动。对方对这张卡的①的效果装备中的卡的原本种类（怪兽·魔法·陷阱）作猜测。猜中的场合，这张卡送去墓地。猜错的场合，对方手卡随机选1张丢弃，这张卡回到持有者手卡。
local s,id,o=GetID()
-- 初始化卡片效果：注册召唤/特殊召唤成功时的效果①，以及结束阶段发动的效果②
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
	-- 这个卡名的②的效果1回合只能使用1次。②：自己·对方的结束阶段发动。对方对这张卡的①的效果装备中的卡的原本种类（怪兽·魔法·陷阱）作猜测。猜中的场合，这张卡送去墓地。猜错的场合，对方手卡随机选1张丢弃，这张卡回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_HANDES_OPPO)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.guesstg)
	e3:SetOperation(s.guessop)
	c:RegisterEffect(e3)
end
-- 效果①的Target函数：必发效果直接返回true
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 效果①的Operation函数：将自己卡组最上面的卡以里侧表示给这张卡装备，并使其攻击力上升500
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己卡组最上方的一张卡
	local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
	-- 检查这张卡是否在怪兽区表侧表示存在，并且魔法与陷阱区域有空余的格子
	if c:IsFaceup() and c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组最上面的卡是否存在且为里侧表示，且玩家能否盖放
		and tc and tc:IsFacedown() and Duel.IsPlayerCanSSet(tp,tc) then
		-- 禁用接下来的洗牌检测
		Duel.DisableShuffleCheck()
		if tc:IsForbidden() then
			-- 如果该卡不能装备，则根据规则送去墓地
			Duel.SendtoGrave(tc,REASON_RULE)
			return
		end
		-- 将卡片作为里侧表示的装备卡装备给这张卡，若装备失败则结束处理
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 以里侧表示给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 攻击力上升500的装备卡使用
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e2:SetValue(500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
-- 装备限制函数，限制只能装备给这张卡
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果②的Target函数：必发效果直接返回true
function s.guesstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 筛选属于该卡①效果装备的里侧表示的卡
function s.eqfilter(c)
	return c:IsFacedown() and c:GetFlagEffect(id)~=0
end
-- 效果②的Operation函数：在结束阶段由对方玩家猜测装备卡的原本种类，猜中则将该卡送去墓地，猜错则对方随机选手卡丢弃且该卡回手卡
function s.guessop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetEquipGroup():Filter(s.eqfilter,nil):GetFirst()
	if tc then
		-- 向对方玩家提示“请选择一个种类”
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
		-- 由对方玩家宣言一个卡片种类（怪兽·魔法·陷阱）
		local op=Duel.AnnounceType(1-tp)
		if (op==0 and tc:GetOriginalType()&TYPE_MONSTER~=0)
			or (op==1 and tc:GetOriginalType()&TYPE_SPELL~=0)
			or (op==2 and tc:GetOriginalType()&TYPE_TRAP~=0)
			and c:IsAbleToGrave() then
			-- 将这张卡送去墓地
			Duel.SendtoGrave(c,REASON_EFFECT)
		elseif (op==0 and tc:GetOriginalType()&TYPE_MONSTER==0)
			or (op==1 and tc:GetOriginalType()&TYPE_SPELL==0)
			or (op==2 and tc:GetOriginalType()&TYPE_TRAP==0) then
			-- 获取对方玩家的全部手卡
			local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
			if g:GetCount()==0 then return end
			local sg=g:RandomSelect(1-tp,1)
			-- 如果成功丢弃对方玩家随机选择的1张手卡，并且这张卡能回到手卡
			if Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)>0 and c:IsAbleToHand() then
				-- 将这张卡回到持有者手卡
				Duel.SendtoHand(c,nil,REASON_EFFECT)
			end
		end
	end
end
