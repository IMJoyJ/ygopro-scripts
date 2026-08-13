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
-- ①效果的目标函数：进行发动条件判定，要求对方卡组有卡、自己主要怪兽区有空位且此卡能够特殊召唤，满足后进入发动时的宣言种类操作。
function c41091257.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件之一：对方卡组至少有1张卡。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0
		-- 发动条件之一：自己主要怪兽区有空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 弹出选择提示，让玩家宣言一个卡片种类（怪兽/魔法/陷阱）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 记录玩家宣言的卡种到效果的Label中，供效果处理时判定翻开的卡是否相符。
	e:SetLabel(Duel.AnnounceType(tp))
	-- 设置操作信息，声明本效果将进行特殊召唤，对象为本卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：若对方卡组无卡则终止；确认对方卡组最上方1张，若其种类与宣言的卡种一致且本卡仍与效果关联，则将本卡特殊召唤。
function c41091257.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 对方卡组为0张时，无法确认卡牌，效果处理不进行。
	if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)==0 then return end
	-- 向双方玩家确认对方卡组最上方1张卡。
	Duel.ConfirmDecktop(1-tp,1)
	-- 获取对方卡组最上方1张卡作为对象组。
	local g=Duel.GetDecktopGroup(1-tp,1)
	local tc=g:GetFirst()
	local opt=e:GetLabel()
	if (opt==0 and tc:IsType(TYPE_MONSTER)) or (opt==1 and tc:IsType(TYPE_SPELL)) or (opt==2 and tc:IsType(TYPE_TRAP)) then
		if not c:IsRelateToEffect(e) then return end
		-- 将本卡特殊召唤到自己的主要怪兽区，表侧表示。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：本卡是否通过「秘旋谍」卡的效果特殊召唤成功（判断特殊召唤的来源字段）。
function c41091257.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSpecialSummonSetCard(0xee)
end
-- ②效果的目标函数：检查对方场上是否存在可选的魔法·陷阱卡，并选择1张作为破坏对象，同时登记破坏的操作信息。
function c41091257.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 发动条件：对方场上有1张可供选择的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 显示选择要破坏的卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1张魔法·陷阱卡作为效果对象并登记。
	local g=Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置操作信息，声明本效果将破坏所选择的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果的处理：取得对象卡，若对象仍与效果关联，则将其破坏。
function c41091257.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果的原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
