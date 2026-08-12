--SPYRAL－タフネス
-- 效果：
-- ①：这张卡的卡名只要在场上·墓地存在当作「秘旋谍-花公子」使用。
-- ②：1回合1次，宣言卡的种类（怪兽·魔法·陷阱），以对方场上1张卡为对象才能发动。对方卡组最上面的卡给双方确认，宣言的种类的卡的场合，作为对象的卡破坏。
function c20584712.initial_effect(c)
	-- 使该卡在场上或墓地存在时视为「秘旋谍-花公子」使用
	aux.EnableChangeCode(c,41091257,LOCATION_MZONE+LOCATION_GRAVE)
	-- 1回合1次，宣言卡的种类（怪兽·魔法·陷阱），以对方场上1张卡为对象才能发动。对方卡组最上面的卡给双方确认，宣言的种类的卡的场合，作为对象的卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20584712,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c20584712.destg)
	e2:SetOperation(c20584712.desop)
	c:RegisterEffect(e2)
end
-- 设置效果的满足条件：对方场上存在可选择的目标卡，且自己卡组最上方有卡
function c20584712.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查自己卡组是否至少有1张卡
		and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
	-- 提示玩家选择卡的种类（怪兽·魔法·陷阱）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 记录玩家宣言的卡的种类
	e:SetLabel(Duel.AnnounceType(tp))
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为破坏对象
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
end
-- 处理效果的发动，确认对方卡组最上方的卡并判断是否与宣言的种类一致，一致则破坏对象卡
function c20584712.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方卡组是否至少有1张卡
	if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)==0 then return end
	-- 获取当前连锁中选择的目标卡
	local dc=Duel.GetFirstTarget()
	if not dc:IsRelateToEffect(e) then return end
	-- 确认对方卡组最上方的1张卡
	Duel.ConfirmDecktop(1-tp,1)
	-- 获取对方卡组最上方的1张卡组成的Group
	local g=Duel.GetDecktopGroup(1-tp,1)
	local tc=g:GetFirst()
	local opt=e:GetLabel()
	if (opt==0 and tc:IsType(TYPE_MONSTER)) or (opt==1 and tc:IsType(TYPE_SPELL)) or (opt==2 and tc:IsType(TYPE_TRAP)) then
		-- 将目标卡破坏
		Duel.Destroy(dc,REASON_EFFECT)
	end
end
