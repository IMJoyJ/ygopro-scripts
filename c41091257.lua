--SPYRAL－ダンディ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，宣言卡的种类（怪兽·魔法·陷阱）才能发动。对方卡组最上面的卡给双方确认，宣言的种类的卡的场合，这张卡从手卡特殊召唤。
-- ②：这张卡用「秘旋谍」卡的效果特殊召唤成功的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
function c41091257.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，宣言卡的种类（怪兽·魔法·陷阱）才能发动。对方卡组最上面的卡给双方确认，宣言的种类的卡的场合，这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41091257,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,41091257)
	e1:SetTarget(c41091257.sptg)
	e1:SetOperation(c41091257.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡用「秘旋谍」卡的效果特殊召唤成功的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41091257,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,41091258)
	e2:SetCondition(c41091257.descon)
	e2:SetTarget(c41091257.destg)
	e2:SetOperation(c41091257.desop)
	c:RegisterEffect(e2)
end
-- 检查是否满足①效果的发动条件：对方卡组存在卡片、自己场上存在怪兽区域、此卡可以特殊召唤。
function c41091257.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方卡组是否存在卡片。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0
		-- 检查自己场上是否存在怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择卡的种类（怪兽·魔法·陷阱）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 记录玩家宣言的卡的种类。
	e:SetLabel(Duel.AnnounceType(tp))
	-- 设置效果处理信息，表示此效果将特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理函数：确认对方卡组最上方的卡，若其种类与宣言一致则特殊召唤此卡。
function c41091257.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查对方卡组是否存在卡片。
	if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)==0 then return end
	-- 确认对方卡组最上方的1张卡。
	Duel.ConfirmDecktop(1-tp,1)
	-- 获取对方卡组最上方的1张卡。
	local g=Duel.GetDecktopGroup(1-tp,1)
	local tc=g:GetFirst()
	local opt=e:GetLabel()
	if (opt==0 and tc:IsType(TYPE_MONSTER)) or (opt==1 and tc:IsType(TYPE_SPELL)) or (opt==2 and tc:IsType(TYPE_TRAP)) then
		if not c:IsRelateToEffect(e) then return end
		-- 将此卡特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断此卡是否通过「秘旋谍」卡的效果特殊召唤成功。
function c41091257.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSpecialSummonSetCard(0xee)
end
-- ②效果的处理函数：选择对方场上1张魔法·陷阱卡进行破坏。
function c41091257.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 检查对方场上是否存在魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 提示玩家选择要破坏的魔法·陷阱卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张魔法·陷阱卡作为破坏对象。
	local g=Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置效果处理信息，表示此效果将破坏选定的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果的处理函数：破坏选定的对方魔法·陷阱卡。
function c41091257.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏目标卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
