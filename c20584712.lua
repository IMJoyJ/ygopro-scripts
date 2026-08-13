--SPYRAL－タフネス
-- 效果：
-- ①：这张卡的卡名只要在场上·墓地存在当作「秘旋谍-花公子」使用。
-- ②：1回合1次，宣言卡的种类（怪兽·魔法·陷阱），以对方场上1张卡为对象才能发动。对方卡组最上面的卡给双方确认，宣言的种类的卡的场合，作为对象的卡破坏。
function c20584712.initial_effect(c)
	-- 为这张卡注册一个在场上·墓地时卡名当作「秘旋谍-花公子」使用的效果。
	aux.EnableChangeCode(c,41091257,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：1回合1次，宣言卡的种类（怪兽·魔法·陷阱），以对方场上1张卡为对象才能发动。对方卡组最上面的卡给双方确认，宣言的种类的卡的场合，作为对象的卡破坏。
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
-- 效果发动前的条件检测：确认对方场上有可成为对象的卡，且对方卡组最上方有卡可确认；满足这些条件时该效果才能发动。
function c20584712.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在至少1张可以成为效果对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil)
		-- 并且检查对方卡组最上方是否有卡存在（因为需要翻开对方卡组最上面的卡）。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
	-- 向操作玩家显示“请选择一个种类”的提示，用于宣言怪兽/魔法/陷阱。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 让操作玩家宣言一个卡片种类（怪兽/魔法/陷阱），把宣言结果以数字（0/1/2）存入效果的Label，供效果处理时进行判断。
	e:SetLabel(Duel.AnnounceType(tp))
	-- 向操作玩家显示“请选择要破坏的卡”的提示，准备选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为此效果的对象（取对象效果）。
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
end
-- 效果处理流程：若对方卡组无卡则终止；取得对象卡并确认其仍与此效果相关；确认对方卡组最上方1张卡；若宣言的种类与翻开卡的种类一致，则将对象卡破坏。
function c20584712.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认对方卡组最上方有卡，若无卡则直接结束处理。
	if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)==0 then return end
	-- 取得发动时选择的对象卡（对方场上的那张卡）。
	local dc=Duel.GetFirstTarget()
	if not dc:IsRelateToEffect(e) then return end
	-- 将对方卡组最上方的1张卡展示给双方玩家确认。
	Duel.ConfirmDecktop(1-tp,1)
	-- 取得对方卡组最上方的1张卡（作为Group形式），用于判断其种类。
	local g=Duel.GetDecktopGroup(1-tp,1)
	local tc=g:GetFirst()
	local opt=e:GetLabel()
	if (opt==0 and tc:IsType(TYPE_MONSTER)) or (opt==1 and tc:IsType(TYPE_SPELL)) or (opt==2 and tc:IsType(TYPE_TRAP)) then
		-- 当宣言的卡种类与翻开确认的卡种类一致时，以效果破坏对象卡。
		Duel.Destroy(dc,REASON_EFFECT)
	end
end
