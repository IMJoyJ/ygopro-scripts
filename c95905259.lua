--予言僧 チョウレン
-- 效果：
-- ①：1回合1次，宣言卡的种类（魔法·陷阱），以对方的魔法与陷阱区域盖放的1张卡为对象才能发动。那张盖放的卡给双方确认，宣言的种类的场合，这个回合那张卡不能发动。
function c95905259.initial_effect(c)
	-- ①：1回合1次，宣言卡的种类（魔法·陷阱），以对方的魔法与陷阱区域盖放的1张卡为对象才能发动。那张盖放的卡给双方确认，宣言的种类的场合，这个回合那张卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95905259,0))  --"确认盖卡"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c95905259.target)
	e1:SetOperation(c95905259.operation)
	c:RegisterEffect(e1)
end
-- 过滤出对方魔陷区（非场地区）的里侧表示卡片
function c95905259.filter(c)
	return c:GetSequence()~=5 and c:IsFacedown()
end
-- 效果发动的对象选择与卡片种类宣言
function c95905259.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE) and c95905259.filter(chkc) end
	-- 检查对方魔陷区是否存在可作为对象的里侧表示卡片
	if chk==0 then return Duel.IsExistingTarget(c95905259.filter,tp,0,LOCATION_SZONE,1,nil) end
	-- 提示玩家选择要确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(95905259,1))  --"请选择一张要确认的卡"
	-- 选择对方魔陷区1张里侧表示的卡作为效果对象
	Duel.SelectTarget(tp,c95905259.filter,tp,0,LOCATION_SZONE,1,1,nil)
	-- 提示玩家选择卡片种类
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 玩家宣言卡片种类（魔法或陷阱）
	local res=Duel.SelectOption(tp,71,72)
	e:SetLabel(res)
end
-- 效果处理，确认对象卡片，若与宣言种类相同则使其本回合不能发动
function c95905259.operation(e,tp,eg,ep,ev,re,r,rp)
	local res=e:GetLabel()
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFacedown() then
		-- 将作为对象的盖放卡给双方确认
		Duel.ConfirmCards(tp,tc)
		if (res==0 and tc:IsType(TYPE_SPELL)) or (res==1 and tc:IsType(TYPE_TRAP)) then
			-- 这个回合那张卡不能发动。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1,true)
		end
	end
end
