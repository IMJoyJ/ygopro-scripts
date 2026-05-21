--RUM－アージェント・カオス・フォース
-- 效果：
-- 这个卡名的②的效果在决斗中只能使用1次。
-- ①：以自己场上1只5阶以上的超量怪兽为对象才能发动。比那只自己怪兽阶级高1阶的1只「混沌No.」怪兽或「混沌超量」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
-- ②：这张卡在墓地存在的状态，自己场上有5阶以上的超量怪兽特殊召唤时才能发动。这张卡加入手卡。
function c94220427.initial_effect(c)
	-- ①：以自己场上1只5阶以上的超量怪兽为对象才能发动。比那只自己怪兽阶级高1阶的1只「混沌No.」怪兽或「混沌超量」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c94220427.target)
	e1:SetOperation(c94220427.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果在决斗中只能使用1次。②：这张卡在墓地存在的状态，自己场上有5阶以上的超量怪兽特殊召唤时才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94220427,0))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,94220427+EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(c94220427.thcon)
	e2:SetTarget(c94220427.thtg)
	e2:SetOperation(c94220427.thop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的5阶以上的超量怪兽，且额外卡组存在可重叠召唤的「混沌No.」或「混沌超量」怪兽，并满足超量素材限制
function c94220427.filter1(c,e,tp)
	local rk=c:GetRank()
	return rk>4 and c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 检查额外卡组是否存在比该怪兽阶级高1阶的、可重叠召唤的「混沌No.」或「混沌超量」怪兽
		and Duel.IsExistingMatchingCard(c94220427.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+1,c:GetCode())
		-- 检查该怪兽是否满足必须作为超量素材的限制
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 过滤额外卡组中阶级比目标怪兽高1阶的「混沌No.」或「混沌超量」怪兽，且该怪兽可以进行超量召唤并有可用的额外怪兽区域
function c94220427.filter2(c,e,tp,mc,rk,code)
	if c:GetOriginalCode()==6165656 and code~=48995978 then return false end
	return c:IsRank(rk) and c:IsSetCard(0x1048,0x1073) and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽是否能以超量召唤的方式特殊召唤，且在将素材怪兽离场后，额外卡组怪兽出场的可用空格数大于0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果①的发动准备，检查场上是否存在符合条件的对象，并让玩家选择1只5阶以上的超量怪兽作为对象，设置特殊召唤的操作信息
function c94220427.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c94220427.filter1(chkc,e,tp) end
	-- 检查场上是否存在符合条件的可作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c94220427.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要作为效果对象的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择1只符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c94220427.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，表明此效果会从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的处理，将作为对象的怪兽及其超量素材作为重叠素材，从额外卡组超量召唤特殊召唤高1阶的「混沌No.」或「混沌超量」怪兽
function c94220427.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否满足必须作为超量素材的限制，若不满足则效果不处理
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只符合条件的「混沌No.」或「混沌超量」怪兽
	local g=Duel.SelectMatchingCard(tp,c94220427.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1,tc:GetCode())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将原超量怪兽持有的超量素材转移给新特殊召唤的怪兽
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将原超量怪兽重叠在新特殊召唤的怪兽下面作为超量素材
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将新超量怪兽以超量召唤的方式特殊召唤到场上
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
-- 过滤自己场上表侧表示的5阶以上的超量怪兽，用于检测是否有符合条件的怪兽特殊召唤
function c94220427.cfilter(c,tp)
	return c:IsFaceup() and c:IsRankAbove(5) and c:IsControler(tp)
end
-- 效果②的发动条件，检查本次特殊召唤的怪兽中是否存在自己场上5阶以上的超量怪兽
function c94220427.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c94220427.cfilter,1,nil,tp)
end
-- 效果②的发动准备，检查此卡是否能加入手卡，并设置回收的操作信息
function c94220427.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置加入手卡的操作信息，表明此效果会将墓地的这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的处理，将墓地的这张卡加入手卡并给对方确认
function c94220427.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡因效果加入持有者的手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的这张卡
		Duel.ConfirmCards(1-tp,c)
	end
end
